import 'dart:convert';

import 'package:google_generative_ai/src/client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'utils/matchers.dart';

void main() {
  group('HttpApiClient', () {
    test('can make unary request', () async {
      final url = Uri.parse('https://someurl.com');
      final body = {'some': 'body'};
      final apiKey = 'apiKey';
      final expectedResponse = {'result': 'OK'};
      await http.runWithClient(() async {
        final client = HttpApiClient(apiKey: apiKey);
        final response = await client.makeRequest(url, body);
        expect(response, expectedResponse);
      },
          () => MockClient((request) async {
                expect(
                    request,
                    matchesRequest(http.Request('POST', url)
                      ..headers.addAll({
                        'x-goog-api-key': apiKey,
                        'x-goog-api-client': clientName,
                        'Content-Type': 'application/json'
                      })
                      ..bodyBytes = utf8.encode(jsonEncode(body))));
                return http.Response.bytes(
                    utf8.encode(jsonEncode(expectedResponse)), 200);
              }));
    });

    test('can make streaming request', () async {
      final url = Uri.parse('https://someurl.com');
      final streamingUrl = Uri.parse('https://someurl.com?alt=sse');
      final body = {'some': 'body'};
      final apiKey = 'apiKey';
      final expectedResponses = [
        {'first': 'OK'},
        {'second': 'OK'}
      ];
      await http.runWithClient(() async {
        final client = HttpApiClient(apiKey: apiKey);
        final response = client.streamRequest(url, body);
        await expectLater(
            response, emitsInOrder([...expectedResponses, emitsDone]));
      },
          () => MockClient.streaming((request, requestStream) async {
                expect(
                    request,
                    matchesBaseRequest(http.Request('POST', streamingUrl)
                      ..headers.addAll({
                        'x-goog-api-key': apiKey,
                        'x-goog-api-client': clientName,
                        'Content-Type': 'application/json'
                      })));
                expect(requestStream,
                    emitsInOrder([utf8.encode(jsonEncode(body)), emitsDone]));
                return http.StreamedResponse(
                    Stream.fromIterable(expectedResponses)
                        .map((r) => utf8.encode('data: ${jsonEncode(r)}\n')),
                    200);
              }));
    });
  });
}
