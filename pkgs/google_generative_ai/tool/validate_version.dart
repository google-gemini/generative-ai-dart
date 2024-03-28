// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:google_generative_ai/src/version.dart';
import 'package:yaml/yaml.dart' as yaml;

void main(List<String> args) {
  final pubspecVersion = _parsePubspecVersion();
  final sourceCodeVersion = packageVersion;

  if (pubspecVersion == sourceCodeVersion) {
    stdout.writeln(
        'pubspec.yaml version and lib/src/version.dart version agree.');
  } else {
    stderr.writeln(
        "pubspec.yaml version and lib/src/version.dart version don't agree.");
    stderr.writeln();
    stderr.writeln('pubspec.yaml: $pubspecVersion');
    stderr.writeln('lib/src/version.dart: $sourceCodeVersion');
    stderr.writeln();
    stderr.writeln('When updating the pubspec version, please also update '
        'the version string in lib/src/version.dart.');
    exit(1);
  }
}

String _parsePubspecVersion() {
  final pubspec = File('pubspec.yaml');
  final contents = yaml.loadYaml(pubspec.readAsStringSync());
  return (contents as Map)['version'] as String;
}
