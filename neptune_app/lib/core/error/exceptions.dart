class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
}

class CryptoException implements Exception {
  final String message;
  const CryptoException(this.message);
}

class RelayException implements Exception {
  final String message;
  const RelayException(this.message);
}
