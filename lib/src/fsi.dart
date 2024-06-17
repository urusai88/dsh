import 'dart:io' as io;

class FileSystemEntity extends io.FileSystemEntity {
  FileSystemEntity(String path)
      : assert(!io.Platform.isWindows, 'Cannot be used on Windows'),
        _file = io.File(path),
        _directory = io.Directory(path);

  final io.File _file;
  final io.Directory _directory;

  io.File? get file => _file.existsSync() ? _file : null;

  io.Directory? get directory => _directory.existsSync() ? _directory : null;

  io.FileSystemEntity get _fsi => _file.existsSync() ? _file : _directory;

  @override
  io.FileSystemEntity get absolute => _fsi.absolute;

  @override
  Future<bool> exists() => _fsi.exists();

  @override
  bool existsSync() => _fsi.existsSync();

  @override
  String get path => _fsi.path;

  @override
  Future<io.FileSystemEntity> rename(String newPath) => _fsi.rename(newPath);

  @override
  io.FileSystemEntity renameSync(String newPath) => _fsi.renameSync(newPath);
}
