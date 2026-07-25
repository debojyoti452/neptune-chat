import 'package:injectable/injectable.dart';

import '../../../../core/storage/encrypted_db.dart';
import '../models/message_model.dart';

abstract interface class ChatLocalDatasource {
  Future<void> saveMessage(MessageModel message);
  Future<List<MessageModel>> getMessages(String sessionId);
  Future<void> deleteSession(String sessionId);
}

@Injectable(as: ChatLocalDatasource)
class ChatLocalDatasourceImpl implements ChatLocalDatasource {
  final EncryptedDb _db;

  const ChatLocalDatasourceImpl(this._db);

  @override
  Future<void> saveMessage(MessageModel message) async {
    await _db.db.insert('messages', message.toMap());
  }

  @override
  Future<List<MessageModel>> getMessages(String sessionId) async {
    final rows = await _db.db.query(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'sent_at ASC',
    );
    return rows.map(MessageModel.fromMap).toList();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _db.db.delete(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }
}
