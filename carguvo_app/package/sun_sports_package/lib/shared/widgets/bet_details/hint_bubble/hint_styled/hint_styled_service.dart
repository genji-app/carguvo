import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_service.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_styled/tag_helpers.dart';

class StyledHintContent {
  final String simpleText;
  final String infoText;
  final String ratioText;
  final String resultText;
  final String exampleText;

  const StyledHintContent({
    required this.simpleText,
    required this.infoText,
    required this.ratioText,
    required this.resultText,
    required this.exampleText,
  });
}

class HintStyledService {
  HintStyledService._();

  static final RegExp _scoreRegex = RegExp(r'(?<=\s)\d+-\d+(?=\s)');

  static final RegExp _winLoseRegex = RegExp(r'[Tt]hắng|[Tt]hua');

  static StyledHintContent generateStyledHint(HintData data) {
    final content = HintService.generateHint(data);

    final teams =
        <String>[
          if (data.homeName.isNotEmpty) data.homeName,
          if (data.awayName.isNotEmpty) data.awayName,
        ]..sort((a, b) => b.length.compareTo(a.length));

    return StyledHintContent(
      simpleText: TagHelpers.wrapTag(
        'simple',
        _wrapTeams(content.simpleText, teams),
      ),
      infoText: _tagInfo(content.infoText, teams),
      ratioText: _tagRatio(content.ratioText, data.ratio),
      resultText: _wrapWinLose(_wrapTeams(content.resultText, teams)),
      exampleText: _wrapWinLose(_wrapTeams(content.exampleText, teams)),
    );
  }

  static String _wrapWinLose(String text) {
    return text.replaceAllMapped(_winLoseRegex, (match) {
      final word = match.group(0)!;
      return word.contains('ắ')
          ? TagHelpers.win(word)
          : TagHelpers.lose(word);
    });
  }

  static String _tagInfo(String text, List<String> teams) {
    final withTeams = _wrapTeams(text, teams);
    return withTeams.replaceAllMapped(
      _scoreRegex,
      (match) => TagHelpers.score(match.group(0)!),
    );
  }

  static String _tagRatio(String text, double ratio) {
    final ratioStr = ratio.toStringAsFixed(2);
    final tagged = ratio >= 0
        ? TagHelpers.positiveRatio(ratioStr)
        : TagHelpers.negativeRatio(ratioStr);
    return text.replaceFirst(ratioStr, tagged);
  }

  static String _wrapTeams(String text, List<String> teams) {
    if (teams.isEmpty) return text;

    final buffer = StringBuffer();
    var pos = 0;
    while (pos < text.length) {
      int hitIndex = -1;
      String hitName = '';
      for (final name in teams) {
        final index = text.indexOf(name, pos);
        if (index >= 0 && (hitIndex < 0 || index < hitIndex)) {
          hitIndex = index;
          hitName = name;
        }
      }
      if (hitIndex < 0) {
        buffer.write(text.substring(pos));
        break;
      }
      buffer.write(text.substring(pos, hitIndex));
      buffer.write(TagHelpers.team(hitName));
      pos = hitIndex + hitName.length;
    }
    return buffer.toString();
  }
}
