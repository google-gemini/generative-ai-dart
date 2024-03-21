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

import 'content.dart';

/// Tool details that the model may use to generate response.
///
/// A `Tool` is a piece of code that enables the system to interact with
/// external systems to perform an action, or set of actions, outside of
/// knowledge and scope of the model.
final class Tool {
  /// A list of `FunctionDeclarations` available to the model that can be used
  /// for function calling.
  ///
  /// The model or system does not execute the function. Instead the defined
  /// function may be returned as a [FunctionCall] with arguments to the client
  /// side for execution. The next conversation turn may contain a
  /// [FunctionResponse]
  /// with the role "function" generation context for the next model turn.
  final List<FunctionDeclaration>? functionDeclarations;

  Tool({this.functionDeclarations});

  Map<String, Object> toJson() => {
        if (functionDeclarations case final functionDeclarations?)
          'functionDeclarations':
              functionDeclarations.map((f) => f.toJson()).toList(),
      };
}

/// Structured representation of a function declaration as defined by the
/// [OpenAPI 3.03 specification](https://spec.openapis.org/oas/v3.0.3).
///
/// Included in this declaration are the function name and parameters. This
/// FunctionDeclaration is a representation of a block of code that can be used
/// as a `Tool` by the model and executed by the client.
final class FunctionDeclaration {
  /// The name of the function.
  ///
  /// Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
  /// length of 63.
  final String name;

  /// A brief description of the function.
  final String description;

  final Schema? parameters;

  FunctionDeclaration(this.name, this.description, this.parameters);

  Map<String, Object?> toJson() => {
        'name': name,
        'description': description,
        if (parameters case final parameters?) 'parameters': parameters.toJson()
      };
}

/// The definition of an input or output data types.
///
/// These types can be objects, but also primitives and arrays.
/// Represents a select subset of an
/// [OpenAPI 3.0 schema object](https://spec.openapis.org/oas/v3.0.3#schema).
final class Schema {
  /// The type of this value.
  SchemaType type;

  /// The format of the data.
  ///
  /// This is used only for primitive datatypes.
  ///
  /// Supported formats:
  ///  for [SchemaType.number] type: float, double
  ///  for [SchemaType.integer] type: int32, int64
  ///  for [SchemaType.string] type: enum. See [enumValues]
  String? format;

  /// A brief description of the parameter.
  ///
  /// This could contain examples of use.
  /// Parameter description may be formatted as Markdown.
  String? description;

  /// Whether the value mey be null.
  bool? nullable;

  /// Possible values if this is a [SchemaType.string] with an enum format.
  List<String>? enumValues;

  /// Schema for the elements if this is a [SchemaType.array].
  Schema? items;

  /// Properties of this type if this is a [SchemaType.object].
  Map<String, Schema>? properties;

  /// The keys from [properties] for properties that are required if this is a
  /// [SchemaType.object].
  List<String>? requiredProperties;

  // TODO: Add named constructors for the types?
  Schema(
    this.type, {
    this.format,
    this.description,
    this.nullable,
    this.enumValues,
    this.items,
    this.properties,
    this.requiredProperties,
  });

  Map<String, Object> toJson() => {
        'type': type.toJson(),
        if (format case final format?) 'format': format,
        if (description case final description?) 'description': description,
        if (nullable case final nullable?) 'nullable': nullable,
        if (enumValues case final enumValues?) 'enum': enumValues,
        if (items case final items?) 'items': items.toJson(),
        if (properties case final properties?)
          'properties': {
            for (final MapEntry(:key, :value) in properties.entries)
              key: value.toJson()
          },
        if (requiredProperties case final requiredProperties?)
          'required': requiredProperties
      };
}

/// The value type of a [Schema].
enum SchemaType {
  string,
  number,
  integer,
  boolean,
  array,
  object;

  String toJson() => switch (this) {
        string => 'STRING',
        number => 'NUMBER',
        integer => 'INTEGER',
        boolean => 'BOOLEAN',
        array => 'ARRAY',
        object => 'OBJECT',
      };
}
