// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:tix_mobile/src/data/update/installer.dart';
import 'package:tix_mobile/src/data/update/release.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';

/// The installer for the platform this runs on, for the app started from
/// [executable] as process [processId].
UpdateInstaller platformInstaller({
  required String executable,
  required int processId,
}) {
  if (Platform.isLinux) {
    return LinuxInstaller(executable: executable, processId: processId);
  }
  if (Platform.isWindows) {
    return WindowsInstaller(executable: executable, processId: processId);
  }
  if (Platform.isMacOS) {
    return MacInstaller(
      executable: executable,
      processId: processId,
      sandboxed: Platform.environment.containsKey('APP_SANDBOX_CONTAINER_ID'),
    );
  }
  return const NoUpdateInstaller();
}

/// `sh -c` arguments that wait up to a minute for [processId] to exit and
/// then run [command]. The GTK application is unique and macOS keeps one
/// instance, so starting the new copy while this one runs would only hand
/// over to it.
List<String> waitThenRun(int processId, List<String> command) => [
  '-c',
  _waitScript,
  '$processId',
  ...command,
];

const _waitScript =
    r'i=0; while kill -0 "$0" 2>/dev/null && [ $i -lt 300 ]; do '
    r'sleep 0.2; i=$((i+1)); done; exec "$@"';

/// Whether [dir] takes new entries from this user.
Future<bool> writable(Directory dir) async {
  try {
    final probe = await dir.createTemp('.tix-write-');
    await probe.delete();
    return true;
  } on FileSystemException {
    return false;
  }
}

/// [dir]'s parent joined with [name].
String sibling(FileSystemEntity dir, String name) =>
    '${dir.parent.path}${Platform.pathSeparator}$name';

String _base(String path) => path.split(RegExp(r'[/\\]')).last;

Future<void> _run(String exe, List<String> args) async {
  final ProcessResult r;
  try {
    r = await Process.run(exe, args);
  } on ProcessException catch (e) {
    throw UpdateException(UpdateErrorKind.install, '$exe: ${e.message}');
  }
  if (r.exitCode != 0) {
    throw UpdateException(UpdateErrorKind.install, '$exe: ${r.stderr}');
  }
}

Future<void> _remove(FileSystemEntity e) async {
  if (e.existsSync()) await e.delete(recursive: true);
}

/// Renames [installed] to [old] and [staged] to [installed], putting the old
/// one back when the new one cannot be moved in.
Future<void> swapIn(Directory installed, Directory staged, String old) async {
  await _remove(Directory(old));
  final path = installed.path;
  try {
    await installed.rename(old);
  } on FileSystemException catch (e) {
    throw UpdateException(UpdateErrorKind.install, e.message);
  }
  try {
    await staged.rename(path);
  } on FileSystemException catch (e) {
    await Directory(old).rename(path);
    throw UpdateException(UpdateErrorKind.install, e.message);
  }
}

/// The Linux tarball install: a bundle directory holding the binary,
/// `lib/` and `data/`. It is not locked while running, so it is swapped
/// in place.
class LinuxInstaller implements UpdateInstaller {
  /// Replaces the bundle holding [executable].
  LinuxInstaller({
    required this.executable,
    required this.processId,
    this.tar = 'tar',
  });

  /// The running binary.
  final String executable;

  /// This process.
  final int processId;

  /// The tar to unpack with.
  final String tar;

  Directory get _bundle => File(executable).parent;
  String get _name => _base(_bundle.path);
  Directory get _staging => Directory(sibling(_bundle, '.$_name.update'));
  String get _old => sibling(_bundle, '.$_name.old');

  @override
  Future<InstallTarget?> target() async {
    final bundle = _bundle;
    if (!Directory('${bundle.path}/data/flutter_assets').existsSync()) {
      return null;
    }
    return InstallTarget(
      path: bundle.path,
      writable: await writable(bundle.parent) && await writable(bundle),
    );
  }

  @override
  Future<StagedUpdate> stage(File archive, ReleaseVersion version) async {
    final staging = _staging;
    await _remove(staging);
    await staging.create();
    await _run(tar, ['-xzf', archive.path, '-C', staging.path]);
    if (!File('${staging.path}/${_base(executable)}').existsSync()) {
      throw const UpdateException(
        UpdateErrorKind.install,
        'the archive holds no tix bundle',
      );
    }
    return StagedUpdate(version: version, path: staging.path);
  }

  @override
  Future<void> apply(StagedUpdate update, {required bool relaunch}) async {
    await swapIn(_bundle, Directory(update.path), _old);
    if (relaunch) {
      await Process.start(
        '/bin/sh',
        waitThenRun(processId, [executable]),
        mode: ProcessStartMode.detached,
      );
    }
  }

  @override
  Future<void> cleanup() async {
    await _remove(_staging);
    await _remove(Directory(_old));
  }
}

/// The macOS zip install: `tix.app` wherever it was put. Replaced by
/// rename, unpacked with `ditto` so symlinks, permissions and the signature
/// survive and no quarantine is added. The App Sandbox forbids all of it.
class MacInstaller implements UpdateInstaller {
  /// Replaces the app holding [executable], unless [sandboxed].
  MacInstaller({
    required this.executable,
    required this.processId,
    required this.sandboxed,
  });

  /// The running binary, `tix.app/Contents/MacOS/tix`.
  final String executable;

  /// This process.
  final int processId;

  /// Whether the App Sandbox confines this process.
  final bool sandboxed;

  Directory get _app => File(executable).parent.parent.parent;
  String get _name => _base(_app.path);
  Directory get _staging => Directory(sibling(_app, '.$_name.update'));
  String get _old => sibling(_app, '.$_name.old');

  @override
  Future<InstallTarget?> target() async {
    final app = _app;
    if (!app.path.endsWith('.app')) return null;
    return InstallTarget(
      path: app.path,
      writable: !sandboxed && await writable(app.parent),
    );
  }

  @override
  Future<StagedUpdate> stage(File archive, ReleaseVersion version) async {
    final staging = _staging;
    await _remove(staging);
    await staging.create();
    await _run('/usr/bin/ditto', ['-x', '-k', archive.path, staging.path]);
    final app = Directory('${staging.path}/$_name');
    if (!app.existsSync()) {
      throw UpdateException(
        UpdateErrorKind.install,
        'the archive holds no $_name',
      );
    }
    return StagedUpdate(version: version, path: app.path);
  }

  @override
  Future<void> apply(StagedUpdate update, {required bool relaunch}) async {
    final app = _app.path;
    await swapIn(_app, Directory(update.path), _old);
    await _remove(_staging);
    if (relaunch) {
      await Process.start(
        '/bin/sh',
        waitThenRun(processId, ['/usr/bin/open', app]),
        mode: ProcessStartMode.detached,
      );
    }
  }

  @override
  Future<void> cleanup() async {
    await _remove(_staging);
    await _remove(Directory(_old));
  }
}

/// The PowerShell that swaps a Windows install once the app has exited:
/// the running exe and its DLLs are locked until then. It retries the move
/// for a while, because antivirus scanners hold files briefly, and puts the
/// old folder back when the new one cannot be moved in.
const windowsSwapScript = r'''
param(
  [int]$ProcessId,
  [string]$Target,
  [string]$Staged,
  [string]$Old,
  [string]$Exe,
  [int]$Relaunch
)
Wait-Process -Id $ProcessId -Timeout 60 -ErrorAction SilentlyContinue
if (Test-Path -LiteralPath $Old) {
  Remove-Item -LiteralPath $Old -Recurse -Force -ErrorAction SilentlyContinue
}
$moved = $false
for ($i = 0; $i -lt 50 -and -not $moved; $i++) {
  try {
    Move-Item -LiteralPath $Target -Destination $Old -ErrorAction Stop
    $moved = $true
  } catch {
    Start-Sleep -Milliseconds 200
  }
}
if ($moved) {
  try {
    Move-Item -LiteralPath $Staged -Destination $Target -ErrorAction Stop
  } catch {
    Move-Item -LiteralPath $Old -Destination $Target
  }
}
if ($Relaunch -eq 1) { Start-Process -FilePath $Exe }
if (Test-Path -LiteralPath $Target) {
  Remove-Item -LiteralPath $Old -Recurse -Force -ErrorAction SilentlyContinue
}
''';

/// The arguments that run [script] in PowerShell with [windowsSwapScript]'s
/// parameters for one swap.
List<String> windowsSwapArgs({
  required String script,
  required int processId,
  required String target,
  required String staged,
  required String old,
  required String exe,
  required bool relaunch,
}) => [
  '-NoProfile',
  '-NonInteractive',
  '-ExecutionPolicy',
  'Bypass',
  '-WindowStyle',
  'Hidden',
  '-File',
  script,
  '-ProcessId',
  '$processId',
  '-Target',
  target,
  '-Staged',
  staged,
  '-Old',
  old,
  '-Exe',
  exe,
  '-Relaunch',
  if (relaunch) '1' else '0',
];

/// The Windows zip install: the runner folder holding `tix_mobile.exe`,
/// its DLLs and `data\`. The swap happens in a helper after exit.
class WindowsInstaller implements UpdateInstaller {
  /// Replaces the folder holding [executable].
  WindowsInstaller({required this.executable, required this.processId});

  /// The running exe.
  final String executable;

  /// This process.
  final int processId;

  static String get _system =>
      '${Platform.environment['SystemRoot'] ?? r'C:\Windows'}\\System32';

  Directory get _folder => File(executable).parent;
  String get _name => _base(_folder.path);
  Directory get _staging => Directory(sibling(_folder, '.$_name.update'));
  String get _old => sibling(_folder, '.$_name.old');

  @override
  Future<InstallTarget?> target() async {
    final folder = _folder;
    if (!Directory('${folder.path}\\data\\flutter_assets').existsSync()) {
      return null;
    }
    return InstallTarget(
      path: folder.path,
      writable: await writable(folder.parent) && await writable(folder),
    );
  }

  @override
  Future<StagedUpdate> stage(File archive, ReleaseVersion version) async {
    final staging = _staging;
    await _remove(staging);
    await staging.create();
    await _run('$_system\\tar.exe', ['-xf', archive.path, '-C', staging.path]);
    if (!File('${staging.path}\\${_base(executable)}').existsSync()) {
      throw const UpdateException(
        UpdateErrorKind.install,
        'the archive holds no tix folder',
      );
    }
    return StagedUpdate(version: version, path: staging.path);
  }

  @override
  Future<void> apply(StagedUpdate update, {required bool relaunch}) async {
    final dir = await Directory.systemTemp.createTemp('tix-update-');
    final script = File('${dir.path}\\swap.ps1');
    await script.writeAsString(windowsSwapScript);
    await Process.start(
      '$_system\\WindowsPowerShell\\v1.0\\powershell.exe',
      windowsSwapArgs(
        script: script.path,
        processId: processId,
        target: _folder.path,
        staged: update.path,
        old: _old,
        exe: executable,
        relaunch: relaunch,
      ),
      mode: ProcessStartMode.detached,
    );
  }

  @override
  Future<void> cleanup() async {
    await _remove(_staging);
    await _remove(Directory(_old));
  }
}
