import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../../models/source_model.dart';
import '../../../utils/path/path.dart';
import '../../../utils/progress_bar/progress_bar.dart';

part 'miner.p.sort.dart';
part 'miner.p.include.dart';

class SourceMiner {
  static SourceMiner _instance;

  SourceMiner._internal() {
    _sourceModelList = List.empty(growable: true);
  }

  factory SourceMiner() {
    if (_instance == null) {
      _instance = SourceMiner._internal();
    }
    return _instance;
  }

  List<SourceModel> _sourceModelList;
  List<SourceModel> get sourceModels => _sourceModelList;
  File database;

  void initialize(String projectDirectory, String projectName) {
    String databasePath = pathjoin('data', 'db', projectName + '.json');
    this.database = File(databasePath);
    if (this.database.existsSync()) {
      _loadSourceModelList(databasePath);
    } else {
      this.database.createSync(recursive: true);

      Directory currentDirectory = Directory.current;
      Directory.current = pathjoin(projectDirectory, projectName);
      _$GetSourceWithDirectory(_instance, 'app');
      _$GetSourceWithDirectory(_instance, 'lib');
      _$GetIncludeFiles(_sourceModelList);
      Directory.current = currentDirectory;

      _saveSourceModelList();
    }
  }

  void _saveSourceModelList() {
    this.database.writeAsStringSync(
        jsonEncode(_sourceModelList.map((e) => e.toJson()).toList()));
  }

  void _loadSourceModelList(String path) {
    _sourceModelList = (jsonDecode(this.database.readAsStringSync()) as List)
        .map((e) => SourceModel.fromJson(e))
        .toList();
  }

  // has hashcode in _sourceModelList
  bool hasHashcode(int hashCode) {
    bool result = false;
    _sourceModelList.forEach((element) {
      if (element.hashCode == hashCode) {
        result = true;
      }
    });
    return result;
  }

  SourceModel getSourceModelByHashCode(int hashCode) {
    return _sourceModelList
        .firstWhere((element) => element.hashCode == hashCode);
  }

  // get source model by file directory and file name
  SourceModel getSourceModelByDirectoryAndName(String directory, String name) {
    int hashCode = directory.hashCode ^ basename(name, false).hashCode;
    return getSourceModelByHashCode(hashCode);
  }

  int get sourceModelsCount => _sourceModelList.length;
}
