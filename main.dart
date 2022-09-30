import 'dart:io';

import 'managers/source_miner/source_miner.dart';
import 'utils/path/path.dart';

class Infomations {
  String projectPath;
  String projectName;
  String projectDirectory;
  String filePath;
  String fileDirectory;
  String fileName;
  String fileExtension;

  Infomations()
      : projectPath = '',
        projectName = '',
        projectDirectory = '',
        filePath = '',
        fileDirectory = '',
        fileName = '',
        fileExtension = '';

  /**
   * get project path
   */
  List<String> _getTargetPathList(String projectPath, String target) {
    List<String> targetPathList = List.empty(growable: true);
    // String targetPath = '';
    Directory(projectPath).listSync(recursive: true).forEach((element) {
      if (element is File) {
        if (basename(element.path) == basename(target)) {
          targetPathList.add(element.path);
        }
      }
    });
    return targetPathList;
  }

  // get infomations
  void getInfomations(String projectPath, String target) {
    this.projectName = basename(projectPath);
    this.projectDirectory = dirname(projectPath);
    this.projectPath = pathjoin(this.projectDirectory, this.projectName);

    print('- Check for "$projectPath" directory');
    if (!Directory(projectPath).existsSync())
      throw Exception('"$projectPath" Directory does not exist.');
    print('Done.');

    print('- Check for "$target" directory');
    if (File(pathjoin(projectPath, target)).existsSync()) {
      this.fileDirectory = dirname(target);
    } else {
      List<String> targetList = _getTargetPathList(this.projectPath, target);
      if (targetList.length > 1) {
        print('The file path is ambiguous. Please specify the exact file.');
        for (String path in targetList) {
          print('- $path');
        }
      } else if (targetList.length == 1) {
        this.fileDirectory =
            dirname(targetList.first).substring(this.projectPath.length + 1);
        this.fileName = basename(target, false);
        this.fileExtension = extname(target);
        this.filePath = pathjoin(
            this.fileDirectory, this.fileName + '.' + this.fileExtension);
      } else {
        throw Exception('"$target" does not exist.');
      }
    }
    print('Done.');

    print("");
    printInfomations();
  }

  // print infomations
  void printInfomations() {
    print('projectPath: ${this.projectPath}');
    print('projectName: ${this.projectName}');
    print('projectDirectory: ${this.projectDirectory}');
    print('filePath: ${this.filePath}');
    print('fileDirectory: ${this.fileDirectory}');
    print('fileName: ${this.fileName}');
    print('fileExtension: ${this.fileExtension}');
  }
}

void usage() {
  print('Usage: dart main.dart <project> <target>');
  print('project :  The project name');
  print('target  :  simple file name or a file name with a path.');
  print("");
  print('example:');
  print('   - just file name');
  print('       dart main.dart /mnt/d/svn/REL-4.1.0.1 PccKredApiAgent.h');
  print('   - file name with a path');
  print(
      '       dart main.dart /mnt/d/svn/REL-4.1.0.1 app/cipher/kred/PccKredApiAgent.h');
  print("");
}

void main(List<String> arguments) {
  if (arguments.length != 2) {
    usage();
    exit(1);
  }
  stdout.write("foo");

  final project = convertPathSeparator(arguments[0]);
  final target = convertPathSeparator(arguments[1]);

  Infomations info = Infomations();
  try {
    info.getInfomations(project, target);
  } catch (e) {
    print(e);
    exit(1);
  }

  // String databasePath = pathjoin('datas', info.projectName + '.json');
  String databasePath = pathjoin(
      'datas${Platform.pathSeparator}${info.projectName}.${Platform.operatingSystem}.json');
  SourceMiner sourceDb = SourceMiner.instance;
  if (!File(databasePath).existsSync()) {
    sourceDb.getSourceWithProject(info.projectPath);
    sourceDb.saveSourceModelList(databasePath);
  } else {
    sourceDb.loadSourceModelList(databasePath);
  }

  sourceDb.getBuildObjectList(
    info.fileDirectory,
    info.fileName,
  );
}
