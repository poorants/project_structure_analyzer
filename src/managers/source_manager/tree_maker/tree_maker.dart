enum Nodetype { ROOT, INNER, LEAF, OVERLAP }

class TreeNodeModel {
  int level;
  int hashCode;
  Nodetype type;
  List<TreeNodeModel> childTreeNodeList;

  TreeNodeModel({
    this.level = 0,
    this.hashCode = 0,
    this.type = Nodetype.ROOT,
  }) : childTreeNodeList = List.empty(growable: true);

  @override
  String toString() {
    return 'TreeNodeModel{level: $level, hashCode: $hashCode, type: $type, childTreeNodeList: $childTreeNodeList}';
  }

  // toJson() for json encode
  Map<String, dynamic> toJson() => {
        'level': level,
        'hashCode': hashCode,
        'type': type.toString(),
        'childTreeNodeList': childTreeNodeList,
      };
}

class TreeMaker {
  static TreeMaker _instance;

  TreeMaker._internal() {
    _treeNodeList = List.empty(growable: true);
  }

  factory TreeMaker() {
    if (_instance == null) {
      _instance = TreeMaker._internal();
    }
    return _instance;
  }

  List<TreeNodeModel> _treeNodeList;

  void addRootNode(int hashCode) {
    _treeNodeList
        .add(TreeNodeModel(level: 0, hashCode: hashCode, type: Nodetype.ROOT));
  }

  // get root node
  TreeNodeModel getRootNode() {
    return _treeNodeList.first;
  }

  // print tree
  void printTree() {
    TreeNodeModel rootNode = getRootNode();
    rootNode.childTreeNodeList.forEach((element) {
      element.toJson();
    });
  }
}
