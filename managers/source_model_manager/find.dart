part of 'source_model_manager.dart';

// get sourceModel with hashCodes
SourceModel? _getSourceModelWithHashCodes(
    List<SourceModel> sources, int hashCode) {
  for (var source in sources) {
    if (source.hashCode == hashCode) {
      return source;
    }
  }
  return null;
}

// search sourceModel list by directory and name
void getTargetObjects(
    List<SourceModel> sourceList, String directory, String name) {
  NodeManager nodeManager = NodeManager();

  int loopCount = 0;
  int parentHashCode = 0;
  nodeManager.addTargetNodeList(
      NodeModel(0, directory.hashCode ^ name.hashCode, parentHashCode));
  while (nodeManager.targetNodeList.length != 0) {
    loopCount++; // increase depth

    for (NodeModel targetNode in nodeManager.targetNodeList) {
      if (targetNode.hashCode == 629261652)
        print('targetNode: ${targetNode.toString()}');
      if (nodeManager.hasDoneNode(targetNode.hashCode)) {
        // {file}.h skip declared in {file}.cpp
        if (targetNode.hashCode == targetNode.parentHashCode) continue;

        // '.h' file declared in file, but skip if already checked.
        targetNode.status = 'overlapped';
        nodeManager.addDoneNodeList(targetNode);
        continue;
      }

      nodeManager.addDoneNodeList(targetNode);
      SourceModel? source =
          _getSourceModelWithHashCodes(sourceList, targetNode.hashCode);
      if (source != null) {
        for (var includedHashCode in source.getIncludeHashCodeList()) {
          nodeManager.addNextNodeList(
              NodeModel(loopCount, includedHashCode, targetNode.hashCode));
        }
      }
    }

    nodeManager.clearTargetNodeList();
    nodeManager.addTargetNodeListList(nodeManager.nextNodeList);
    nodeManager.clearNextNodeList();
  }

  drawNodeTree(nodeManager, sourceList, loopCount);

  List<SourceModel> doneSourceModelList = List.empty(growable: true);
  for (NodeModel node in nodeManager.doneNodeList) {
    if (node.status.isNotEmpty) continue;
    SourceModel? source =
        _getSourceModelWithHashCodes(sourceList, node.hashCode);
    if (source != null) doneSourceModelList.add(source);
  }
  // List<SourceModel> doneSourceModelList = List.empty(growable: true);
  // for (NodeModel doneNode in nodeManager.doneNodeList) {
  //   SourceModel? source =
  //       _getSourceModelWithHashCodes(sourceList, doneNode.hashCode);
  //   if (source != null) doneSourceModelList.add(source);
  // }

  Descending(doneSourceModelList);

  List<String> justHeaderList = List.empty(growable: true);
  List<String> hasObjectList = List.empty(growable: true);

  for (SourceModel source in doneSourceModelList) {
    if (source.hasSource()) {
      hasObjectList.add("${source.directory}/${source.name}.\$(OBJEXT)");
      // print("${source.directory}/${source.name}.\$(OBJEXT)");
    } else {
      justHeaderList.add("${source.directory}/${source.name}.h");
      // print("${source.directory}/${source.name}.h");
    }
  }

  print("");
  print("justHeaderList = ${justHeaderList.length}");
  for (var element in justHeaderList) {
    print(element);
  }
  print("");
  print("hasObjectList = ${hasObjectList.length}");
  for (var element in hasObjectList) {
    print(element);
  }
}

// 재귀 출력 함수 nodeManager를 이용한다.
// depth를 이용하여 출력한다.
int _grid(NodeManager nodeManager, List<SourceModel> sourceList,
    List<String> dump, int parentHashCode, int depth, int maximumDepth) {
  List<NodeModel> depthNodeList =
      nodeManager.getDoneNodeListByDepth(depth, parentHashCode);
  for (NodeModel node in depthNodeList) {
    SourceModel? source =
        _getSourceModelWithHashCodes(sourceList, node.hashCode);
    if (source == null)
      print("source is null :: ${node.hashCode}");
    else
      dump.add(source.directory + "/" + source.name + ".h");
    int rst = _grid(
        nodeManager, sourceList, dump, node.hashCode, depth + 1, maximumDepth);
    if (rst == 0) {
      if (node.status.isEmpty)
        print(dump.join(' > '));
      else
        print(dump.join(' > ') + ' (${node.status})');
    }
    dump.removeLast();
  }

  return depthNodeList.length;
}

void drawNodeTree(
    NodeManager nodeManager, List<SourceModel> sourceList, int maximumDepth) {
  List<String> dumpNodeTree = List.empty(growable: true);
  _grid(nodeManager, sourceList, dumpNodeTree, 0, 0, maximumDepth);
}

// treeModel class.
// hashCode is int
// parentHashCode is int
class NodeModel {
  int depth;
  int hashCode;
  int parentHashCode;
  String status;

  NodeModel(this.depth, this.hashCode, this.parentHashCode, {this.status = ''});

  // toString
  @override
  String toString() {
    return 'NodeModel{depth: $depth, hashCode: $hashCode, parentHashCode: $parentHashCode, status: $status}';
  }
}

class NodeManager {
  List<NodeModel> targetNodeList = List.empty(growable: true);
  List<NodeModel> nextNodeList = List.empty(growable: true);
  List<NodeModel> doneNodeList = List.empty(growable: true);

  // Check if there is a hash code among hash codes in the doneNodeList.
  bool hasDoneNode(int hashCode) {
    for (NodeModel node in doneNodeList) {
      if (node.hashCode == hashCode) return true;
    }
    return false;
  }

  // add targetNodeList
  void addTargetNodeList(NodeModel node) {
    targetNodeList.add(node);
  }

  void addDoneNodeList(NodeModel node) {
    doneNodeList.add(node);
  }

  void addNextNodeList(NodeModel node) {
    nextNodeList.add(node);
  }

  void clearTargetNodeList() {
    targetNodeList.clear();
  }

  void clearNextNodeList() {
    nextNodeList.clear();
  }

  addTargetNodeListList(List<NodeModel> nodeList) {
    targetNodeList.addAll(nodeList);
  }

  // get depth list
  List<NodeModel> getDoneNodeListByDepth(int depth, int parentHashCode) {
    List<NodeModel> doneNodeList = List.empty(growable: true);
    for (NodeModel node in this.doneNodeList) {
      if (node.depth == depth && node.parentHashCode == parentHashCode)
        doneNodeList.add(node);
    }
    return doneNodeList;
  }
}
