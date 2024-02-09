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

/// Utilities for working with classes that can be converted to JSON.
library;

/// General interface that a class with a [toJson] method can implement.
///
/// Allows generalized helper functionality that works on different,
/// otherwise unrelated, classes.
abstract interface class JsonConvertible {
  /// Creates a JSON representation of this object.
  Object? toJson();
}

extension JsonConvertibleListToJsonList on Iterable<JsonConvertible> {
  /// Converts a seqeuence of objects to a list of their JSON representations.
  List<Object?> toJsonList() => [for (final element in this) element.toJson()];
}
