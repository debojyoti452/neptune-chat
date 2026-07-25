abstract final class DbSchema {
  static const createMessages = '''
    CREATE TABLE IF NOT EXISTS messages (
      id           TEXT PRIMARY KEY,
      session_id   TEXT NOT NULL,
      peer_id      TEXT NOT NULL,
      ciphertext   BLOB NOT NULL,
      nonce        BLOB NOT NULL,
      direction    TEXT NOT NULL,
      transport    TEXT NOT NULL,
      sent_at      INTEGER NOT NULL
    )
  ''';

  static const createSessions = '''
    CREATE TABLE IF NOT EXISTS sessions (
      id               TEXT PRIMARY KEY,
      peer_id          TEXT NOT NULL,
      peer_public_key  BLOB NOT NULL,
      shared_secret    BLOB NOT NULL,
      transport        TEXT NOT NULL,
      started_at       INTEGER NOT NULL
    )
  ''';

  static const createPeers = '''
    CREATE TABLE IF NOT EXISTS peers (
      id              TEXT PRIMARY KEY,
      display_name    TEXT,
      public_key      BLOB NOT NULL,
      last_seen_at    INTEGER,
      last_transport  TEXT
    )
  ''';

  static const createRoutingTable = '''
    CREATE TABLE IF NOT EXISTS routing_table (
      peer_id             TEXT NOT NULL,
      via_peer_id         TEXT,
      transport           TEXT NOT NULL,
      reachability_score  REAL,
      last_updated        INTEGER NOT NULL,
      PRIMARY KEY (peer_id, transport)
    )
  ''';

  static const createSettings = '''
    CREATE TABLE IF NOT EXISTS settings (
      key         TEXT PRIMARY KEY,
      value_blob  BLOB NOT NULL
    )
  ''';
}
