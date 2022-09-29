import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../models/source_model.dart';
import 'util/path.dart';

part 'sort.dart';
part 'get_list_with_project_path.dart';
part 'find.dart';

class SourceModelManager {
  SourceModelManager._privateConstructor();
  static final SourceModelManager _instance =
      SourceModelManager._privateConstructor();
  static SourceModelManager get instance => _instance;
  List<SourceModel> _sourceModelList = [];
  List<SourceModel> get sourceModels => _sourceModelList;

  void addSourceModel(SourceModel sourceModel) {
    _sourceModelList.add(sourceModel);
  }

  void removeSourceModel(SourceModel sourceModel) {
    _sourceModelList.remove(sourceModel);
  }

  void removeSourceModelAt(int index) {
    _sourceModelList.removeAt(index);
  }

  void clearSourceModels() {
    _sourceModelList.clear();
  }

  // get SourceModel with index

  void updateSourceModel(SourceModel sourceModel) {
    int index = _sourceModelList
        .indexWhere((element) => element.hashCode == sourceModel.hashCode);
    if (index != -1) {
      _sourceModelList[index] = sourceModel;
    }
  }

  void getSourceWithProject(String projectDirectory) {
    Directory runDirectory = Directory.current;
    Directory.current = projectDirectory;
    print('Move to ${Directory.current.path}');
    print("");

    print('1. serach for source files in ${projectDirectory + '/app'}');
    getSourceWithDirectory(_sourceModelList, 'app');
    print('Done.');
    print("");

    print('2. serach for source files in ${projectDirectory + '/lib'}');
    getSourceWithDirectory(_sourceModelList, 'lib');
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

  void printSourceModelList() {
    _sourceModelList.forEach((element) {
      print(element);
    });
  }

  void getBuildObjectList(String directory, String name) {
    getTargetObjects(_sourceModelList, directory, name);
  }

  // search sourceModel list by directory and name

  int get sourceModelsCount => _sourceModelList.length;
}
