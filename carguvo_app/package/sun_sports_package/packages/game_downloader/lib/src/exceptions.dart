sealed class GameDownloaderException implements Exception {
  final String message;
  const GameDownloaderException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends GameDownloaderException {
  const NetworkException(super.message);
}

class ServerException extends GameDownloaderException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class CacheException extends GameDownloaderException {
  const CacheException(super.message);
}

class UnzipException extends GameDownloaderException {
  const UnzipException(super.message);
}

class UnexpectedException extends GameDownloaderException {
  const UnexpectedException(super.message);
}
