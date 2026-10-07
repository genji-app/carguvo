import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

void logRepaintBoundaryPath(BuildContext context, {String label = ''}) {
  if (!kDebugMode) return;

  RenderObject? node = context.findRenderObject();
  if (node == null) {
    debugPrint('[RB] $label: chưa có RenderObject (gọi sau frame đầu tiên)');
    return;
  }

  final buffer = StringBuffer('[RB] $label\n');
  var depth = 0;
  var foundFirstBoundary = false;

  while (node != null) {
    final isBoundary = node.isRepaintBoundary;
    final size = node is RenderBox && node.hasSize ? node.size : null;

    if (isBoundary) {
      final marker = foundFirstBoundary ? 'boundary' : '⟵ BOUNDARY GẦN NHẤT';
      buffer.writeln(
        '  ${depth.toString().padLeft(3)}  ${node.runtimeType}  '
        '${size ?? ''}  $marker',
      );
      foundFirstBoundary = true;
    } else if (depth <= 2 || node.parent == null) {
      buffer.writeln(
        '  ${depth.toString().padLeft(3)}  ${node.runtimeType}  ${size ?? ''}',
      );
    }

    node = node.parent;
    depth++;
  }

  buffer.writeln('  → tổng $depth tầng tới gốc');
  debugPrint(buffer.toString());
}
