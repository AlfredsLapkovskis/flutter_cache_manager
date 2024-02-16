import 'package:file/file.dart' show File;
import 'package:file/memory.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';
import 'package:uuid/uuid.dart';

class MemoryCacheSystem implements FileSystem {
  final directory = MemoryFileSystem().systemTempDirectory.createTemp('cache');

  @override
  String createRelativePath({String fileName = "", String fileExtension = ""}) {
    return "${const Uuid().v1()}${fileExtension.isNotEmpty ? ".$fileExtension" : ".file"}";
  }

  @override
  Future<File> createFile(String name) async {
    return (await directory).childFile(name);
  }

  @override
  Future<void> deleteFile(String relativePath) async {
    final file = (await directory).childFile(relativePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
