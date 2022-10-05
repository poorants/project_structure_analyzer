part of 'source_manager.dart';

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

    print('- Check for "$target" files');
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
  }
}
