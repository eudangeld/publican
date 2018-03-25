import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;

class AddCommand extends Command {
  final File pubspec;
  final String name = 'add';
  final String description = 'Adds a dependency to pubspec file';

  AddCommand(this.pubspec) {
    argParser
      ..addFlag('dev', abbr: 'd', help: 'Installs as dev_dependencies.')
      ..addFlag('dry-run',
          help: 'Outputs the final pubspec without writing it.');
  }

  Future run() async {
    if (!await pubspec.exists()) {
      return print('No pubspec file found.');
    }

    String contents = pubspec.readAsStringSync().trim();

    final String key =
        argResults['dev'] ? 'dev_dependencies:' : 'dependencies:';

    if (!contents.contains(key)) {
      contents = '$contents\n\n$key';
    }

    List<String> deps = (argResults['dev']
            ? argResults.arguments.sublist(1)
            : argResults.arguments)
        .where((String dep) => !dep.startsWith('-') && !contents.contains(dep));

    deps = await Future.wait(deps.map((String dep) => _resolveDep(dep)));

    contents = deps.fold(
        contents,
        (String contents, String dep) =>
            contents.replaceFirst(key, '$key\n  $dep'));

    if (argResults['dry-run']) {
      print(contents);
    } else {
      pubspec.writeAsString(contents);
    }
  }

  Future<String> _resolveDep(String dep) async {
    if (dep.contains('@')) {
      final List<String> parts = dep.split('@');
      return '${parts[0]}: ${parts[1]}';
    }

    final http.Client client = new http.Client();
    final http.Response response =
        await client.get('https://pub.dartlang.org/packages/$dep.json');
    client.close();

    if (response.statusCode == HttpStatus.NOT_FOUND) {
      print('Sorry, [$dep] not found on Pub.');
      exit(64);
    }

    final Map<String, dynamic> data = JSON.decode(response.body);
    final List<String> versions = data['versions'];
    final String latestVer = versions.last;

    return '$dep: ^$latestVer';
  }
}