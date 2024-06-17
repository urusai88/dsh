import 'dart:io';

typedef SpawnFunction = ProcessResult Function(
  dynamic command, {
  String? cwd,
  Map<String, String>? environment,
});

ProcessResult spawn(
  dynamic command, {
  String? cwd,
  Map<String, String>? environment,
}) {
  final (executable, arguments) = switch (command) {
    final String executable => (executable, const <String>[]),
    final List arguments when arguments.isNotEmpty => (
        '${arguments.first}',
        arguments.skip(1).map((e) => '$e').toList(),
      ),
    _ => throw Exception('Invalid arguments $command'),
  };

  return Process.runSync(
    executable,
    arguments,
    workingDirectory: cwd,
    // runInShell: true,
    environment: environment,
  );
}

SpawnFunction spawnWithEnvironment(Map<String, String>? baseEnvironment) {
  return (dynamic command, {String? cwd, Map<String, String>? environment}) {
    final e = baseEnvironment != null || environment != null
        ? <String, String>{
            if (baseEnvironment != null) ...baseEnvironment,
            if (environment != null) ...environment,
          }
        : null;

    return spawn(command, cwd: cwd, environment: e);
  };
}
