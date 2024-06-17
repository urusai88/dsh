import 'package:scripts_builder/dsh.dart';

void main(List<String> args) {
  final path = args.first;
  print('building scripts in $path');
  final result = buildScripts(path);
  print('built ${result.length} scripts');
  for (final entry in result.entries) {
    print('${entry.key}: ${entry.value}');
  }
}
