import 'dart:convert';
import 'dart:typed_data';

class Base64Helper {
  static String decodeToString(String base64String) {
    try {
      if (base64String.isEmpty) {
        return '';
      }

      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);
      return utf8.decode(bytes);
    } catch (e) {
      return '';
    }
  }

  static Uint8List decodeToBytes(String base64String) {
    try {
      if (base64String.isEmpty) {
        return Uint8List(0);
      }

      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      return base64Decode(cleanBase64);
    } catch (e) {
      return Uint8List(0);
    }
  }

  static String encode(String input) {
    try {
      if (input.isEmpty) {
        return '';
      }
      final bytes = utf8.encode(input);
      return base64Encode(bytes);
    } catch (e) {
      return '';
    }
  }

  static String encodeBytes(Uint8List bytes) {
    try {
      if (bytes.isEmpty) {
        return '';
      }
      return base64Encode(bytes);
    } catch (e) {
      return '';
    }
  }

  static bool isValidBase64(String input) {
    try {
      if (input.isEmpty) {
        return false;
      }

      String cleanBase64 = input;
      if (input.contains(',')) {
        cleanBase64 = input.split(',').last;
      }

      base64Decode(cleanBase64);
      return true;
    } catch (e) {
      return false;
    }
  }
}

extension Base64StringExtension on String {
  String base64DecodeToString() => Base64Helper.decodeToString(this);

  Uint8List base64DecodeToBytes() => Base64Helper.decodeToBytes(this);

  String base64Encode() => Base64Helper.encode(this);

  bool isValidBase64() => Base64Helper.isValidBase64(this);
}
