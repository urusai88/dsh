import 'dart:io';

import 'package:path/path.dart' as p;

import 'fsi.dart';
import 'spawn.dart';

bool exists(String path) => FileSystemEntity(path).existsSync();

(String, String) _cwd(String src, String dst, String? cwd) {
  if (cwd != null && cwd.isNotEmpty) {
    src = p.join(cwd, src);
    dst = p.join(cwd, dst);
  }
  return (src, dst);
}

void mv(String src, String dst, {String? cwd}) {
  (src, dst) => _cwd(src, dst, cwd);
  FileSystemEntity(src).renameSync(dst);
}

void cp(String src, String dst, {String? cwd}) {
  (src, dst) => _cwd(src, dst, cwd);

  switch (FileSystemEntity(src)) {
    case FileSystemEntity(file: final file?):
      File(dst).writeAsBytesSync(file.readAsBytesSync());
    case FileSystemEntity(directory: final directory?):
      directory.create();
  }
}

void cpIfNotExists(String src, String dst, {String? cwd}) {
  if (!exists(dst)) {
    cp(src, dst, cwd: cwd);
  }
}

Iterable<FileSystemEntity> scan(String path) =>
    Directory(path).listSync().map((e) => FileSystemEntity(e.path));

Map<String, String> buildScripts(String path) {
  final result = <String, String>{};
  for (final script in scan(path).where((e) =>
      p.basename(e.path).endsWith('.dart') &&
      !p.basename(e.path).startsWith('_'))) {
    final scriptPath = p.normalize(p.absolute(script.path));
    final genName = p.setExtension(scriptPath, '.exe');
    final newName = p.setExtension(scriptPath, '.script');
    final command = [
      'dart',
      'compile',
      'exe',
      scriptPath,
      '-p',
      '.dart_tool/package_config.json',
    ];
    final processResult = spawn(command);
    if (processResult.stderr case final String s when s.isNotEmpty) {
      print('===\n$command\n===');
      print(s);
      break;
    }

    mv(genName, newName);
    result[genName] = newName;
  }
  return result;
}
