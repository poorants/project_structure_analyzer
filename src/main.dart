import 'dart:io';

import 'managers/source_manager/source_manager.dart';
import 'utils/path/path.dart';

void usage() {
  print('Usage: dart main.dart <project> <target>');
  print('project :  The project name');
  print('target  :  simple file name or a file name with a path.');
  print("");
  print('example:');
  print('   - just file name');
  if (Platform.isWindows)
    print('       dart main.dart d:\\svn\\REL-4.1.0.1 PccKredApiAgent.h');
  else
    print('       dart main.dart /mnt/d/svn/REL-4.1.0.1 PccKredApiAgent.h');
  print('   - file name with a path');
  if (Platform.isWindows)
    print(
        '       dart main.dart d:\\svn\\REL-4.1.0.1 app\\cipher\\kred\\PccKredApiAgent.h');
  else
    print(
        '       dart main.dart /mnt/d/svn/REL-4.1.0.1 app/cipher/kred/PccKredApiAgent.h');
  print("");
}

void main(List<String> arguments) {
  if (arguments.length != 2) {
    usage();
    exit(1);
  }

  final project = convertPathSeparator(arguments[0]);
  final target = convertPathSeparator(arguments[1]);

  SourceManager manager = SourceManager();

  manager.initialize(project, target);
  manager.buildTree();
}
