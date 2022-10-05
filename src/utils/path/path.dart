// private method, remove the last '/'
import 'dart:io';

// convert the pathSeparator to suit the current platform.
// For example, on Windows, the pathSeparator is '\'.
// On Linux, the pathSeparator is '/'.
// On MacOS, the pathSeparator is '/'.

String convertPathSeparator(String path) {
  if (Platform.isWindows) {
    return path.replaceAll(RegExp(r'/'), '\\');
  } else {
    return path.replaceAll(RegExp(r'\\'), '/');
  }
}

String _removeLastSlash(String path) {
  if (path.endsWith(Platform.pathSeparator)) {
    return path.substring(0, path.length - Platform.pathSeparator.length);
  } else {
    return path;
  }
}

// get absolute path, and remove the last Platform.pathSeparator
String pathjoin(String part1,
    [String part2,
    String part3,
    String part4,
    String part5,
    String part6,
    String part7,
    String part8]) {
  final parts = <String>[
    part1,
    part2,
    part3,
    part4,
    part5,
    part6,
    part7,
    part8
  ];

  parts.removeWhere((element) => element == null);
  for (int i = 0; i < parts.length; i++) {
    parts[i] = _removeLastSlash(parts[i]);
  }

  String path = parts.join(Platform.pathSeparator);
  path = Directory(path).uri.path;
  path = convertPathSeparator(path);
  path = _removeLastSlash(path);

  if (Platform.isWindows && path.startsWith(Platform.pathSeparator))
    path = path.substring(1, path.length);

  return path;
}

// get directory name
String dirname(String path) {
  path = convertPathSeparator(path);
  path = _removeLastSlash(path);

  String filename = path.split(Platform.pathSeparator).last;
  return path.substring(
      0, path.length - filename.length - Platform.pathSeparator.length);
}

// get file name
String basename(String path, [bool withExt = true]) {
  path = convertPathSeparator(path);
  path = _removeLastSlash(path);
  if (withExt) {
    return path.split(Platform.pathSeparator).last;
  } else {
    // example test.123.c
    List<String> parts = path.split(Platform.pathSeparator).last.split('.');
    if (parts.length > 1) parts.removeLast();
    return parts.join('.');
  }
}

// get file extention
String extname(String path) {
  path = convertPathSeparator(path);
  path = _removeLastSlash(path);
  return path.split(Platform.pathSeparator).last.split('.').last;
}
