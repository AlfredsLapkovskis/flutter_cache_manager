import 'package:file/file.dart';

abstract class FileSystem {
  String createRelativePath({String fileName = "", String fileExtension = ""});
  Future<File> createFile(String relativePath);
  Future<void> deleteFile(String relativePath);
}
