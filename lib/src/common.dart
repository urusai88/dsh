import 'dart:io';

import 'package:path/path.dart' as p;

import 'fsi.dart';

bool exists(String path) => FileSystemEntity(path).existsSync();

(String, String) _cwd(String src, String dst, String? cwd) {
  if (cwd != null && cwd.isNotEmpty) {
    src = p.join(cwd, src);
    dst = p.join(cwd, dst);
  }
  return (src, dst);
}

void mv(String src, String dst, {String? cwd}) {
  (src, dst) = _cwd(src, dst, cwd);
  FileSystemEntity(src).renameSync(dst);
  print('mv $src -> $dst');
}

void cp(String src, String dst, {String? cwd}) {
  (src, dst) = _cwd(src, dst, cwd);
  switch (FileSystemEntity(src)) {
    case FileSystemEntity(file: final file?):
      File(dst).writeAsBytesSync(file.readAsBytesSync());
    case FileSystemEntity(directory: final directory?):
      directory.create();
  }
  print('cp $src -> $dst');
}

void cpIfNotExists(String src, String dst, {String? cwd}) {
  (src, dst) = _cwd(src, dst, cwd);
  if (!exists(dst)) {
    cp(src, dst);
  }
}

Iterable<FileSystemEntity> scan(String path) =>
    Directory(path).listSync().map((e) => FileSystemEntity(e.path));
