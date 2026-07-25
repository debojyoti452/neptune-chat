import 'package:equatable/equatable.dart';

class Identity extends Equatable {
  final String pubkey;
  final String? displayName;

  const Identity({required this.pubkey, this.displayName});

  @override
  List<Object?> get props => [pubkey, displayName];
}
