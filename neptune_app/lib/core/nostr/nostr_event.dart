import 'package:freezed_annotation/freezed_annotation.dart';

part 'nostr_event.freezed.dart';
part 'nostr_event.g.dart';

@freezed
abstract class NostrEvent with _$NostrEvent {
  const factory NostrEvent({
    required String id,
    required String pubkey,
    @JsonKey(name: 'created_at') required int createdAt,
    required int kind,
    required List<List<String>> tags,
    required String content,
    required String sig,
  }) = _NostrEvent;

  factory NostrEvent.fromJson(Map<String, dynamic> json) =>
      _$NostrEventFromJson(json);
}
