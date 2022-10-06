import 'dart:io';

RandomAccessFile replaceRemoteFile(String path) {
  File file = File(path);
  if (file.existsSync()) file.deleteSync();
  file.createSync(recursive: true);
  file.openSync(mode: FileMode.append);
  return File(path).openSync(mode: FileMode.append);
}
