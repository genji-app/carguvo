import 'dart:typed_data';

import '../proto/proto.dart';

class ProtoParser {
  static void Function(String message)? onParseError;

  Payload? parse(Uint8List bytes) {
    if (bytes.isEmpty) {
      return null;
    }

    try {
      return Payload.fromBuffer(bytes);
    } catch (e) {
      onParseError?.call('[ProtoParser] Failed to parse message: $e');
      return null;
    }
  }

  ParseResult parseWithDetails(Uint8List bytes) {
    if (bytes.isEmpty) {
      return ParseResult.error('Empty bytes received');
    }

    try {
      final payload = Payload.fromBuffer(bytes);
      return ParseResult.success(payload);
    } catch (e, stackTrace) {
      return ParseResult.error(
        'Failed to parse protobuf: $e',
        stackTrace: stackTrace,
        rawBytes: bytes,
      );
    }
  }
}

class ParseResult {
  final Payload? payload;
  final String? error;
  final StackTrace? stackTrace;
  final Uint8List? rawBytes;

  const ParseResult._({
    this.payload,
    this.error,
    this.stackTrace,
    this.rawBytes,
  });

  factory ParseResult.success(Payload payload) =>
      ParseResult._(payload: payload);

  factory ParseResult.error(
    String error, {
    StackTrace? stackTrace,
    Uint8List? rawBytes,
  }) =>
      ParseResult._(
        error: error,
        stackTrace: stackTrace,
        rawBytes: rawBytes,
      );

  bool get isSuccess => payload != null;
  bool get isError => error != null;
}
