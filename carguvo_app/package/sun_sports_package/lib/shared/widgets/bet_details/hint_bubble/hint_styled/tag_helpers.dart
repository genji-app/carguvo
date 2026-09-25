class TagHelpers {
  TagHelpers._();

  static String wrapTag(String tag, String content) => '<$tag>$content</$tag>';

  static String wrapTags(List<String> tags, String content) {
    if (tags.isEmpty) return content;
    return tags.reversed.fold(content, (acc, tag) => wrapTag(tag, acc));
  }

  static String bulletPoint(String content) =>
      ' <bullet-point>•</bullet-point> <bullet>$content</bullet>';

  static String bulletResult(String resultTag, String text) =>
      ' <bullet-point>•</bullet-point> <bullet><$resultTag>$text</$resultTag>.</bullet>';

  static String caseItem(String caseNum, String content) =>
      ' <bullet-point>•</bullet-point> <case>$caseNum:</case> $content';

  static String remainingCase(String content) =>
      ' <bullet-point>•</bullet-point> Các trường hợp còn lại → $content';

  static String team(String name) => wrapTag('team', name);

  static String selection(String name) => wrapTag('selection', name);

  static String selectionTeam(String name) => wrapTag('selection-team', name);

  static String period(String text) => wrapTag('period', text);

  static String handicap(String value) => wrapTag('handicap', value);

  static String score(String value) => wrapTag('score', value);

  static String money(String amount) => wrapTag('money', amount);

  static String number(String value) => wrapTag('number', value);

  static String condition(String text) => wrapTag('condition', text);

  static String positiveRatio(String value) => wrapTag('positive', value);

  static String negativeRatio(String value) => wrapTag('negative', value);

  static String win(String text) => wrapTag('win', text);

  static String lose(String text) => wrapTag('lose', text);

  static String draw(String text) => wrapTag('draw', text);

  static String halfWin(String text) => wrapTag('halfwin', text);

  static String halfLose(String text) => wrapTag('halflose', text);
}
