import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../crypto/key_storage_service.dart';
import 'db_schema.dart';

class EncryptedDb {
  EncryptedDb._();

  static final EncryptedDb instance = EncryptedDb._();

  Database? _db;

  Database get db {
    assert(_db != null, 'EncryptedDb.open() must be called before use');
    return _db!;
  }

  Future<void> open() async {
    final key = await KeyStorageService.instance.getOrCreateDbKey();
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'neptune.db');

    _db = await openDatabase(
      path,
      password: key,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute(DbSchema.createMessages);
    batch.execute(DbSchema.createSessions);
    batch.execute(DbSchema.createPeers);
    batch.execute(DbSchema.createRoutingTable);
    batch.execute(DbSchema.createSettings);
    await batch.commit(noResult: true);
  }
}
