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

import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'client.dart';
import 'content.dart';
import 'http_multipart_related.dart';

const _apiVersion = 'v1beta';
final _fileBaseUri = Uri.https('generativelanguage.googleapis.com');

/// A client for uploading files to the generative AI model storage.
///
/// This service uses the `v1beta` API version.
final class FileService {
  final ApiClient _client;

  factory FileService({
    required String apiKey,
    http.Client? httpClient,
  }) =>
      FileService._withClient(
          client: HttpApiClient(apiKey: apiKey, httpClient: httpClient));

  FileService._withClient({
    required ApiClient client,
  }) : _client = client;

  Future<CreateFileResponse> createFile(String mimeType, Uint8List bytes,
      {String? name, String? displayName}) async {
    if (name != null && name.isNotEmpty && !name.contains('/')) {
      name = 'files/$name';
    }
    final uri = _fileBaseUri.replace(pathSegments: [
      'upload',
      _apiVersion,
      'files',
    ], queryParameters: {
      'uploadType': 'multipart'
    });
    final (boundary, requestBytes) = formatMultipartRelated(
        mimeType: mimeType,
        fileBytes: bytes,
        name: name,
        displayName: displayName);
    // final httpClient = http.Client();
    // http.MultipartRequest('POST', uri)..files.add(http.MultipartFile());
    final response = await _client.postBytes(
        uri,
        'multipart/related; boundary="$boundary"; type=application/json',
        requestBytes,
        {'X-Goog-Upload-Protocol': 'multipart'});
    return CreateFileResponse._parse(response);
  }

  Future<ListFilesResponse> listFiles(
      {int? pageSize, String? pageToken}) async {
    final uri = _fileBaseUri.replace(pathSegments: [
      _apiVersion,
      'files',
    ], queryParameters: {
      if (pageSize != null) 'pageSize': '$pageSize',
      if (pageToken != null) 'pageToken': pageToken
    });
    final response = await _client.fetch(uri);
    return ListFilesResponse._parse(response);
  }

  Future<ServerFile?> fetchFile(String name) {
    throw UnimplementedError();
  }

  Future<ServerFile?> deleteFile(String name) {
    throw UnimplementedError();
  }
}

final class CreateFileResponse {
  static CreateFileResponse _parse(Object jsonObject) {
    return switch (jsonObject) {
      {'file': final Object fileData} =>
        CreateFileResponse(ServerFile._parse(fileData)),
      _ =>
        throw FormatException('Unhandled CreateFileREsponse format', jsonObject)
    };
  }

  final ServerFile file;
  CreateFileResponse(this.file);
}

final class ListFilesResponse {
  static ListFilesResponse _parse(Object jsonObject) {
    return switch (jsonObject) {
      {'files': final List<Object?> files} => ListFilesResponse(
          files.cast<Object>().map(ServerFile._parse).toList(),
          (jsonObject as Map)['nextPageToken'] as String?),
      _ =>
        throw FormatException('Unhandled CreateFileREsponse format', jsonObject)
    };
  }

  final List<ServerFile> files;
  final String? nextPageToken;
  ListFilesResponse(this.files, this.nextPageToken);
}

final class ServerFile {
  static ServerFile _parse(Object jsonObject) {
    return switch (jsonObject) {
      {
        'name': final String name,
        'mimeType': final String mimeType,
        'sizeBytes': final String sizeBytes,
        'createTime': final String createTime,
        'updateTime': final String updateTime,
        'expirationTime': final String expirationTime,
        'sha256Hash': final String sha256Hash,
        'uri': final String uri,
      } =>
        ServerFile(
          name: name,
          displayName: jsonObject['displayName'] as String?,
          mimeType: mimeType,
          sizeBytes: int.parse(sizeBytes),
          createTime: DateTime.parse(createTime),
          updateTime: DateTime.parse(updateTime),
          expirationTime: DateTime.parse(expirationTime),
          sha256Hash: sha256Hash,
          uri: Uri.parse(uri),
        ),
      _ => throw FormatException('Unhandled File format', jsonObject)
    };
  }

  final String name;
  final String? displayName;
  final String mimeType;
  final int sizeBytes;
  final DateTime createTime;
  final DateTime updateTime;
  final DateTime expirationTime;
  final String sha256Hash;
  final Uri uri;
  ServerFile({
    required this.name,
    this.displayName,
    required this.mimeType,
    required this.sizeBytes,
    required this.createTime,
    required this.updateTime,
    required this.expirationTime,
    required this.sha256Hash,
    required this.uri,
  });
}

extension AsPart on ServerFile {
  FilePart asPart() => FilePart(uri);
}

FileService createFileServiceWithClient({required ApiClient client}) =>
    FileService._withClient(client: client);
