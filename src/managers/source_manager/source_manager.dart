import 'dart:io';

import 'miner/miner.dart';
import 'tree_maker/tree_maker.dart';
import '../../utils/path/path.dart';
import '../../utils/file/file.dart';
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

  void initialize(String project, String target) {
    this.info.getInfomations(project, target);
    miner.initialize(info.projectDirectory, info.projectName);
  }

  void buildTree() {
    int rootHashCode = info.fileDirectory.hashCode ^ info.fileName.hashCode;
    treeMaker.addRootNode(rootHashCode);

    TreeNodeModel rootNode = treeMaker.getRootNode();
    _history.add(rootNode);
    _buildTree(rootNode);

    RandomAccessFile treeFile = replaceRemoteFile(
        pathjoin('data', 'result', info.fileName, 'tree.dat'));
    _gridTree(rootNode, treeFile);

    RandomAccessFile lineFile = replaceRemoteFile(
        pathjoin('data', 'result', info.fileName, 'line.dat'));
    _gridLine(rootNode, List.empty(growable: true), lineFile);

    RandomAccessFile objectFile = replaceRemoteFile(
        pathjoin('data', 'result', info.fileName, 'objects.dat'));
    _getObjectNodes(objectFile);
  }

  void _gridTree(TreeNodeModel node, RandomAccessFile resultFile) {
    // stopwatch

    SourceModel source = miner.getSourceModelByHashCode(node.hashCode);

    for (int i = 0; i < node.level; i++) {
      resultFile.writeStringSync('  |');
    }
    resultFile.writeStringSync(
        '-${source.directory}${Platform.pathSeparator}${source.name}.h');

    if (node.type == Nodetype.ROOT) {
      resultFile.writeStringSync(' (ROOT)\n');
    } else if (node.type == Nodetype.INNER) {
      resultFile.writeStringSync('\n');
    } else if (node.type == Nodetype.LEAF) {
      resultFile.writeStringSync(' (LEAF)\n');
    } else if (node.type == Nodetype.OVERLAP) {
      resultFile.writeStringSync(' (OVERLAP)\n');
    }

    node.childTreeNodeList.forEach((element) {
      _gridTree(element, resultFile);
    });
  }

  void _gridLine(
      TreeNodeModel node, List<String> buffer, RandomAccessFile resultFile) {
    SourceModel source = miner.getSourceModelByHashCode(node.hashCode);
    buffer.add('${source.directory}${Platform.pathSeparator}${source.name}.h');
    if (node.type == Nodetype.LEAF) {
      resultFile.writeStringSync('${buffer.join(' > ')} (LEAF)\n');
    } else if (node.type == Nodetype.OVERLAP) {
      resultFile.writeStringSync('${buffer.join(' > ')} (OVERLAP)\n');
    }

    node.childTreeNodeList.forEach((element) {
      _gridLine(element, buffer, resultFile);
    });
    buffer.removeLast();
  }

  bool _buildTree(TreeNodeModel node) {
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
        if (!_buildTree(childnode)) {
          childnode.type = Nodetype.LEAF;
        }
      }

      node.childTreeNodeList.add(childnode);
    }

    return true;
  }

  void _getObjectNodes(RandomAccessFile resultFile) {
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
    objectList.forEach((element) {
      resultFile.writeStringSync(element + '\n');
    });
  }
}
