import 'package:uuid/uuid.dart';

class IdGenerator {
  IdGenerator._();

  static const _uuid = Uuid();

  /// Generate a unique ID
  static String generate() => _uuid.v4();
}
