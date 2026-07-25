import 'dart:convert';
import 'dart:typed_data';

class BleMessageCodec {
  static List<Uint8List> encode(String json, int mtu) {
    final payload = utf8.encode(json);
    final totalLength = payload.length;

    final header = ByteData(4)..setUint32(0, totalLength, Endian.big);
    final frame = Uint8List(4 + totalLength);
    frame.setRange(0, 4, header.buffer.asUint8List());
    frame.setRange(4, frame.length, payload);

    final chunkSize = mtu - 3;
    final chunks = <Uint8List>[];
    var offset = 0;
    while (offset < frame.length) {
      final end =
          (offset + chunkSize < frame.length) ? offset + chunkSize : frame.length;
      chunks.add(Uint8List.fromList(frame.sublist(offset, end)));
      offset = end;
    }
    return chunks;
  }
}

class BleMessageDecoder {
  final _buffer = BytesBuilder();
  int _expectedLength = -1;

  String? addChunk(Uint8List chunk) {
    _buffer.add(chunk);
    final accumulated = _buffer.toBytes();

    if (_expectedLength < 0 && accumulated.length >= 4) {
      final view = ByteData.sublistView(accumulated, 0, 4);
      _expectedLength = view.getUint32(0, Endian.big);
    }

    if (_expectedLength >= 0 && accumulated.length >= 4 + _expectedLength) {
      final jsonBytes = accumulated.sublist(4, 4 + _expectedLength);
      _reset();
      return utf8.decode(jsonBytes);
    }

    return null;
  }

  void _reset() {
    _buffer.clear();
    _expectedLength = -1;
  }
}
