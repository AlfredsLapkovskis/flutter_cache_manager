import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class IOFileSystem implements FileSystem {
  final Future<Directory> _fileDir;
  final String _cacheKey;

  IOFileSystem(this._cacheKey) : _fileDir = createDirectory(_cacheKey);

  static Future<Directory> createDirectory(String key) async {
    final baseDir = await getTemporaryDirectory();
    final path = p.join(baseDir.path, key);

    const fs = LocalFileSystem();
    final directory = fs.directory(path);
    await directory.create(recursive: true);
    return directory;
  }

  @override
  String createRelativePath({String fileName = "", String fileExtension = ""}) {
    if (fileName.isEmpty) {
      return "${const Uuid().v1()}${fileExtension.isNotEmpty ? ".$fileExtension" : ".file"}";
    }

    final uniqueDirName = const Uuid().v1();

    return p.join(uniqueDirName, "$fileName${fileExtension.isNotEmpty ? ".$fileExtension" : ""}");
  }

  @override
  Future<File> createFile(String relativePath) async {
    final directory = await _fileDir;
    if (!(await directory.exists())) {
      await createDirectory(_cacheKey);
    }

    final baseName = p.basename(relativePath);
    final enclosingDirName = _getEnclosingDirName(relativePath);

    if (enclosingDirName.isNotEmpty) {
      final enclosingDir = directory.childDirectory(enclosingDirName);

      if (!(await enclosingDir.exists())) {
        await enclosingDir.create(recursive: true);
      }

      return enclosingDir.childFile(baseName);
    }

    return directory.childFile(baseName);
  }

  @override
  Future<void> deleteFile(String relativePath) async {
    final directory = await _fileDir;
    if (!(await directory.exists())) {
      return;
    }

    final baseName = p.basename(relativePath);
    final enclosingDirName = _getEnclosingDirName(relativePath);

    if (enclosingDirName.isNotEmpty) {
      final enclosingDir = directory.childDirectory(enclosingDirName);

      if (await enclosingDir.exists()) {
        await enclosingDir.delete(recursive: true);
      }
    } else {
      final file = directory.childFile(baseName);
      if (await file.exists()) {
        file.delete();
      }
    }
  }

  String _getEnclosingDirName(String relativePath) {
    final enclosingDirName = p.dirname(relativePath);
    return enclosingDirName != "." && enclosingDirName != p.separator ? enclosingDirName : "";
  }
}
