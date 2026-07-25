import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:neptune_app/core/discovery/peer_discovery_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late PeerDiscoveryService service;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    service = PeerDiscoveryService(mockClient, 'http://localhost:4000');
  });

  tearDown(() {
    service.dispose();
  });

  group('announceLan', () {
    test('sends PUT to correct endpoint with auth header and body', () async {
      when(
        () => mockClient.put(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('{}', 200));

      await service.announceLan(ip: '192.168.1.10', port: 9000, token: 'tok123');

      final captured = verify(
        () => mockClient.put(
          captureAny(),
          headers: captureAny(named: 'headers'),
          body: captureAny(named: 'body'),
        ),
      ).captured;

      expect(
        (captured[0] as Uri).toString(),
        'http://localhost:4000/api/v1/peers/me/hints',
      );
      expect((captured[1] as Map<String, String>)['Authorization'], 'Bearer tok123');
      expect((captured[1] as Map<String, String>)['Content-Type'], 'application/json');

      final body = jsonDecode(captured[2] as String) as Map<String, dynamic>;
      expect(body['ip'], '192.168.1.10');
      expect(body['port'], 9000);
      expect((body['transports'] as List), contains('lan'));
    });

    test('does not throw when http client throws', () async {
      when(
        () => mockClient.put(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(Exception('network error'));

      await expectLater(
        service.announceLan(ip: '192.168.1.10', port: 9000, token: 'tok'),
        completes,
      );
    });

    test('does not throw when response is non-200', () async {
      when(
        () => mockClient.put(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      await expectLater(
        service.announceLan(ip: '192.168.1.10', port: 9000, token: 'tok'),
        completes,
      );
    });
  });

  group('fetchLanHint', () {
    void stubGet(String body, int status) {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(body, status));
    }

    test('returns PeerHint when response includes lan transport', () async {
      stubGet(
        jsonEncode({'ip': '192.168.1.5', 'port': 8888, 'transports': ['lan']}),
        200,
      );

      final hint = await service.fetchLanHint('peer1', 'tok');

      expect(hint, isNotNull);
      expect(hint!.ip, '192.168.1.5');
      expect(hint.port, 8888);
    });

    test('sends GET to correct URL with auth header', () async {
      stubGet(
        jsonEncode({'ip': '10.0.0.1', 'port': 9001, 'transports': ['lan']}),
        200,
      );

      await service.fetchLanHint('abc123pubkey', 'mytoken');

      final captured = verify(
        () => mockClient.get(captureAny(), headers: captureAny(named: 'headers')),
      ).captured;

      expect(
        (captured[0] as Uri).toString(),
        'http://localhost:4000/api/v1/peers/abc123pubkey/hints',
      );
      expect((captured[1] as Map<String, String>)['Authorization'], 'Bearer mytoken');
    });

    test('returns null when status is not 200', () async {
      stubGet('Not Found', 404);
      expect(await service.fetchLanHint('peer1', 'tok'), isNull);
    });

    test('returns null when transports does not include lan', () async {
      stubGet(
        jsonEncode({'ip': '192.168.1.5', 'port': 8888, 'transports': ['ble']}),
        200,
      );
      expect(await service.fetchLanHint('peer1', 'tok'), isNull);
    });

    test('returns null when transports is empty', () async {
      stubGet(
        jsonEncode({'ip': '192.168.1.5', 'port': 8888, 'transports': []}),
        200,
      );
      expect(await service.fetchLanHint('peer1', 'tok'), isNull);
    });

    test('returns null when ip is missing', () async {
      stubGet(
        jsonEncode({'port': 8888, 'transports': ['lan']}),
        200,
      );
      expect(await service.fetchLanHint('peer1', 'tok'), isNull);
    });

    test('returns null when port is missing', () async {
      stubGet(
        jsonEncode({'ip': '192.168.1.5', 'transports': ['lan']}),
        200,
      );
      expect(await service.fetchLanHint('peer1', 'tok'), isNull);
    });

    test('returns null when http client throws', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('timeout'));
      expect(await service.fetchLanHint('peer1', 'tok'), isNull);
    });

    test('returns null when response body is malformed JSON', () async {
      stubGet('not json {{{', 200);
      expect(await service.fetchLanHint('peer1', 'tok'), isNull);
    });
  });
}
