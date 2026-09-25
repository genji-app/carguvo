import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'hint_service.dart';

class HintContentStyle {
  final Color simpleColor;
  final Color defaultColor;
  final Color highlightColor;
  final Color positiveColor;
  final Color negativeColor;

  final Color winColor;
  final Color loseColor;

  final Color teamColor;

  final TextStyle? textStyle;

  final FontWeight ratioFontWeight;

  const HintContentStyle({
    required this.simpleColor,
    required this.defaultColor,
    required this.highlightColor,
    required this.positiveColor,
    required this.negativeColor,
    this.winColor = AppColors.green500,
    this.loseColor = AppColors.red500,
    this.teamColor = const Color(0xFF2E90FA),
    this.textStyle,
    this.ratioFontWeight = FontWeight.bold,
  });

  TextStyle getTextStyle(Color color) {
    if (textStyle != null) {
      return textStyle!.copyWith(color: color);
    }
    return AppTextStyles.paragraphSmall(color: color);
  }
}

class HintContentBuilder {
  HintContentBuilder._();

  static final _ratioRegex = RegExp(r'(-?\d+\.?\d*)');
  static final _thRegex = RegExp(r'(TH\d+:)');

  static Widget buildContent({
    required HintContent content,
    required double ratio,
    required HintContentStyle style,
    bool useGap = false,
    double spacing = 16.0,
    double linePadding = 2.0,
    double ratioPadding = 4.0,
  }) {
    final spacingWidget = useGap ? Gap(spacing) : SizedBox(height: spacing);
    final teamNames = _teamNameList(content.homeName, content.awayName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSimpleText(content.simpleText, style),
        spacingWidget,
        buildInfoText(content.infoText, style, linePadding, teamNames),
        spacingWidget,
        buildRatioText(
          content.ratioText,
          ratio,
          style,
          linePadding,
          ratioPadding,
        ),
        spacingWidget,
        buildResultText(content.resultText, style, linePadding, teamNames),
        spacingWidget,
        buildExampleText(content.exampleText, style, linePadding, teamNames),
      ],
    );
  }

  static List<String> _teamNameList(String homeName, String awayName) {
    final names = [homeName, awayName].where((n) => n.isNotEmpty).toList();
    names.sort((a, b) => b.length.compareTo(a.length));
    return names;
  }

  static List<InlineSpan> _teamSpans(
    String text,
    List<String> teamNames,
    TextStyle teamStyle,
    List<InlineSpan> Function(String) segment,
  ) {
    if (teamNames.isEmpty || text.isEmpty) return segment(text);

    final spans = <InlineSpan>[];
    var pos = 0;
    while (pos < text.length) {
      int hitIndex = -1;
      String hitName = '';
      for (final name in teamNames) {
        final index = text.indexOf(name, pos);
        if (index >= 0 && (hitIndex < 0 || index < hitIndex)) {
          hitIndex = index;
          hitName = name;
        }
      }
      if (hitIndex < 0) {
        spans.addAll(segment(text.substring(pos)));
        break;
      }
      if (hitIndex > pos) {
        spans.addAll(segment(text.substring(pos, hitIndex)));
      }
      spans.add(TextSpan(text: hitName, style: teamStyle));
      pos = hitIndex + hitName.length;
    }
    return spans;
  }

  static Widget buildSimpleText(String text, HintContentStyle style) {
    return Text(text, style: style.getTextStyle(style.simpleColor));
  }

  static Widget buildInfoText(
    String text,
    HintContentStyle style,
    double linePadding, [
    List<String> teamNames = const [],
  ]) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final textStyle = style.getTextStyle(style.defaultColor);
    final teamStyle = style.getTextStyle(style.teamColor);
    final padding = EdgeInsets.only(bottom: linePadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Padding(
            padding: padding,
            child: RichText(
              text: TextSpan(
                style: textStyle,
                children: _teamSpans(
                  line,
                  teamNames,
                  teamStyle,
                  (segment) => [TextSpan(text: segment)],
                ),
              ),
            ),
          ),
      ],
    );
  }

  static Widget buildRatioText(
    String text,
    double ratio,
    HintContentStyle style,
    double linePadding,
    double ratioPadding,
  ) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final textStyle = style.getTextStyle(style.defaultColor);
    final padding = EdgeInsets.only(bottom: linePadding);
    final ratioPad = EdgeInsets.only(bottom: ratioPadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: ratioPad,
          child: buildRatioLine(lines[0], ratio, style),
        ),
        for (int i = 1; i < lines.length; i++)
          Padding(
            padding: padding,
            child: Text(lines[i], style: textStyle),
          ),
      ],
    );
  }

  static Widget buildRatioLine(
    String line,
    double ratio,
    HintContentStyle style,
  ) {
    final ratioColor = ratio >= 0 ? style.positiveColor : style.negativeColor;
    final match = _ratioRegex.firstMatch(line);

    if (match == null) {
      return Text(line, style: style.getTextStyle(style.defaultColor));
    }

    final defaultStyle = style.getTextStyle(style.defaultColor);
    final ratioStyle = style
        .getTextStyle(ratioColor)
        .copyWith(fontWeight: style.ratioFontWeight);

    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: [
          if (match.start > 0) TextSpan(text: line.substring(0, match.start)),
          TextSpan(text: match.group(0), style: ratioStyle),
          if (match.end < line.length)
            TextSpan(text: line.substring(match.end)),
        ],
      ),
    );
  }

  static Widget buildResultText(
    String text,
    HintContentStyle style,
    double linePadding, [
    List<String> teamNames = const [],
  ]) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final defaultStyle = style.getTextStyle(style.defaultColor);
    final highlightStyle = style.getTextStyle(style.highlightColor);
    final teamStyle = style.getTextStyle(style.teamColor);
    final padding = EdgeInsets.only(bottom: linePadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Padding(
            padding: padding,
            child: RichText(
              text: TextSpan(
                style: line.trimLeft().startsWith('•')
                    ? highlightStyle
                    : defaultStyle,
                children: _teamSpans(
                  line,
                  teamNames,
                  teamStyle,
                  (segment) => [TextSpan(text: segment)],
                ),
              ),
            ),
          ),
      ],
    );
  }

  static Widget buildExampleText(
    String text,
    HintContentStyle style,
    double linePadding, [
    List<String> teamNames = const [],
  ]) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final highlightStyle = style.getTextStyle(style.highlightColor);
    final padding = EdgeInsets.only(bottom: linePadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Padding(
            padding: padding,
            child: _buildExampleLine(line, style, highlightStyle, teamNames),
          ),
      ],
    );
  }

  static Widget _buildExampleLine(
    String line,
    HintContentStyle style,
    TextStyle highlightStyle,
    List<String> teamNames,
  ) {
    if (line.contains('TH')) {
      final match = _thRegex.firstMatch(line);
      if (match != null) {
        return buildCaseLine(line, style, match, teamNames);
      }
    }

    final hasWin = line.contains('thắng');
    final hasLose = line.contains('thua');

    if (hasWin || hasLose) {
      return buildResultLine(line, style, teamNames);
    }

    return RichText(
      text: TextSpan(
        style: highlightStyle,
        children: _teamSpans(
          line,
          teamNames,
          style.getTextStyle(style.teamColor),
          (segment) => [TextSpan(text: segment)],
        ),
      ),
    );
  }

  static Widget buildCaseLine(
    String line,
    HintContentStyle style,
    RegExpMatch match, [
    List<String> teamNames = const [],
  ]) {
    final highlightStyle = style.getTextStyle(style.highlightColor);
    final boldStyle = highlightStyle.copyWith(fontWeight: FontWeight.bold);
    final teamStyle = style.getTextStyle(style.teamColor);

    return RichText(
      text: TextSpan(
        style: highlightStyle,
        children: [
          if (match.start > 0) TextSpan(text: line.substring(0, match.start)),
          TextSpan(text: match.group(0), style: boldStyle),
          ..._teamSpans(
            line.substring(match.end),
            teamNames,
            teamStyle,
            (segment) => buildResultSpans(segment, style),
          ),
        ],
      ),
    );
  }

  static Widget buildResultLine(
    String line,
    HintContentStyle style, [
    List<String> teamNames = const [],
  ]) {
    final highlightStyle = style.getTextStyle(style.highlightColor);
    final teamStyle = style.getTextStyle(style.teamColor);

    final cleanLine = line.trimLeft().startsWith('•')
        ? line.replaceFirst(RegExp(r'^\s*•\s*'), '')
        : line;

    return RichText(
      text: TextSpan(
        style: highlightStyle,
        children: [
          const TextSpan(text: ' • '),
          ..._teamSpans(
            cleanLine,
            teamNames,
            teamStyle,
            (segment) => buildResultSpans(segment, style),
          ),
        ],
      ),
    );
  }

  static List<TextSpan> buildResultSpans(String text, HintContentStyle style) {
    if (text.isEmpty) return const [];

    final defaultStyle = style.getTextStyle(style.defaultColor);
    final spans = <TextSpan>[];
    var pos = 0;

    while (pos < text.length) {
      final remaining = text.substring(pos);
      final winIndex = remaining.indexOf('thắng');
      final loseIndex = remaining.indexOf('thua');

      int nextIndex = -1;
      String keyword = '';
      Color keywordColor = style.defaultColor;

      if (winIndex >= 0 && (loseIndex < 0 || winIndex < loseIndex)) {
        nextIndex = winIndex;
        keyword = 'thắng';
        keywordColor = style.winColor;
      } else if (loseIndex >= 0) {
        nextIndex = loseIndex;
        keyword = 'thua';
        keywordColor = style.loseColor;
      }

      if (nextIndex < 0) {
        if (remaining.isNotEmpty) {
          spans.add(TextSpan(text: remaining, style: defaultStyle));
        }
        break;
      }

      if (nextIndex > 0) {
        spans.add(
          TextSpan(
            text: remaining.substring(0, nextIndex),
            style: defaultStyle,
          ),
        );
      }

      spans.add(
        TextSpan(
          text: keyword,
          style: style
              .getTextStyle(keywordColor)
              .copyWith(fontWeight: FontWeight.bold),
        ),
      );

      pos += nextIndex + keyword.length;
    }

    return spans;
  }
}
