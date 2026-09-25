import 'package:flutter/widgets.dart';
import 'package:sun_sports/core/perf/perf_flags.dart';
import 'package:sun_sports/core/perf/perf_log.dart';

abstract final class ElementCensus {
  static final Set<String> _done = {};

  static void once(
    String key,
    BuildContext context, {
    Set<String> sections = const {},
    String? dumpSection,
  }) {
    if (!PerfFlags.trace || !_done.add(key)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      _report(key, context as Element, sections, dumpSection);
    });
  }

  static void _report(
    String key,
    Element root,
    Set<String> sections,
    String? dumpSection,
  ) {
    var total = 0;
    var renders = 0;
    final byType = <String, int>{};
    final bySection = <String, int>{};
    final rendersBySection = <String, int>{};
    final instances = <String, int>{};
    Element? dumpRoot;

    void visit(Element element, String section) {
      final type = element.widget.runtimeType.toString();
      var owner = section;
      if (sections.contains(type)) {
        owner = type;
        instances[type] = (instances[type] ?? 0) + 1;
        if (type == dumpSection) dumpRoot ??= element;
      }
      total++;
      byType[type] = (byType[type] ?? 0) + 1;
      bySection[owner] = (bySection[owner] ?? 0) + 1;
      if (element is RenderObjectElement) {
        renders++;
        rendersBySection[owner] = (rendersBySection[owner] ?? 0) + 1;
      }
      element.visitChildren((child) => visit(child, owner));
    }

    visit(root, '(row itself)');

    String top(Map<String, int> counts, int n) {
      final entries = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return entries.take(n).map((e) => '${e.key}=${e.value}').join(' ');
    }

    final sectionLines = (bySection.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .map((e) {
      final count = instances[e.key] ?? 1;
      final per = count > 1 ? ' (×$count, ~${(e.value / count).round()} each)' : '';
      return '  ${e.key}: ${e.value} elements, '
          '${rendersBySection[e.key] ?? 0} render$per';
    }).join('\n');

    final buf = StringBuffer()
      ..writeln('census $key: $total elements, $renders render objects')
      ..writeln(sectionLines)
      ..writeln('  top types: ${top(byType, 18)}');

    final cell = dumpRoot;
    if (cell != null) {
      buf.writeln('  tree of first $dumpSection:');
      var lines = 0;
      void dump(Element element, int depth) {
        if (lines >= 90) return;
        lines++;
        final marker = element is RenderObjectElement ? ' ▣' : '';
        buf.writeln('    ${'  ' * depth}${element.widget.runtimeType}$marker');
        element.visitChildren((child) => dump(child, depth + 1));
      }

      dump(cell, 0);
    }
    PerfLog.write(buf.toString());
  }
}
