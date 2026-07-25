import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:network_info_plus/network_info_plus.dart';

const _serviceType = '_neptune._tcp';

@singleton
class PeerDiscoveryService {
  final MDnsClient _mdns = MDnsClient();
  final _discoveredController = StreamController<PeerHint>.broadcast();

  Stream<PeerHint> get discovered => _discoveredController.stream;

  Future<void> startAdvertising({required String pubkey, required int port}) async {
    await _mdns.start();
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
