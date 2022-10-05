part of 'miner.dart';

void mergeSourceModel(List<SourceModel> sourceList, SourceModel source) {
  int index =
      sourceList.indexWhere((element) => element.hashCode == source.hashCode);
  if (index != -1) {
    sourceList[index].merge(source);
  } else {
    sourceList.add(source);
  }
}

/**
 * Locate the file '.h', '.cpp', '.c' in the target directory and add it to the sourceList.
 */
void getSourceByDirectory(List<SourceModel> sourceList, String targetDirectory,
    {List<String> extentionList = const ['h', 'cpp', 'c']}) {
  // Get the files and directories from the path you entered.
  List<FileSystemEntity> entities = Directory(targetDirectory).listSync();
  // Traverse the files and directories you got.
  for (FileSystemEntity entity in entities) {
    // If it's a file
    if (entity is File) {
      // If the file extension is ".h" or ".cpp"
      if (extentionList.contains(extname(entity.path))) {
        // Add it to the SourceModel list.
        SourceModel source = SourceModel(
            name: basename(entity.path, false),
            directory: dirname(entity.path));
        source.addextention(extname(entity.path));
        mergeSourceModel(sourceList, source);
      }
    }
    // If it's a directory
    else if (entity is Directory) {
      // Call it recursively.
      getSourceByDirectory(sourceList, entity.path);
    }
  }
}

/**
 * Returns the header file used by the input file.
 */
List<String> getIncludeNameList(String path) {
  List<String> includeHeaderList = List.empty(growable: true);
  try {
    Uint8List byteList = File(path).readAsBytesSync();

    String content = byteDecode(byteList);
    RegExp regExp = RegExp(r'#*include\s*\"(.*)\"');
    Iterable<RegExpMatch> matches = regExp.allMatches(content);
    for (RegExpMatch match in matches) {
      includeHeaderList.add(match.group(1));
    }
  } catch (e) {
    print('Character Convert Error :: ${path} :: ${e.toString()} :: skipped.');
  }

  return includeHeaderList;
}

/**
 * Decode Byte String to types 'utf8', 'ascii', and 'latin1' to return String content.
 */
String byteDecode(Uint8List byteList) {
  String content = '';
  try {
    content = utf8.decode(byteList);
    return content;
  } catch (e) {}

  try {
    content = ascii.decode(byteList);
    return content;
  } catch (e) {}

  try {
    content = latin1.decode(byteList);
    return content;
  } catch (e) {
    throw e;
  }
}

/**
 * Returns the most likely path to a header file with the same name in the project.
 * 
 */
String getBetterThenIncludePath(
    List<SourceModel> sourceList,
    String sourceDirectory,
    String includeDirectory,
    String name,
    String extention,
    SourceModel source) {
  List<SourceModel> targetList = List.empty(growable: true);
  for (var source in sourceList) {
    if (source.name == name && source.extentionList.contains(extention)) {
      targetList.add(source);
    }
  }

  if (targetList.length == 1) {
    return targetList.first.directory;
  } else if (targetList.length == 0) {
    return "";
  } else {
    for (SourceModel target in targetList) {
      if (target.directory == sourceDirectory) return target.directory;
      if (target.directory == includeDirectory) return target.directory;
    }
    return "";
  }
}

void getIncludeFiles(List<SourceModel> sourceList) {
  ProgressBar bar = new ProgressBar(' [:bar] :percent (:current/:total)',
      total: sourceList.length);
  for (var index = 0; index < sourceList.length; index++) {
    SourceModel source = sourceList[index];

    List<String> targetList = source.getPathList();
    for (var path in targetList) {
      // print('path : $path');
      List<String> includeHeaderList = getIncludeNameList(path);
      for (var includeHeader in includeHeaderList) {
        String includeDirectory = dirname(path);
        String name = basename(includeHeader, false);
        String extention = extname(includeHeader);
        String betterThenIncludePath = getBetterThenIncludePath(sourceList,
            source.directory, includeDirectory, name, extention, source);
        if (betterThenIncludePath != "") {
          sourceList[index].addincludedHashCodeList(
              betterThenIncludePath.hashCode ^ name.hashCode);
        }
      }
    }
    bar.tick();
  }
}
