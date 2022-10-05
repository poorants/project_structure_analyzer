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

  void getSourceWithProject(String projectDirectory) {
    Directory runDirectory = Directory.current;
    Directory.current = projectDirectory;

    print(
        '- Obtain source code from the "app", "lib" directory within the "$projectDirectory".');
    getSourceByDirectory(_sourceModelList, 'app');
    getSourceByDirectory(_sourceModelList, 'lib');
    print('Done.');

    print('- Get included header file.');
    getIncludeFiles(_sourceModelList);
    print('Done.');
    Ascending(_sourceModelList);

    Directory.current = runDirectory;
  }

  void saveSourceModelList(String path) {
    File(path).writeAsStringSync(
        jsonEncode(_sourceModelList.map((e) => e.toJson()).toList()));
  }

  void loadSourceModelList(String path) {
    print('- Load file "$path".');
    _sourceModelList = (jsonDecode(File(path).readAsStringSync()) as List)
        .map((e) => SourceModel.fromJson(e))
        .toList();
    print('Done.');
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
