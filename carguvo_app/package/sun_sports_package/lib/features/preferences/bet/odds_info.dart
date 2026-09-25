import 'package:sun_sports/shared/domain/enums/league_enums.dart';

abstract class OddsInfo {
  static const malayLabel = 'Malaysia';
  static const hongKongLabel = 'Hong Kong';
  static const indoLabel = 'Indonesia';
  static const decimalLabel = 'Decimal';

  static const malayPositiveSection = '''
<title>Tỷ lệ cược <odds>Malaysia</odds> số dương:</title>
<content>• Tiền thắng = Tiền cược x Tỷ lệ.</content>
<content>• Tiền thua = Tiền cược.</content>

Ví dụ cược 100k tỷ lệ <number>0.78</number>:
• Thắng 78K
• Thua 100K''';

  static const malayNegativeSection = '''
<title>Tỷ lệ cược <odds>Malaysia</odds> số âm:</title>
<content>• Tiền thắng = Tiền cược.</content>
<content>• Tiền thua = Tiền cược x Tỷ lệ.</content>

Ví dụ cược 100k tỷ lệ <number>-0.78</number>:
• Thắng 100K
• Thua 78K''';

  static const List<String> malaySections = [
    malayPositiveSection,
    malayNegativeSection,
  ];

  static const hongKongSection = '''
<title>Tỷ lệ cược <odds>Hongkong</odds>:</title>
<content>• Tiền thắng = Tiền cược x Tỷ lệ.</content>
<content>• Tiền thua = Tiền cược.</content>

Ví dụ cược 100K tỷ lệ <number>1.23</number>:
• Thắng 123K
• Thua 100K''';

  static const List<String> hongKongSections = [hongKongSection];

  static const indoPositiveSection = '''
<title>Tỷ lệ cược <odds>Indonesia</odds> số dương:</title>
<content>• Tiền thắng = Tiền cược.</content>
<content>• Tiền thua = Tiền cược x Tỷ lệ.</content>

Ví dụ cược 100K tỷ lệ <number>1.23</number>:
• Thắng 123K
• Thua 100K''';

  static const indoNegativeSection = '''
<title>Tỷ lệ cược <odds>Indonesia</odds> số âm:</title>
<content>• Tiền thắng = Tiền cược ÷ Tỷ lệ.</content>
<content>• Tiền thua = Tiền cược.</content>

Ví dụ cược 123K tỷ lệ <number>-1.23</number>:
• Thắng 100K
• Thua 123K''';

  static const List<String> indoSections = [
    indoPositiveSection,
    indoNegativeSection,
  ];

  static const decimalSection = '''
<title>Tỷ lệ cược <odds>Decimal</odds>:</title>
<content>• Tiền thắng = Tiền cược x (Tỷ lệ - 1).</content>
<content>• Tiền thua = Tiền cược.</content>

Ví dụ cược 100K tỷ lệ <number>2.34</number>:
• Thắng 134K
• Thua 100K''';

  static const List<String> decimalSections = [decimalSection];
}

extension OddsStyleDisplayExt on OddsStyle {
  String get label => switch (this) {
    OddsStyle.malay => OddsInfo.malayLabel,
    OddsStyle.hongKong => OddsInfo.hongKongLabel,
    OddsStyle.indo => OddsInfo.indoLabel,
    OddsStyle.decimal => OddsInfo.decimalLabel,
  };

  List<String> get sections => switch (this) {
    OddsStyle.malay => OddsInfo.malaySections,
    OddsStyle.hongKong => OddsInfo.hongKongSections,
    OddsStyle.indo => OddsInfo.indoSections,
    OddsStyle.decimal => OddsInfo.decimalSections,
  };

  String get displaySuffix => switch (this) {
    OddsStyle.malay => 'MA',
    OddsStyle.indo => 'IN',
    OddsStyle.decimal => 'DE',
    OddsStyle.hongKong => 'HK',
  };
}
