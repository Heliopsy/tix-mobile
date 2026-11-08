// SPDX-License-Identifier: AGPL-3.0-or-later

// Builds the embedded tix engine (libtix) from the commit tix.lock pins, for
// the platform and architecture Flutter is building, and bundles it as a code
// asset. Without Go, or without a C compiler for the target, it bundles
// nothing and the app runs with local databases switched off; set
// `hooks: user_defines: tix_mobile: engine: required` to make that an error
// instead, or `off` to skip the build. See docs/development.md.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import 'src/libtix.dart';

Future<void> main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) return;
    final lockFile = File.fromUri(input.packageRoot.resolve('tix.lock'));
    output.dependencies.add(lockFile.uri);
    final mode = '${input.userDefines['engine'] ?? 'auto'}';
    if (mode == 'off') return;

    void skip(String why) {
      if (mode == 'required') throw StateError('libtix: $why');
      stderr.writeln(
        'libtix: $why; building without the embedded engine, so local '
        'databases are off in this build (docs/development.md)',
      );
    }

    if (!await LibtixBuilder.has('go')) return skip('go is not on PATH');
    final code = input.config.code;
    final target = await _target(code);
    if (target == null) {
      return skip(
        'no C compiler for ${code.targetOS.name}/'
        '${code.targetArchitecture.name}',
      );
    }
    final builder = LibtixBuilder(
      lock: TixLock.parse(lockFile.readAsStringSync()),
      cacheRoot: LibtixBuilder.defaultCacheRoot(Platform.environment),
      log: stderr.writeln,
    );
    final dir = await builder.build(target);
    final lib = File.fromUri(input.outputDirectory.resolve(target.fileName));
    await File('${dir.path}${Platform.pathSeparator}${target.fileName}')
        .copy(lib.path);
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'libtix',
        linkMode: DynamicLoadingBundled(),
        file: lib.uri,
      ),
    );
  });
}

Future<GoTarget?> _target(CodeConfig code) async {
  final arch = code.targetArchitecture;
  final cc = code.cCompiler?.compiler.toFilePath();
  switch (code.targetOS) {
    case OS.android:
      final ndkClang = cc ?? _ndkClang();
      if (ndkClang == null) return null;
      final api = code.android.targetNdkApi;
      final (goarch, triple) = switch (arch) {
        Architecture.arm64 => ('arm64', 'aarch64-linux-android'),
        Architecture.arm => ('arm', 'armv7a-linux-androideabi'),
        Architecture.x64 => ('amd64', 'x86_64-linux-android'),
        Architecture.ia32 => ('386', 'i686-linux-android'),
        _ => throw UnsupportedError('libtix: Android ${arch.name}'),
      };
      return GoTarget(
        goos: 'android',
        goarch: goarch,
        goarm: goarch == 'arm' ? '7' : '',
        variant: 'api$api',
        cc: '${_quoted(ndkClang)} --target=$triple$api',
        // Google Play requires 16 KB pages for Android 15 and later; NDK r28
        // links so by default, older ones need the flag.
        extldflags: const [
          '-Wl,-z,max-page-size=16384',
          '-Wl,-soname,libtix.so',
        ],
      );
    case OS.iOS:
      final sdk = code.iOS.targetSdk.type;
      final v = code.iOS.deploymentVersion;
      final goarch = arch == Architecture.x64 ? 'amd64' : 'arm64';
      final cpu = arch == Architecture.x64 ? 'x86_64' : 'arm64';
      final sim = sdk == 'iphonesimulator' ? '-simulator' : '';
      final triple = '$cpu-apple-ios${v.major}.${v.minor}$sim';
      final clang =
          cc ?? await LibtixBuilder.xcrun(['--sdk', sdk, '-f', 'clang']);
      final sysroot = await LibtixBuilder.xcrun([
        '--sdk',
        sdk,
        '--show-sdk-path',
      ]);
      final flags = ['-isysroot', sysroot, '-target', triple];
      return GoTarget(
        goos: 'ios',
        goarch: goarch,
        variant: '$sdk-${v.major}.${v.minor}',
        cc: _quoted(clang),
        cflags: flags,
        // Go builds no shared library for iOS, so the static archive is
        // linked into one here, whole (-force_load keeps every Tix* symbol),
        // with what the Go runtime needs from the system.
        dylibLink: (archive, out) => [
          clang,
          '-dynamiclib',
          ...flags,
          '-Wl,-force_load,$archive',
          '-framework',
          'CoreFoundation',
          '-framework',
          'Security',
          '-lresolv',
          '-install_name',
          '@rpath/libtix.dylib',
          '-o',
          out,
        ],
      );
    case OS.macOS:
      final v = code.macOS.deploymentVersion;
      final clang = cc ?? await LibtixBuilder.xcrun(['-f', 'clang']);
      final sysroot = await LibtixBuilder.xcrun([
        '--sdk',
        'macosx',
        '--show-sdk-path',
      ]);
      return GoTarget(
        goos: 'darwin',
        goarch: arch == Architecture.x64 ? 'amd64' : 'arm64',
        variant: 'macos${v.major}.${v.minor}',
        cc: _quoted(clang),
        cflags: [
          '-isysroot',
          sysroot,
          '-arch',
          if (arch == Architecture.x64) 'x86_64' else 'arm64',
          '-mmacosx-version-min=${v.major}.${v.minor}',
        ],
        extldflags: const ['-Wl,-install_name,@rpath/libtix.dylib'],
      );
    case OS.linux:
      if (arch != Architecture.current) return null;
      return GoTarget(
        goos: 'linux',
        goarch: arch == Architecture.arm64 ? 'arm64' : 'amd64',
        cc: cc == null ? null : _quoted(cc),
        extldflags: const ['-Wl,-soname,libtix.so'],
      );
    case OS.windows:
      // cgo needs gcc or clang; Flutter offers MSVC, which it cannot drive.
      if (arch != Architecture.x64) return null;
      final gcc = await _firstOnPath(['x86_64-w64-mingw32-gcc', 'gcc']);
      if (gcc == null) return null;
      return GoTarget(goos: 'windows', goarch: 'amd64', cc: gcc);
  }
  return null;
}

String? _ndkClang() {
  final env = Platform.environment;
  for (final name in [
    'ANDROID_NDK_HOME',
    'ANDROID_NDK_LATEST_HOME',
    'ANDROID_NDK_ROOT',
    'ANDROID_NDK',
  ]) {
    final ndk = env[name];
    if (ndk == null || ndk.isEmpty) continue;
    final prebuilt = Directory('$ndk/toolchains/llvm/prebuilt');
    if (!prebuilt.existsSync()) continue;
    for (final host in prebuilt.listSync().whereType<Directory>()) {
      final clang = File(
        '${host.path}/bin/clang${Platform.isWindows ? '.exe' : ''}',
      );
      if (clang.existsSync()) return clang.path;
    }
  }
  return null;
}

Future<String?> _firstOnPath(List<String> tools) async {
  for (final tool in tools) {
    try {
      final r = await Process.run(tool, const ['--version']);
      if (r.exitCode == 0) return tool;
    } on ProcessException {
      continue;
    }
  }
  return null;
}

String _quoted(String path) => path.contains(' ') ? '"$path"' : path;
