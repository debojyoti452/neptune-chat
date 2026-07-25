import 'package:injectable/injectable.dart';

import '../../../../core/storage/encrypted_db.dart';
import '../models/chat_session_model.dart';

abstract interface class ChatSessionDatasource {
  Future<void> saveSession(ChatSessionModel session);
  Future<ChatSessionModel?> getSession(String sessionId);
  Future<void> deleteSession(String sessionId);
}

@Injectable(as: ChatSessionDatasource)
class ChatSessionDatasourceImpl implements ChatSessionDatasource {
  final EncryptedDb _db;

  const ChatSessionDatasourceImpl(this._db);

  @override
  Future<void> saveSession(ChatSessionModel session) async {
    await _db.db.insert('sessions', session.toMap());
  }

  @override
  Future<ChatSessionModel?> getSession(String sessionId) async {
    final rows = await _db.db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ChatSessionModel.fromMap(rows.first);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _db.db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
  }
}
