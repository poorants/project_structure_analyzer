// The type of name is a string. The name is the filename except for the extentionList.
// The type of path is a string. The path to the file.
// The extentionList is a string list type. The value has h or cpp.
// the type of includeList is a IncludeModel list.

class SourceModel {
  int hashCode;
  String name;
  String directory;
  List<String> extentionList;
  List<int> includedHashCodeList;

  SourceModel({
    hashCode,
    required this.name,
    required this.directory,
    extentionList,
    includedHashCodeList,
  })  : this.hashCode = hashCode ?? directory.hashCode ^ name.hashCode,
        this.extentionList = extentionList ?? List.empty(growable: true),
        this.includedHashCodeList =
            includedHashCodeList ?? List.empty(growable: true);

  // add extentionList
  void addextention(String extentionList) {
    this.extentionList.add(extentionList);
  }

  // add includedHashCodeList
  void addincludedHashCodeList(int includedHashCodeList) {
    this.includedHashCodeList.add(includedHashCodeList);
  }

  // is header
  bool hasHeader() {
    return this.extentionList.contains('h');
  }

  // is source
  bool hasSource() {
    return this.extentionList.contains('cpp') ||
        this.extentionList.contains('c');
  }

  void merge(SourceModel source) {
    // Remove duplicate values after applying addAll to the extensionList
    for (var extention in source.extentionList) {
      if (!this.extentionList.contains(extention)) {
        this.extentionList.add(extention);
      }
    }

    // Remove duplicate values after applying addAll to the includeList
    for (var include in source.includedHashCodeList) {
      if (!this.includedHashCodeList.contains(include)) {
        this.includedHashCodeList.add(include);
      }
    }
  }

  List<String> getPathList() {
    List<String> pathList = List.empty(growable: true);
    for (var extention in this.extentionList) {
      pathList.add(this.directory + '/' + this.name + '.' + extention);
    }
    return pathList;
  }

  // get include list
  List<int> getIncludeHashCodeList() {
    List<int> includeHashColdeList = List.empty(growable: true);
    for (var includedHashCode in this.includedHashCodeList) {
      includeHashColdeList.add(includedHashCode);
    }
    return includeHashColdeList;
  }

  // to json sourceModel
  Map<String, dynamic> toJson() => {
        'hashCode': hashCode,
        'name': name,
        'directory': directory,
        'extentionList': extentionList,
        'includedHashCodeList': includedHashCodeList,
      };

  // from json sourceModel
  factory SourceModel.fromJson(Map<String, dynamic> json) => SourceModel(
        hashCode: json['hashCode'],
        name: json['name'],
        directory: json['directory'],
        extentionList: List<String>.from(json['extentionList']),
        includedHashCodeList: List<int>.from(json['includedHashCodeList']),
      );

  // toString()
  @override
  String toString() {
    return 'SourceModel{hashCode: $hashCode, name: $name, directory: $directory, extentionList: $extentionList, includedHashCodeList: $includedHashCodeList}';
  }
}
