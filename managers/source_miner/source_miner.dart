import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// import 'package:progress_bar/progress_bar.dart';

import '../../models/source_model.dart';
import '../../utils/path/path.dart';
import '../../utils/progress_bar/progress_bar.dart';

part 'p.sort.dart';
part 'p.get_list_with_project_path.dart';
part 'p.find.dart';

class SourceMiner {
  SourceMiner._privateConstructor();
  static final SourceMiner _instance = SourceMiner._privateConstructor();
  static SourceMiner get instance => _instance;
  List<SourceModel> _sourceModelList = [];
  List<SourceModel> get sourceModels => _sourceModelList;

  void getSourceWithProject(String projectDirectory) {
    Directory runDirectory = Directory.current;
    Directory.current = projectDirectory;
    print('Move to ${Directory.current.path}');
    print("");

    print(
        '1. serach for source files in ${projectDirectory + Platform.pathSeparator + 'app'}');
    getSourceByDirectory(_sourceModelList, 'app');

    print("");

    print(
        '2. serach for source files in ${projectDirectory + Platform.pathSeparator + 'lib'}');
    getSourceByDirectory(_sourceModelList, 'lib');
    print('Done.');
    print("");

    print('3. serach for included files');
    getIncludeFiles(_sourceModelList);
    Ascending(_sourceModelList);
    print('Done.');
    Directory.current = runDirectory;
  }

  void saveSourceModelList(String path) {
    File(path).writeAsStringSync(
        jsonEncode(_sourceModelList.map((e) => e.toJson()).toList()));
  }

  void loadSourceModelList(String path) {
    _sourceModelList = (jsonDecode(File(path).readAsStringSync()) as List)
        .map((e) => SourceModel.fromJson(e))
        .toList();
  }

  void getBuildObjectList(String directory, String name) {
    getTargetObjects(_sourceModelList, directory, name);
  }

  int get sourceModelsCount => _sourceModelList.length;
}
