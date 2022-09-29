import 'dart:io';

import 'managers/source_model_manager/source_model_manager.dart';

// Define the main function that receives the directory and filename
// as command-line arguments.

void getSource(String directory, String project) {
  // Get the directory and filename from the command-line arguments.

  String projectDirectory = '$directory/$project';

  SourceModelManager saveDB = SourceModelManager.instance;
  saveDB.getSourceWithProject(projectDirectory);
  saveDB.saveSourceModelList('datas/$project.json');
}

void main(List<String> arguments) {
  String svnPath = '/mnt/d/svn';
  // Get the directory and filename from the command-line arguments.
  // getSource();

  final project = arguments[0];
  final directory = arguments[1];
  final filename = arguments[2];

  // define usage
  if (project.isEmpty || directory.isEmpty || filename.isEmpty) {
    print('Usage: dart main.dart <project> <directory> <filename>');
    exit(1);
  }

  String databasePath = 'datas/$project.json';
  if (!File(databasePath).existsSync()) {
    getSource(svnPath, project);
  }

  SourceModelManager sourceDb = SourceModelManager.instance;
  sourceDb.loadSourceModelList('datas/$project.json');
  sourceDb.getBuildObjectList(
    directory,
    filename,
  );
}
