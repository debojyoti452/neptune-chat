import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:network_info_plus/network_info_plus.dart';

const _serviceType = '_neptune._tcp';

@lazySingleton
class PeerDiscoveryService {
  final http.Client _client;
  final String _baseUrl;

  final MDnsClient _mdns = MDnsClient();
  final _discoveredController = StreamController<PeerHint>.broadcast();

  Stream<PeerHint> get discovered => _discoveredController.stream;

  PeerDiscoveryService(this._client, @Named('apiBaseUrl') this._baseUrl);

  Future<void> announceLan({
    required String ip,
    required int port,
    required String token,
  }) async {
    try {
      await _client.put(
        Uri.parse('$_baseUrl/api/v1/peers/me/hints'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'ip': ip,
          'port': port,
          'transports': ['lan'],
        }),
      );
    } catch (_) {}
  }

  Future<PeerHint?> fetchLanHint(String peerPubkey, String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/peers/$peerPubkey/hints'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final transports = (body['transports'] as List<dynamic>?) ?? [];
      if (!transports.contains('lan')) return null;
      final ip = body['ip'] as String?;
      final port = body['port'] as int?;
      if (ip == null || port == null) return null;
      return PeerHint(ip: ip, port: port);
    } catch (_) {
      return null;
    }
  }

  Future<void> startScanning() async {
    await _mdns.start();
    await for (final ptr in _mdns.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer(_serviceType),
    )) {
      await for (final srv in _mdns.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName),
      )) {
        await for (final ip in _mdns.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(srv.target),
        )) {
          _discoveredController.add(
            PeerHint(ip: ip.address.address, port: srv.port),
          );
        }
      }
    }
  }

  Future<String?> localIpAddress() async {
    return NetworkInfo().getWifiIP();
  }

  void stop() {
    _mdns.stop();
  }

  void dispose() {
    stop();
    _discoveredController.close();
  }
}

class PeerHint {
  final String ip;
  final int port;
  final String? pubkey;

  const PeerHint({required this.ip, required this.port, this.pubkey});
}
