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
import 'dart:typed_data';

import 'package:path/path.dart' as path;

/// Reads a file from the `resources/` directory of this Pub package root
/// directory.
///
/// The [name] is the entire file name, including extension.
///
/// Assumes the script is run from the `bin/` directory or another immediate
/// subdirectory of the package root directory.
Future<Uint8List> readResource(String name) {
  return File(path.join(_resourceDirectory.path, name)).readAsBytes();
}

final _resourceDirectory =
    Directory.fromUri(Platform.script.resolve('../resources/'));
