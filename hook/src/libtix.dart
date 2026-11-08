// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

/// The tix commit libtix is built from, as `tix.lock` pins it.
class TixLock {
  /// Creates a pin.
  const TixLock({required this.commit, required this.version});

  /// Reads `key = value` lines, skipping blanks and `#` comments.
  factory TixLock.parse(String text) {
    final values = <String, String>{};
    for (final raw in const LineSplitter().convert(text)) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final eq = line.indexOf('=');
      if (eq < 0) throw FormatException('tix.lock: want key = value', raw);
      values[line.substring(0, eq).trim()] = line.substring(eq + 1).trim();
    }
    final commit = values['commit'] ?? '';
    if (!RegExp(r'^[0-9a-f]{40}$').hasMatch(commit)) {
      throw FormatException('tix.lock: commit must be a full SHA', commit);
    }
    final version = values['version'] ?? '';
    return TixLock(
      commit: commit,
      version: version.isEmpty ? commit.substring(0, 12) : version,
    );
  }

  /// The full commit SHA.
  final String commit;

  /// The version stamped into the library, `git describe` of [commit].
  final String version;

  /// The abbreviated commit tix reports beside its version.
  String get shortCommit => commit.substring(0, 8);
}

/// One libtix build: a Go target and how to compile and link for it.
class GoTarget {
  /// Creates a target.
  const GoTarget({
    required this.goos,
    required this.goarch,
    this.goarm = '',
    this.variant = '',
    this.cc,
    this.cflags = const [],
    this.extldflags = const [],
    this.dylibLink,
  });

  /// GOOS: android, ios, darwin, linux or windows.
  final String goos;

  /// GOARCH: arm64, arm, amd64 or 386.
  final String goarch;

  /// GOARM, set for 32-bit ARM only.
  final String goarm;

  /// What else changes the output, such as the API level or the SDK.
  final String variant;

  /// The C compiler, with any target flags; null leaves Go's default.
  final String? cc;

  /// CGO_CFLAGS and CGO_LDFLAGS.
  final List<String> cflags;

  /// Flags for the external linker.
  final List<String> extldflags;

  /// When set, Go builds a static archive and this command, given the
  /// archive and the output path, links it into a dynamic library. iOS needs
  /// it: Go has no c-shared mode for iOS.
  final List<String> Function(String archive, String output)? dylibLink;

  /// The library's file name.
  String get fileName => switch (goos) {
    'darwin' || 'ios' => 'libtix.dylib',
    'windows' => 'libtix.dll',
    _ => 'libtix.so',
  };

  /// The cache directory name: everything that changes the output.
  String get key =>
      [goos, goarch, goarm, variant].where((s) => s.isNotEmpty).join('-');

  /// The target NOTICES.json is generated for.
  String get noticesTarget => '$goos/$goarch';
}

/// Fetches tix at the pinned commit and builds libtix from it, caching both
/// per commit and target so a second build is a copy.
class LibtixBuilder {
  /// Builds from [lock] into [cacheRoot], reporting progress to [log].
  LibtixBuilder({
    required this.lock,
    required this.cacheRoot,
    required this.log,
  });

  /// The pinned commit.
  final TixLock lock;

  /// Where sources and builds are cached.
  final Directory cacheRoot;

  /// Progress messages.
  final void Function(String) log;

  static const _module = 'github.com/heliopsy/tix';

  /// The default cache: `~/.cache/tix-mobile/libtix`, or under
  /// `%LOCALAPPDATA%` on Windows.
  static Directory defaultCacheRoot(Map<String, String> env) {
    final base = Platform.isWindows
        ? env['LOCALAPPDATA'] ?? '${env['USERPROFILE']}\\AppData\\Local'
        : '${env['HOME']}/.cache';
    return Directory(_join([base, 'tix-mobile', 'libtix']));
  }

  /// Whether [tool] runs.
  static Future<bool> has(String tool) async {
    try {
      final r = await Process.run(tool, const ['version']);
      return r.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }

  /// The tix source tree at the pinned commit, fetched once.
  Future<Directory> source() async {
    final dir = Directory(_join([cacheRoot.path, 'src', lock.commit]));
    if (File(_join([dir.path, 'go.mod'])).existsSync()) return dir;
    log('fetching tix ${lock.version} (${lock.shortCommit})');
    final tmp = await _scratch(dir.parent, 'src');
    await _run('git', ['init', '-q', tmp.path]);
    await _run('git', [
      '-C',
      tmp.path,
      'fetch',
      '-q',
      '--depth',
      '1',
      'https://$_module.git',
      lock.commit,
    ]);
    await _run('git', ['-C', tmp.path, 'checkout', '-q', 'FETCH_HEAD']);
    return await _publish(tmp, dir);
  }

  /// The directory holding libtix and its NOTICES.json for [target], built
  /// unless the cache has it.
  Future<Directory> build(GoTarget target) async {
    final dir = Directory(_join([cacheRoot.path, lock.commit, target.key]));
    if (File(_join([dir.path, target.fileName])).existsSync() &&
        File(_join([dir.path, 'NOTICES.json'])).existsSync()) {
      return dir;
    }
    final src = await source();
    log('building libtix ${lock.version} for ${target.key}');
    final tmp = await _scratch(dir.parent, target.key);
    final archive = target.dylibLink != null;
    final built = _join([
      tmp.path,
      if (archive) 'libtix.a' else target.fileName,
    ]);
    final ldflags = [
      '-s',
      '-w',
      '-X',
      '$_module/internal/version.Version=${lock.version}',
      '-X',
      '$_module/internal/version.Commit=${lock.shortCommit}',
      if (target.extldflags.isNotEmpty)
        '-extldflags=${target.extldflags.join(' ')}',
    ];
    await _run(
      'go',
      [
        'build',
        '-trimpath',
        '-buildmode=${archive ? 'c-archive' : 'c-shared'}',
        '-ldflags',
        _ldflags(ldflags),
        '-o',
        built,
        './embedded/libtix',
      ],
      workingDirectory: src.path,
      environment: {
        'CGO_ENABLED': '1',
        'GOOS': target.goos,
        'GOARCH': target.goarch,
        'GOARM': target.goarm,
        'CC': ?target.cc,
        if (target.cflags.isNotEmpty) 'CGO_CFLAGS': target.cflags.join(' '),
        if (target.cflags.isNotEmpty) 'CGO_LDFLAGS': target.cflags.join(' '),
      },
    );
    final link = target.dylibLink;
    if (link != null) {
      final cmd = link(built, _join([tmp.path, target.fileName]));
      await _run(cmd.first, cmd.sublist(1));
    }
    await notices(
      target.goos,
      target.goarch,
      File(_join([tmp.path, 'NOTICES.json'])),
    );
    return await _publish(tmp, dir);
  }

  /// Writes the licence notices of the modules libtix links on [goos] and
  /// [goarch] to [out].
  Future<void> notices(String goos, String goarch, File out) async {
    final src = await source();
    await _run('go', [
      'run',
      './internal/notices/gen',
      '-goos',
      goos,
      '-goarch',
      goarch,
      '-version',
      lock.version,
      '-o',
      out.absolute.path,
    ], workingDirectory: src.path);
  }

  /// Runs `xcrun` with [args] and returns what it prints.
  static Future<String> xcrun(List<String> args) async {
    final r = await Process.run('xcrun', args);
    if (r.exitCode != 0) {
      throw ProcessException('xcrun', args, '${r.stderr}', r.exitCode);
    }
    return '${r.stdout}'.trim();
  }

  Future<void> _run(
    String exe,
    List<String> args, {
    String? workingDirectory,
    Map<String, String> environment = const {},
  }) async {
    final r = await Process.run(
      exe,
      args,
      workingDirectory: workingDirectory,
      environment: environment,
    );
    if (r.exitCode != 0) {
      throw ProcessException(
        exe,
        args,
        'exit ${r.exitCode}\n${r.stdout}\n${r.stderr}',
        r.exitCode,
      );
    }
  }

  // Concurrent builds (Flutter runs one hook per ABI) each fill their own
  // scratch directory and rename it into place; the loser of a race keeps
  // the winner's copy.
  Future<Directory> _scratch(Directory parent, String name) async {
    await parent.create(recursive: true);
    return await parent.createTemp('.$name-');
  }

  Future<Directory> _publish(Directory tmp, Directory dir) async {
    try {
      await tmp.rename(dir.path);
    } on FileSystemException {
      if (!dir.existsSync()) rethrow;
      await tmp.delete(recursive: true);
    }
    return dir;
  }

  static String _ldflags(List<String> flags) =>
      flags.map((f) => f.contains(' ') ? "'$f'" : f).join(' ');

  static String _join(List<String> parts) => parts.join(Platform.pathSeparator);
}
