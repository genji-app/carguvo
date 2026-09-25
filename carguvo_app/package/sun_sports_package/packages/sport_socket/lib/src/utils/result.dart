sealed class Result<T, E> {
  const Result();

  bool get isSuccess => this is Success<T, E>;

  bool get isFailure => this is Failure<T, E>;

  T? get valueOrNull {
    final self = this;
    if (self is Success<T, E>) {
      return self.value;
    }
    return null;
  }

  E? get errorOrNull {
    final self = this;
    if (self is Failure<T, E>) {
      return self.error;
    }
    return null;
  }

  T get valueOrThrow {
    final self = this;
    if (self is Success<T, E>) {
      return self.value;
    }
    throw StateError('Result is Failure: ${(self as Failure<T, E>).error}');
  }

  Result<U, E> map<U>(U Function(T value) mapper) {
    final self = this;
    if (self is Success<T, E>) {
      return Success(mapper(self.value));
    }
    return Failure((self as Failure<T, E>).error);
  }

  Result<T, F> mapError<F>(F Function(E error) mapper) {
    final self = this;
    if (self is Failure<T, E>) {
      return Failure(mapper(self.error));
    }
    return Success((self as Success<T, E>).value);
  }

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) {
    final self = this;
    if (self is Success<T, E>) {
      return onSuccess(self.value);
    }
    return onFailure((self as Failure<T, E>).error);
  }

  void whenSuccess(void Function(T value) callback) {
    final self = this;
    if (self is Success<T, E>) {
      callback(self.value);
    }
  }

  void whenFailure(void Function(E error) callback) {
    final self = this;
    if (self is Failure<T, E>) {
      callback(self.error);
    }
  }
}

final class Success<T, E> extends Result<T, E> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

final class Failure<T, E> extends Result<T, E> {
  final E error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

class ParseError {
  final String rawMessage;
  final String errorMessage;
  final DateTime timestamp;

  ParseError(this.rawMessage, this.errorMessage) : timestamp = DateTime.now();

  @override
  String toString() => 'ParseError: $errorMessage';
}

class ConnectionError {
  final String message;
  final Object? originalError;
  final DateTime timestamp;

  ConnectionError(this.message, [this.originalError])
      : timestamp = DateTime.now();

  @override
  String toString() => 'ConnectionError: $message';
}

class ProcessingError {
  final String message;
  final String? messageType;
  final Object? originalError;
  final DateTime timestamp;

  ProcessingError(this.message, {this.messageType, this.originalError})
      : timestamp = DateTime.now();

  @override
  String toString() => 'ProcessingError: $message';
}
