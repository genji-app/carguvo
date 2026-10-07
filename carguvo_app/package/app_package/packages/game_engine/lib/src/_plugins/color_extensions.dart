import 'dart:ui';

extension ColorExtensions on Color {
  String toCssRgba() {
    final rValue = (r * 255.0).round().clamp(0, 255);
    final gValue = (g * 255.0).round().clamp(0, 255);
    final bValue = (b * 255.0).round().clamp(0, 255);
    return 'rgba($rValue, $gValue, $bValue, $a)';
  }
}
