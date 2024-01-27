import 'package:google_generative_ai/src/client.dart';
import 'package:collection/collection.dart';

const Equality<Map<String, Object?>> _mapEquality =
    MapEquality(values: DeepCollectionEquality());

final class StubClient implements ApiClient {
  final _requests =
      EqualityMap<Map<String, Object?>, Map<String, Object?>>(_mapEquality);
  final _streamRequests =
      EqualityMap<Map<String, Object?>, Iterable<Map<String, Object?>>>(
          _mapEquality);

  void stub(Uri uri, Map<String, Object?> body, Map<String, Object?> result) =>
      _requests[{'_hack_uri': uri, ...body}] = result;
  void stubStream(Uri uri, Map<String, Object?> body,
          Iterable<Map<String, Object?>> result) =>
      _streamRequests[{'_hack_uri': uri, ...body}] = result;

  @override
  Future<Map<String, Object?>> makeRequest(
          Uri uri, Map<String, Object?> body) =>
      Future.value(_requests.remove({'_hack_uri': uri, ...body}) ??
          (throw StateError(
              'Missing stub for request to $uri with body $body')));

  @override
  Stream<Map<String, Object?>> streamRequest(
          Uri uri, Map<String, Object?> body) =>
      Stream.fromIterable(_streamRequests.remove({'_hack_uri': uri, ...body}) ??
          (throw StateError(
              'Missing stub for request to $uri with body $body')));
}
