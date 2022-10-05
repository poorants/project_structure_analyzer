import 'dart:io';

import 'miner/miner.dart';
import 'tree_maker/tree_maker.dart';
import '../../utils/path/path.dart';
import '../../models/source_model.dart';

part 'source_manager.p.information.dart';

class SourceManager {
  static SourceManager _instance;
  static SourceManager get instance =>
      _instance ??= new SourceManager._internal();
  SourceManager._internal();

  Infomations info = Infomations();
  SourceMiner miner;
  TreeMaker treeMaker;
  String _databasePath;
  // List<int> _history;
  List<TreeNodeModel> _history;

  SourceManager() {
    miner = SourceMiner();
    treeMaker = TreeMaker();
    _history = List.empty(growable: true);
  }

  // has hashcode in _history List
  bool hasHashcodeInHistory(int hashCode) {
    bool result = false;
    _history.forEach((element) {
      if (element.hashCode == hashCode) {
        result = true;
      }
    });
    return result;
  }

  void _setDatabase() {
    if (!File(this._databasePath).existsSync()) {
      miner.getSourceWithProject(this.info.projectPath);
      miner.saveSourceModelList(this._databasePath);
    } else {
      miner.loadSourceModelList(this._databasePath);
    }
  }

  void initialize(String project, String target) {
    print('# Initialize.');
    this.info.getInfomations(project, target);
    this._databasePath = pathjoin(
        'datas${Platform.pathSeparator}${info.projectName}.${Platform.operatingSystem}.json');
    _setDatabase();
  }

  // void buildTree() {
  //   miner.getBuildObjectList(
  //     this.info.fileDirectory,
  //     this.info.fileName,
  //   );
  // }

  void buildTree() {
    int rootHashCode = info.fileDirectory.hashCode ^ info.fileName.hashCode;
    treeMaker.addRootNode(rootHashCode);

    TreeNodeModel rootNode = treeMaker.getRootNode();
    _test(rootNode);
    // File('sample.json').writeAsStringSync(jsonEncode(rootNode.toJson()));
    print('');
    print('[GRID TREE]');
    _gridTree(rootNode);
    print('');
    print('[GRID LINE]');
    _gridLine(rootNode, List.empty(growable: true));
    _getObjectNodes();
  }

  void _gridTree(TreeNodeModel node) {
    SourceModel source = miner.getSourceModelByHashCode(node.hashCode);
    for (int i = 0; i < node.level; i++) {
      stdout.write('  |');
    }
    stdout
        .write('-${source.directory}${Platform.pathSeparator}${source.name}.h');
    if (node.type == Nodetype.ROOT) {
      print(' (ROOT)');
    } else if (node.type == Nodetype.INNER) {
      print('');
    } else if (node.type == Nodetype.LEAF) {
      print(' (LEAF)');
    } else if (node.type == Nodetype.OVERLAP) {
      print(' (OVERLAP)');
    }

    node.childTreeNodeList.forEach((element) {
      _gridTree(element);
    });
  }

  void _gridLine(TreeNodeModel node, List<String> buffer) {
    SourceModel source = miner.getSourceModelByHashCode(node.hashCode);
    buffer.add('${source.directory}${Platform.pathSeparator}${source.name}.h');
    if (node.type == Nodetype.LEAF) {
      print('${buffer.join(' > ')} (LEAF)');
    } else if (node.type == Nodetype.OVERLAP) {
      print('${buffer.join(' > ')} (OVERLAP)');
    }

    node.childTreeNodeList.forEach((element) {
      _gridLine(element, buffer);
    });
    buffer.removeLast();
  }

  bool _test(TreeNodeModel node) {
    if (node.level > 50) exit(1);

    SourceModel source = miner.getSourceModelByHashCode(node.hashCode);
    if (source == null || source.hasInclude() == false) {
      return false;
    }

    for (int includeHashcode in source.includedHashCodeList) {
      if (node.hashCode == includeHashcode) continue;
      TreeNodeModel childnode = TreeNodeModel(
          level: node.level + 1,
          hashCode: includeHashcode,
          type: Nodetype.INNER);

      if (hasHashcodeInHistory(childnode.hashCode)) {
        childnode.type = Nodetype.OVERLAP;
      } else {
        _history.add(childnode);
        if (!_test(childnode)) {
          childnode.type = Nodetype.LEAF;
        }
        // _history.add(childnode.hashCode);
        // _history.add(childnode);
      }

      node.childTreeNodeList.add(childnode);
    }

    return true;
  }

  void _getObjectNodes() {
    List<String> headerList = List.empty(growable: true);
    List<String> objectList = List.empty(growable: true);
    for (TreeNodeModel element in this._history) {
      SourceModel source = miner.getSourceModelByHashCode(element.hashCode);
      if (source.hasSource()) {
        objectList.add(source.directory +
            Platform.pathSeparator +
            source.name +
            '.\$(OBJEXT)');
      } else {
        headerList.add(
            source.directory + Platform.pathSeparator + source.name + '.h');
      }
    }
    // header list sort desc
    headerList.sort((a, b) => b.compareTo(a));
    objectList.sort((a, b) => b.compareTo(a));
    // headerList.forEach((element) {
    //   print(element);
    // });

    print('');
    print('[OBJECT LIST]');
    objectList.forEach((element) {
      print(element);
    });
  }
}
