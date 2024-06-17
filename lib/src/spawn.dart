import 'dart:convert';
import 'dart:io';

typedef SpawnFunction = Future<void> Function(
  dynamic command, {
  String? cwd,
  Map<String, String>? environment,
  bool sync,
  bool log,
});

Future<void> spawn(
  dynamic command, {
  String? cwd,
  Map<String, String>? environment,
  bool sync = true,
  bool log = false,
}) async {
  final (executable, arguments) = switch (command) {
    final String executable => (executable, const <String>[]),
    final List arguments when arguments.isNotEmpty => (
        '${arguments.first}',
        arguments.skip(1).map((e) => '$e').toList(),
      ),
    _ => throw Exception('Invalid arguments $command'),
  };

  print(
    'spawn \'$executable ${arguments.join(' ')}\' ${cwd != null ? 'cwd: \'$cwd\'' : ''}',
  );

  if (sync) {
    final result = Process.runSync(
      executable,
      arguments,
      workingDirectory: cwd,
      environment: environment,
    );
    if (result.stderr case final String s when s.isNotEmpty) {
      print(s);
    }
    if (result.stdout case final String s when s.isNotEmpty && log) {
      print(s);
    }
  } else {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: cwd,
      environment: environment,
    );

    process.stderr.transform(utf8.decoder).listen(print);
    if (log) {
      process.stdout.transform(utf8.decoder).listen(print);
    }
    await process.exitCode;
  }
}

Future<void> spawnSplit(
  String command, {
  String? cwd,
  Map<String, String>? environment,
  bool sync = true,
  bool log = false,
}) =>
    spawn(
      command.split(' '),
      cwd: cwd,
      environment: environment,
      sync: sync,
      log: log,
    );

SpawnFunction spawnWithEnvironment(Map<String, String>? baseEnvironment) {
  return (
    dynamic command, {
    String? cwd,
    Map<String, String>? environment,
    bool sync = true,
    bool log = false,
  }) {
    final e = baseEnvironment != null || environment != null
        ? <String, String>{
            if (baseEnvironment != null) ...baseEnvironment,
            if (environment != null) ...environment,
          }
        : null;

    return spawn(command, cwd: cwd, environment: e, sync: sync, log: log);
  };
}
