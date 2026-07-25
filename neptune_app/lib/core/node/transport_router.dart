import 'package:injectable/injectable.dart';

import '../nostr/nostr_event.dart';
import '../nostr/nostr_relay_client.dart';
import 'route_envelope.dart';

@singleton
class TransportRouter {
  final NostrRelayClient _internetRelay;

  TransportRouter({required this._internetRelay});

  Future<void> send(NostrEvent event, {String? toPubkey}) async {
    final transport = await _selectTransport(toPubkey);
    switch (transport) {
      case MessageTransport.internet:
        _internetRelay.sendEvent(event);
      case MessageTransport.lan:
        break;
      case MessageTransport.ble:
        break;
      case MessageTransport.relay:
        _internetRelay.sendEvent(event);
    }
  }

  Future<MessageTransport> _selectTransport(String? peerPubkey) async {
    return MessageTransport.internet;
  }
}
