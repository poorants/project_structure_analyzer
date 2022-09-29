// private method, remove the last '/'
import 'dart:io';

String _removeLastSlash(String path) {
  if (path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  } else {
    return path;
  }
}

// get absolute path, and remove the last '/'
String join(String part1,
    [String? part2,
    String? part3,
    String? part4,
    String? part5,
    String? part6,
    String? part7,
    String? part8]) {
  final parts = <String?>[
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
    parts[i] = _removeLastSlash(parts[i]!);
  }

  String path = parts.join('/');
  return Directory(path).uri.path.replaceAll(RegExp(r'\/$'), '');
}

// get directory name
String dirname(String path, [String? ext]) {
  String filename = path.split('/').last;
  return path
      .substring(0, path.length - filename.length)
      .replaceAll(RegExp(r'\/$'), '');
}

// get file name
String basename(String path, [bool withExt = true]) {
  if (withExt) {
    return path.split('/').last;
  } else {
    // example test.123.c
    List<String> parts = path.split('/').last.split('.');
    parts.removeLast();
    return parts.join('.');
  }
}

// get file extention
String extname(String path) {
  return path.split('/').last.split('.').last;
}
