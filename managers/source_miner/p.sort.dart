part of 'source_miner.dart';

// In ascending order, the sourceModel list. Use directory and name.
List<SourceModel> Ascending(List<SourceModel> sources) {
  sources.sort((a, b) {
    if (a.directory == b.directory) {
      return a.name.compareTo(b.name);
    } else {
      return a.directory.compareTo(b.directory);
    }
  });
  return sources;
}

// In decending order, the sourceModel list. Use directory and name.
List<SourceModel> Descending(List<SourceModel> sources) {
  sources.sort((a, b) {
    if (a.directory == b.directory) {
      return b.name.compareTo(a.name);
    } else {
      return b.directory.compareTo(a.directory);
    }
  });
  return sources;
}
