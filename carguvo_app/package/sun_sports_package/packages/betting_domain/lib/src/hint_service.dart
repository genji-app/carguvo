library;

import 'hint_data.dart';
import 'hint_enums.dart';
import 'odds_calculator.dart';
import 'outright_kind.dart';

class HintService {
  HintService._();

  static HintContent generateHint(HintData data) {
    final simpleText = _personalizeTeams(_buildSimpleText(data), data);
    final infoText = _personalizeTeams(_buildInfoText(data), data);
    final ratioText = _buildRatioText(data);
    final resultText = _personalizeTeams(_buildResultText(data), data);
    final exampleText = _personalizeTeams(_buildExampleText(data), data);

    return HintContent(
      simpleText: simpleText,
      infoText: infoText,
      ratioText: ratioText,
      resultText: resultText,
      exampleText: exampleText,
      homeName: data.homeName,
      awayName: data.awayName,
    );
  }

  static String _personalizeTeams(String text, HintData data) {
    var result = text;
    if (data.homeName.isNotEmpty) {
      result = result
          .replaceAll('Đội nhà', data.homeName)
          .replaceAll('đội nhà', data.homeName);
    }
    if (data.awayName.isNotEmpty) {
      result = result
          .replaceAll('Đội khách', data.awayName)
          .replaceAll('đội khách', data.awayName);
    }
    return result;
  }

  static String _buildSimpleText(HintData data) {
    final period = data.periodLabel.isNotEmpty
        ? data.periodLabel
        : _simplePeriod(data.period, data.sportId);

    switch (data.market) {
      case MarketCategory.asianHandicap:
        return 'Kèo Châu Á với đội chấp phải thắng cách biệt hơn tỷ lệ đưa ra trong thời gian $period.';

      case MarketCategory.overUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số ${_sumWord(data.sportId)} của cả 2 đội, trong thời gian $period.';

      case MarketCategory.homeOverUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào số ${_sumWord(data.sportId)} của đội nhà, trong thời gian $period.';

      case MarketCategory.awayOverUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào số ${_sumWord(data.sportId)} của đội khách, trong thời gian $period.';

      case MarketCategory.market1X2:
        return 'Kèo Châu Âu trong thời gian $period.\nCó 3 cửa:\n • 1 : đội nhà thắng.\n • X : hòa.\n • 2 : đội khách thắng.';

      case MarketCategory.oddEven:
        return 'Kèo cược tổng số bàn thắng của hai đội là số chẵn hoặc số lẻ, trong thời gian $period.';

      case MarketCategory.doubleChance:
        return 'Kèo Châu Âu cơ hội kép trong thời gian $period.\nNgười chơi có thể chọn:\n • 1X : đội nhà hoặc hoà.\n • 2X : đội khách hoặc hoà.\n • 12 : đội nhà hoặc đội khách.';

      case MarketCategory.cornerOverUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số lần phạt góc của cả 2 đội, trong thời gian $period.';

      case MarketCategory.cornerHandicap:
        return 'Kèo phạt góc Châu Á với đội chấp phải có số lần phạt góc cách biệt hơn tỷ lệ đưa ra trong thời gian $period.';

      case MarketCategory.bookingsOverUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số thẻ phạt của cả 2 đội, trong thời gian $period.\nThẻ vàng tính 1, thẻ đỏ tính 2.';

      case MarketCategory.bookingsHandicap:
        return 'Kèo thẻ phạt Châu Á với đội chấp phải có số thẻ phạt cách biệt hơn tỷ lệ đưa ra trong thời gian $period.\nThẻ vàng tính 1, thẻ đỏ tính 2.';

      case MarketCategory.drawNoBet:
        return 'Kèo cược đội thắng, trong thời gian $period.\nNgười chơi có thể chọn:\n • Đội nhà thắng.\n • Đội khách thắng.';

      case MarketCategory.moneyLine:
        return 'Kèo đội thắng trong thời gian trận đấu.';

      case MarketCategory.correctScore:
        return 'Kèo cược tỷ số chính xác trong thời gian $period.';

      case MarketCategory.totalScore:
        return 'Kèo cược tổng bàn thắng trong thời gian $period.';

      case MarketCategory.nextGoal:
        return 'Kèo bàn thắng kế tiếp (next goal), lựa chọn bàn thắng kế tiếp được ghi thuộc về đội nhà hoặc đội khách.\nNgười chơi có thể chọn:\n • Bàn thắng kế tiếp thuộc đội nhà.\n • Bàn thắng kế tiếp thuộc đội khách.';

      case MarketCategory.lastGoal:
        return 'Kèo bàn thắng cuối cùng (last goal), lựa chọn bàn thắng cuối cùng được ghi thuộc về đội nhà hoặc đội khách.\nNgười chơi có thể chọn:\n • Bàn thắng cuối cùng thuộc đội nhà.\n • Bàn thắng cuối cùng thuộc đội khách.';

      case MarketCategory.toQualify:
        return 'Kèo cược đội vào vòng trong.\nNgười chơi có thể chọn:\n • Đội nhà vào vòng trong.\n • Đội khách vào vòng trong.';

      case MarketCategory.whichTeamKickOff:
        return 'Kèo cược đội giao bóng trước.\nNgười chơi có thể chọn:\n • Đội nhà giao bóng trước.\n • Đội khách giao bóng trước.';

      case MarketCategory.penaltyWinner:
        return 'Kèo cược đội thắng Penalty (loạt đá luân lưu).\nNgười chơi có thể chọn:\n • Đội nhà thắng Penalty.\n • Đội khách thắng Penalty.';

      case MarketCategory.whichTeamToScore:
        return 'Kèo cược đội ghi bàn thắng.\nNgười chơi có thể chọn:\n • Không có đội nào ghi bàn.\n • Chỉ đội nhà ghi bàn.\n • Chỉ đội khách ghi bàn.\n • Cả hai đội đều ghi bàn.';

      case MarketCategory.homeCleanSheet:
        return 'Kèo cược đội nhà giữ sạch lưới.\nNgười chơi có thể chọn:\n • Đội nhà giữ sạch lưới.\n • Đội nhà không giữ sạch lưới.';

      case MarketCategory.awayCleanSheet:
        return 'Kèo cược đội khách giữ sạch lưới.\nNgười chơi có thể chọn:\n • Đội khách giữ sạch lưới.\n • Đội khách không giữ sạch lưới.';

      case MarketCategory.lastCorner:
        return 'Kèo cược đội đá phạt góc cuối cùng.\nNgười chơi có thể chọn:\n • Đội nhà đá phạt góc cuối cùng.\n • Đội khách đá phạt góc cuối cùng.';

      case MarketCategory.corner1X2:
        return 'Kèo phạt góc Châu Âu dựa vào số lần phạt góc trong thời gian $period.\nNgười chơi có thể chọn:\n • 1 : đội nhà có số lần phạt góc nhiều hơn.\n • 2 : đội khách có số lần phạt góc nhiều hơn.\n • X : 2 đội có số lần phạt góc bằng nhau.';

      case MarketCategory.cornerOddEven:
        return 'Kèo cược tổng số lần phạt góc của hai đội là số chẵn hoặc số lẻ, trong thời gian $period.';

      case MarketCategory.cornerRange:
        return switch (data.marketId) {
          134 =>
            'Kèo cược tổng số lần phạt góc của đội nhà, trong thời gian $period.',
          135 =>
            'Kèo cược tổng số lần phạt góc của đội khách, trong thời gian $period.',
          _ => 'Kèo cược tổng số lần phạt góc trong thời gian $period.',
        };

      case MarketCategory.bookings1X2:
        return 'Kèo thẻ phạt Châu Âu dựa vào số thẻ phạt trong thời gian $period.\nThẻ vàng tính 1, thẻ đỏ tính 2.\nNgười chơi có thể chọn:\n • 1 : đội nhà có số thẻ phạt nhiều hơn.\n • 2 : đội khách có số thẻ phạt nhiều hơn.\n • X : 2 đội có số thẻ phạt bằng nhau.';

      case MarketCategory.outright:
        return switch (data.outrightKind) {
          OutrightKind.player => 'Kèo cược cầu thủ đoạt danh hiệu của giải đấu.',
          OutrightKind.team => 'Kèo cược đội lọt vào trận chung kết.',
          OutrightKind.groupWinner => 'Kèo cược đội đứng nhất bảng.',
          OutrightKind.goalscorerAnytime =>
            'Kèo cược cầu thủ ghi ít nhất 1 bàn trong 90 phút thi đấu chính thức (gồm bù giờ, không tính hiệp phụ; không tính bàn phản lưới nhà).',
          OutrightKind.goalscorerFirst =>
            'Kèo cược cầu thủ ghi bàn thắng đầu tiên của trận trong 90 phút thi đấu chính thức (bàn phản lưới nhà không được tính).',
          OutrightKind.goalscorerLast =>
            'Kèo cược cầu thủ ghi bàn thắng cuối cùng của trận trong 90 phút thi đấu chính thức (bàn phản lưới nhà không được tính).',
          OutrightKind.hatTrick =>
            'Kèo cược cầu thủ ghi từ 3 bàn trở lên trong 90 phút thi đấu chính thức (không tính bàn phản lưới nhà).',
          OutrightKind.matchSpecial =>
            'Kèo cược vào điều kiện hoặc tổ hợp sự kiện được mô tả trong lựa chọn, tính trong 90 phút thi đấu chính thức (gồm bù giờ, không tính hiệp phụ).',
          OutrightKind.champion => 'Kèo cược đội vô địch giải đấu.',
        };

      case MarketCategory.playerGoalscorer:
        return switch (data.marketId) {
          153 =>
            'Kèo cược cầu thủ ghi bàn thắng KẾ TIẾP của trận đấu.\nThắng nếu cầu thủ đã chọn là người ghi bàn tiếp theo.',
          1026 =>
            'Kèo cược cầu thủ ĐỘI NHÀ ghi bàn thắng kế tiếp của đội.\nCửa "no goal": đội nhà không ghi thêm bàn nào.',
          1027 =>
            'Kèo cược cầu thủ ĐỘI KHÁCH ghi bàn thắng kế tiếp của đội.\nCửa "no goal": đội khách không ghi thêm bàn nào.',
          156 =>
            'Kèo cược cầu thủ ghi từ 2 bàn trở lên trong trận đấu.\nThắng nếu cầu thủ đã chọn ghi ít nhất 2 bàn.',
          158 =>
            'Kèo cược cầu thủ ghi từ 3 bàn trở lên trong trận đấu.\nThắng nếu cầu thủ đã chọn ghi ít nhất 3 bàn.',
          _ =>
            'Kèo cược cầu thủ có ghi bàn trong trận đấu (bất kỳ thời điểm nào).\nThắng nếu cầu thủ đã chọn ghi ít nhất 1 bàn.',
        };

      case MarketCategory.halfTimeFullTime:
        return 'Kèo cược ĐỒNG THỜI kết quả hiệp 1 và kết quả cả trận. Đoán đúng cả hai mốc mới thắng, sai một trong hai là thua.\nLưu ý: vế thứ hai là kết quả chung cuộc của TOÀN TRẬN (90 phút), không phải kết quả của riêng hiệp 2.\nVí dụ cửa Hòa/Nhà: hết hiệp 1 hai đội hòa VÀ chung cuộc đội nhà thắng.';

      case MarketCategory.restOfMatchWinner:
        final rest = data.marketId == 1003 ? 'hiệp 1' : 'trận';
        return 'Kèo cược đội thắng PHẦN CÒN LẠI của $rest: tỉ số được tính lại từ 0-0 kể từ thời điểm kèo mở, các bàn đã ghi trước đó không tính.\nNgười chơi có thể chọn:\n • Đội nhà thắng phần còn lại.\n • Hòa: không đội nào hơn.\n • Đội khách thắng phần còn lại.';

      case MarketCategory.europeanNextGoal:
        return 'Kèo cược đội ghi BÀN THẮNG THỨ N của trận (N là con số cạnh tỷ lệ, ví dụ 2 = bàn thứ hai).\nNgười chơi có thể chọn:\n • Đội nhà ghi bàn thứ N.\n • Không có: bàn thứ N không xảy ra.\n • Đội khách ghi bàn thứ N.\nBàn phản lưới nhà được tính cho đội được hưởng bàn thắng trên bảng tỉ số.';

      case MarketCategory.europeanHandicapGoal:
        return 'Kèo chấp kiểu Châu Âu: cộng tỷ lệ chấp (dạng tỉ số, ví dụ 0:1 = đội khách được cộng 1 bàn) vào kết quả rồi tính như kèo 1X2, trong thời gian $period.\nKhác chấp Châu Á: có đủ 3 cửa kể cả cửa Hòa (tỉ số sau khi cộng chấp là hòa thì cửa Hòa thắng), và KHÔNG có hoàn tiền — đoán sai cửa là thua.';

      case MarketCategory.europeanHandicapCorner:
        return 'Kèo chấp phạt góc kiểu Châu Âu: cộng tỷ lệ chấp (dạng tỉ số, ví dụ 0:1 = đội khách được cộng 1 lần phạt góc) vào tổng phạt góc rồi tính như kèo 1X2.\nKhác chấp Châu Á: có đủ 3 cửa kể cả cửa Hòa, và KHÔNG có hoàn tiền — đoán sai cửa là thua.';

      case MarketCategory.cornerOverExactlyUnder:
        final oeuPeriod = switch (data.marketId) {
          140 => 'hiệp 1',
          141 => 'hiệp phụ',
          _ => '2 hiệp chính',
        };
        return 'Kèo tài xỉu phạt góc có thêm cửa CHÍNH XÁC, tính trong $oeuPeriod.\nNgười chơi có thể chọn:\n • Tài: tổng phạt góc CAO hơn mốc.\n • Chính xác: tổng phạt góc ĐÚNG BẰNG mốc.\n • Xỉu: tổng phạt góc THẤP hơn mốc.\nVì đã có cửa Chính xác nên cược Tài hoặc Xỉu sẽ thua hẳn khi tổng đúng bằng mốc.\nChỉ tính các quả phạt góc đã được thực hiện.';

      case MarketCategory.winToNil:
        final wtnTeam = data.marketId == 78 ? 'đội nhà' : 'đội khách';
        return 'Kèo cược $wtnTeam thắng trận VÀ giữ sạch lưới.\nNgười chơi có thể chọn:\n • Có: $wtnTeam thắng và không bị ghi bàn nào.\n • Không: $wtnTeam không thắng, hoặc có bị thủng lưới.';

      case MarketCategory.highestScoringHalf:
        final hshScope = switch (data.marketId) {
          87 => 'chỉ tính bàn thắng của đội nhà',
          88 => 'chỉ tính bàn thắng của đội khách',
          _ => 'tính bàn thắng của cả hai đội',
        };
        return 'Kèo cược hiệp đấu có nhiều bàn thắng hơn ($hshScope).\nNgười chơi có thể chọn:\n • Hiệp 1 nhiều bàn hơn.\n • Hòa: hai hiệp có số bàn bằng nhau.\n • Hiệp 2 nhiều bàn hơn.';

      case MarketCategory.exactCorner:
        final ecTeam = data.marketId == 198 ? 'đội nhà' : 'đội khách';
        return 'Kèo cược SỐ LẦN phạt góc chính xác của $ecTeam trong hiệp 1: chọn đúng con số (hoặc mốc "N trở lên") thì thắng.\nChỉ tính các quả phạt góc đã được thực hiện.';

      case MarketCategory.nextCorner3Way:
        final nc3Period = data.marketId == 199 ? ' trong hiệp 1' : '';
        return 'Kèo cược đội được hưởng quả PHẠT GÓC KẾ TIẾP$nc3Period.\nNgười chơi có thể chọn:\n • Đội nhà hưởng quả kế tiếp.\n • Không có: không còn quả phạt góc nào.\n • Đội khách hưởng quả kế tiếp.\nChỉ tính các quả phạt góc đã được thực hiện.';

      case MarketCategory.nextPenaltyScored:
        return 'Kèo cược quả PHẠT ĐỀN kế tiếp trong trận (không phải loạt đá luân lưu):\n • Có: quả phạt đền kế tiếp thành bàn.\n • Không: quả phạt đền kế tiếp bị sút hỏng hoặc bị cản phá.\nNếu không có quả phạt đền nào được thổi, vé thường được hoàn tiền theo quy định xử lý kèo.';

      case MarketCategory.combo:
        return switch (data.marketId) {
          82 =>
            'Kèo tổ hợp (combo): đoán ĐỒNG THỜI kết quả trận (thắng/hòa/thua) VÀ tài xỉu tổng bàn thắng theo mốc. Cả hai vế phải đúng mới thắng, sai một vế là thua toàn bộ.',
          81 =>
            'Kèo tổ hợp (combo): đoán ĐỒNG THỜI hai điều kiện — "cả hai đội có cùng ghi bàn hay không" VÀ kết quả trận (thắng/hòa/thua). Cả hai vế phải đúng mới thắng, sai một vế là thua toàn bộ.',
          _ =>
            'Kèo tổ hợp (combo): đoán ĐỒNG THỜI hai điều kiện — "cả hai đội có cùng ghi bàn hay không" VÀ kèo cơ hội kép (1X/12/X2). Cả hai vế phải đúng mới thắng, sai một vế là thua toàn bộ.',
        };

      case MarketCategory.yellowCards1X2:
        return 'Kèo Châu Âu 1X2 tính trên số THẺ VÀNG: đội nào bị nhiều thẻ vàng hơn trong 2 hiệp chính.\nChỉ đếm thẻ vàng rút cho cầu thủ đang thi đấu trên sân; thẻ cho HLV, ban huấn luyện hoặc cầu thủ dự bị không được tính.';

      case MarketCategory.yellowCardsOverUnder:
        return 'Kèo tài xỉu tổng số THẺ VÀNG của cả hai đội trong 2 hiệp chính.\nChỉ đếm thẻ vàng rút cho cầu thủ đang thi đấu trên sân; thẻ cho HLV, ban huấn luyện hoặc cầu thủ dự bị không được tính.';

      case MarketCategory.yellowCardsDoubleChance:
        return 'Kèo cơ hội kép (1X/12/X2) tính trên số THẺ VÀNG trong 2 hiệp chính.\nChỉ đếm thẻ vàng rút cho cầu thủ đang thi đấu trên sân; thẻ cho HLV, ban huấn luyện hoặc cầu thủ dự bị không được tính.';

      default:
        return 'Kèo cược trong thời gian $period.';
    }
  }

  static String _simplePeriod(Period period, int sportId) {
    if (period != Period.fullTime) return period.text;
    return switch (sportId) {
      1 => '2 hiệp chính',
      2 => 'trận đấu',
      _ => 'toàn trận',
    };
  }

  static String _unitWord(int sportId) {
    return switch (sportId) {
      1 => 'trái',
      2 || 5 || 7 => 'điểm',
      _ => 'game',
    };
  }

  static String _sumWord(int sportId) {
    return switch (sportId) {
      1 => 'bàn thắng',
      2 || 5 || 7 => 'điểm',
      _ => 'game',
    };
  }

  static String _scoreSub(int sportId) {
    return switch (sportId) {
      4 => ' game',
      5 || 7 => ' điểm',
      _ => '',
    };
  }

  static String _buildInfoText(HintData data) {
    final buffer = StringBuffer();

    if (data.market == MarketCategory.outright) {
      if (data.eventName.isNotEmpty) {
        buffer.writeln(data.eventName);
      }
      if (data.eventDate.isNotEmpty) {
        buffer.writeln(data.eventDate);
      }
      return buffer.toString().trim();
    }

    final handicapAbs = data.handicap.abs();

    if (data.market == MarketCategory.asianHandicap ||
        data.market == MarketCategory.cornerHandicap ||
        data.market == MarketCategory.bookingsHandicap) {
      if (handicapAbs < 0.001) {
        buffer.writeln(switch (data.market) {
          MarketCategory.cornerHandicap => 'Không chấp phạt góc.',
          MarketCategory.bookingsHandicap => 'Không chấp thẻ phạt.',
          _ => 'Trận đấu đồng banh.',
        });
      } else {
        final selectedIsGiving = data.handicap < 0;
        final isHomeBet = data.team == HintTeamType.home;
        final String overTeamName;
        if (selectedIsGiving) {
          overTeamName = isHomeBet ? data.homeName : data.awayName;
        } else {
          overTeamName = isHomeBet ? data.awayName : data.homeName;
        }
        final unit = switch (data.market) {
          MarketCategory.cornerHandicap => 'lần phạt góc',
          MarketCategory.bookingsHandicap => 'thẻ phạt',
          _ => _unitWord(data.sportId),
        };
        final teamPrefix = (data.sportId == 4 || data.sportId == 5)
            ? ''
            : 'Đội ';
        buffer.writeln(
          '$teamPrefix$overTeamName chấp ${_fmtNum(handicapAbs)} $unit'
          '${_handicapDetail(handicapAbs)}.',
        );
      }
    }

    if (data.market == MarketCategory.overUnder ||
        data.market == MarketCategory.cornerOverUnder ||
        data.market == MarketCategory.bookingsOverUnder) {
      final unit = switch (data.market) {
        MarketCategory.cornerOverUnder => 'lần phạt góc',
        MarketCategory.bookingsOverUnder => 'thẻ phạt',
        _ => _unitWord(data.sportId),
      };
      buffer.writeln(
        'Kèo Tài Xỉu ${_fmtNum(handicapAbs)} $unit'
        '${_handicapDetail(handicapAbs)}.',
      );
    }

    if (!data.isLive) {
      buffer.writeln('Trận đấu chưa bắt đầu.');
    } else {
      buffer.writeln(
        'Tỷ số${_scoreSub(data.sportId)} hiện tại: ${data.homeName} ${data.homeScore}-${data.awayScore} ${data.awayName}.',
      );
      if (_cornerInfoMarkets.contains(data.market)) {
        buffer.writeln(
          'Số lần phạt góc hiện tại: ${data.homeName} ${data.homeCorner}-${data.awayCorner} ${data.awayName}.',
        );
      } else if (_bookingsInfoMarkets.contains(data.market)) {
        buffer.writeln(
          'Số thẻ phạt hiện tại: ${data.homeName} ${data.homeBookings}-${data.awayBookings} ${data.awayName}.',
        );
      }
    }

    return buffer.toString().trim();
  }

  static const _cornerInfoMarkets = {
    MarketCategory.cornerHandicap,
    MarketCategory.cornerOverUnder,
    MarketCategory.corner1X2,
    MarketCategory.cornerRange,
  };

  static const _bookingsInfoMarkets = {
    MarketCategory.bookingsHandicap,
    MarketCategory.bookingsOverUnder,
    MarketCategory.bookings1X2,
  };

  static String _buildRatioText(HintData data) {
    final ratio = data.ratio;
    final style = data.style;
    final styleName = OddsCalculator.getStyleName(style);
    final winFormula = OddsCalculator.getWinFormula(ratio, style);
    final loseFormula = OddsCalculator.getLoseFormula(ratio, style);

    return '''Tỷ lệ cược ${ratio.toStringAsFixed(2)} ($styleName):
• Tiền thắng = $winFormula.
• Tiền thua = $loseFormula.''';
  }

  static String _buildResultText(HintData data) {
    final hintType = data.getHintType();
    final buffer = StringBuffer();

    if (_isHandicapType(hintType)) {
      buffer.writeln('Kết quả ${_handicapTitle(data)}:');
      for (final result in _handicapResults(hintType)) {
        buffer.writeln(' • $result.');
      }
      return buffer.toString().trim();
    }

    if (_isOverUnderType(hintType)) {
      buffer.writeln('Kết quả ${_overUnderTitle(data)}:');
      for (final result in _overUnderResults(hintType, data.isOver)) {
        buffer.writeln(' • $result.');
      }
      return buffer.toString().trim();
    }

    if (_otherMarkets.contains(data.market)) {
      return _buildOtherResultText(data);
    }

    final v6041Title = _v6041ResultTitle(data);
    if (v6041Title != null) {
      buffer.writeln('Kết quả $v6041Title:');
      buffer.writeln(' • Thắng.');
      buffer.writeln(' • Thua.');
      return buffer.toString().trim();
    }

    switch (hintType) {
      case HintType.market1X2:
        final periodCode = data.period.code;
        buffer.writeln(
          'Kết quả kèo 1X2 ${data.period.text}, cược ${data.selectionName} ($periodCode.${_get1X2Code(data)}):',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.oddEven:
        buffer.writeln(
          'Kết quả kèo Lẻ/Chẵn ${data.period.text}, cược ${data.selectionName}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.doubleChance:
        buffer.writeln(
          'Kết quả kèo Cơ Hội Kép ${data.period.text}, cược ${_getDoubleChanceName(data)} (${data.period.code}.${_getDoubleChanceCode(data)}):',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.moneyLine:
        buffer.writeln('Kết quả kèo đội thắng, cược ${data.teamName}:');
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.correctScore:
        buffer.writeln(
          'Kết quả kèo Tỷ Số chính xác ${data.period.text}, cược tỷ số [${data.teamName}]:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.totalScore:
        buffer.writeln(
          'Kết quả kèo Tổng bàn thắng ${data.period.text}, cược tổng bàn thắng ${_totalScoreLabel(data.teamName)}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.drawNoBet:
        buffer.writeln(
          'Kết quả kèo Hòa được hoàn tiền ${data.period.text}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Hoàn tiền cược.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.outright:
        final outrightTitle = switch (data.outrightKind) {
          OutrightKind.player => 'Kèo Cầu Thủ',
          OutrightKind.team => 'Kèo Đội Vào Chung Kết',
          OutrightKind.groupWinner => 'Kèo Đội Nhất Bảng',
          OutrightKind.goalscorerAnytime => 'Kèo Cầu Thủ Ghi Bàn',
          OutrightKind.goalscorerFirst => 'Kèo Cầu Thủ Ghi Bàn Đầu Tiên',
          OutrightKind.goalscorerLast => 'Kèo Cầu Thủ Ghi Bàn Cuối Cùng',
          OutrightKind.hatTrick => 'Kèo Cầu Thủ Lập Hat-trick',
          OutrightKind.matchSpecial => 'Kèo Đặc Biệt',
          OutrightKind.champion => 'Kèo Đội Vô Địch',
        };
        buffer.writeln('Kết quả $outrightTitle, cược ${data.teamName}:');
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      default:
        buffer.writeln('Kết quả kèo:');
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
    }

    return buffer.toString().trim();
  }

  static String _buildExampleText(HintData data) {
    final stake = data.stake > 0 ? data.stake : 100000.0;
    final win = OddsCalculator.calculateWin(stake, data.ratio, data.style);
    final lose = OddsCalculator.calculateLose(stake, data.ratio, data.style);
    final winHalf = OddsCalculator.calculateHalfWin(
      stake,
      data.ratio,
      data.style,
    );
    final loseHalf = OddsCalculator.calculateHalfLose(
      stake,
      data.ratio,
      data.style,
    );

    final hintType = data.getHintType();
    final buffer = StringBuffer();
    final caseCount = _threeWayOtherMarkets.contains(data.market)
        ? 3
        : data.getCaseCount();

    buffer.writeln(
      'Ví dụ cược ${_exampleSubject(data)} ${OddsCalculator.formatMoney(stake)}, có $caseCount trường hợp:',
    );

    if (_otherMarkets.contains(data.market)) {
      _writeOtherExample(buffer, data, win, lose);
      return buffer.toString().trim();
    }

    if (_isHandicapType(hintType)) {
      _writeHandicapExample(
        buffer,
        data,
        hintType,
        win,
        lose,
        winHalf,
        loseHalf,
      );
      return buffer.toString().trim();
    }

    if (_isOverUnderType(hintType)) {
      _writeOverUnderExample(
        buffer,
        data,
        hintType,
        win,
        lose,
        winHalf,
        loseHalf,
      );
      return buffer.toString().trim();
    }

    switch (hintType) {
      case HintType.market1X2:
        buffer.writeln(
          ' • TH1: ${_get1X2WinCondition(data)} → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.oddEven:
        final examples = data.isEven ? '0, 2, 4, ...' : '1, 3, 5, ...';
        buffer.writeln(
          ' • TH1: Tổng bàn thắng là số ${data.selectionName.toLowerCase()} (vd: $examples) → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.doubleChance:
        buffer.writeln(
          ' • TH1: ${_getDoubleChanceWinCondition(data)} → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.moneyLine:
        buffer.writeln(
          ' • TH1: ${data.teamName} thắng → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.correctScore:
        buffer.writeln(
          ' • TH1: Tỷ số chính xác là [${data.teamName}] → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.totalScore:
        buffer.writeln(
          ' • TH1: Tổng bàn thắng là ${_totalScoreLabel(data.teamName)} → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.drawNoBet:
        buffer.writeln(
          ' • TH1: ${data.teamName} thắng → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(' • TH2: Hòa → hoàn tiền cược.');
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.outright:
        final outrightWin = switch (data.outrightKind) {
          OutrightKind.player => '${data.teamName} đoạt danh hiệu',
          OutrightKind.team => '${data.teamName} lọt vào chung kết',
          OutrightKind.groupWinner => '${data.teamName} đứng nhất bảng',
          OutrightKind.goalscorerAnytime => '${data.teamName} ghi bàn',
          OutrightKind.goalscorerFirst => '${data.teamName} ghi bàn đầu tiên',
          OutrightKind.goalscorerLast => '${data.teamName} ghi bàn cuối cùng',
          OutrightKind.hatTrick => '${data.teamName} lập hat-trick',
          OutrightKind.matchSpecial => 'toàn bộ điều kiện trong lựa chọn xảy ra',
          OutrightKind.champion => '${data.teamName} vô địch',
        };
        buffer.writeln(
          ' • TH1: $outrightWin → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      default:
        buffer.writeln(' • TH1: Thắng → ${OddsCalculator.formatMoney(win)}.');
        buffer.writeln(' • TH2: Thua → ${OddsCalculator.formatMoney(lose)}.');
    }

    return buffer.toString().trim();
  }

  static String _handicapTitle(HintData data) {
    final absHc = data.handicap.abs();
    final direction = data.handicap > 0 ? 'dưới' : 'trên';

    switch (data.market) {
      case MarketCategory.cornerHandicap:
        return absHc < 0.001
            ? 'Phạt Góc Kèo Chấp bằng nhau'
            : 'Phạt Góc Kèo Chấp ${_fmtNum(absHc)}, bắt kèo $direction';
      case MarketCategory.bookingsHandicap:
        return absHc < 0.001
            ? 'Thẻ Phạt Kèo Chấp bằng nhau'
            : 'Thẻ Phạt Kèo Chấp ${_fmtNum(absHc)}, bắt kèo $direction';
      default:
        return absHc < 0.001
            ? 'Kèo Chấp đồng banh'
            : 'Kèo Chấp ${_fmtNum(absHc)} ${_unitWord(data.sportId)}, bắt kèo $direction';
    }
  }

  static List<String> _handicapResults(HintType type) {
    switch (type) {
      case HintType.asianHandicapRound:
        return ['Thắng', 'Hoàn tiền cược', 'Thua'];
      case HintType.asianHandicapHalf:
        return ['Thắng', 'Thua'];
      case HintType.asianHandicapQuarterOver:
        return ['Thắng', 'Thua nửa tiền', 'Thua'];
      case HintType.asianHandicapQuarterUnder:
        return ['Thắng', 'Thắng nửa tiền', 'Thua'];
      case HintType.asianHandicap3QuarterOver:
        return ['Thắng', 'Thắng nửa tiền', 'Thua'];
      case HintType.asianHandicap3QuarterUnder:
        return ['Thắng', 'Thua nửa tiền', 'Thua'];
      default:
        return ['Thắng', 'Thua'];
    }
  }

  static void _writeHandicapExample(
    StringBuffer buffer,
    HintData data,
    HintType hintType,
    double win,
    double lose,
    double winHalf,
    double loseHalf,
  ) {
    final h = data.handicap;
    final h1f = _handicapPlus1Floor(h);
    final isHomeBet = data.team == HintTeamType.home;
    final name = data.teamName;

    final (int sel, int other) = switch (data.market) {
      MarketCategory.cornerHandicap => isHomeBet
          ? (data.homeCorner, data.awayCorner)
          : (data.awayCorner, data.homeCorner),
      MarketCategory.bookingsHandicap => isHomeBet
          ? (data.homeBookings, data.awayBookings)
          : (data.awayBookings, data.homeBookings),
      _ => isHomeBet
          ? (data.homeScore, data.awayScore)
          : (data.awayScore, data.homeScore),
    };

    final diff = switch (hintType) {
      HintType.asianHandicapRound => h <= 0
          ? sel - other + h1f
          : sel - other - h1f + 2,
      HintType.asianHandicapHalf => h <= 0
          ? sel - other + h1f
          : sel - other - h1f + 1,
      HintType.asianHandicapQuarterOver => sel - other + h1f,
      HintType.asianHandicapQuarterUnder => sel - other - h1f + 2,
      HintType.asianHandicap3QuarterOver => sel - other + h1f + 1,
      HintType.asianHandicap3QuarterUnder => sel - other - h1f + 1,
      _ => 0,
    };

    final winCond = _diffText(data.market, data.sportId, name, true, diff);
    final midCond = _diffText(data.market, data.sportId, name, false, diff - 1);
    final winMoney = OddsCalculator.formatMoney(win);
    final loseMoney = OddsCalculator.formatMoney(lose);
    final winHalfMoney = OddsCalculator.formatMoney(winHalf);
    final loseHalfMoney = OddsCalculator.formatMoney(loseHalf);

    switch (hintType) {
      case HintType.asianHandicapRound:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • TH2: $midCond → hoàn tiền cược.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      case HintType.asianHandicapHalf:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      case HintType.asianHandicapQuarterOver:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • TH2: $midCond → thua $loseHalfMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      case HintType.asianHandicapQuarterUnder:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • TH2: $midCond → thắng $winHalfMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      case HintType.asianHandicap3QuarterOver:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • TH2: $midCond → thắng $winHalfMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      case HintType.asianHandicap3QuarterUnder:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • TH2: $midCond → thua $loseHalfMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      default:
        break;
    }
  }

  static String _overUnderTitle(HintData data) {
    final absHc = _fmtNum(data.handicap.abs());
    final direction = data.selectionName;
    switch (data.market) {
      case MarketCategory.cornerOverUnder:
        return 'kèo Phạt Góc Tài Xỉu $absHc, bắt $direction';
      case MarketCategory.bookingsOverUnder:
        return 'kèo Thẻ Phạt Tài Xỉu $absHc, bắt $direction';
      default:
        return 'kèo Tài Xỉu $absHc ${_unitWord(data.sportId)}, bắt $direction';
    }
  }

  static List<String> _overUnderResults(HintType type, bool isOver) {
    switch (type) {
      case HintType.overUnderRound:
        return ['Thắng', 'Hoàn tiền cược', 'Thua'];
      case HintType.overUnderHalf:
        return ['Thắng', 'Thua'];
      case HintType.overUnderQuarter:
        return ['Thắng', isOver ? 'Thua nửa tiền' : 'Thắng nửa tiền', 'Thua'];
      case HintType.overUnder3Quarter:
        return ['Thắng', isOver ? 'Thắng nửa tiền' : 'Thua nửa tiền', 'Thua'];
      default:
        return ['Thắng', 'Thua'];
    }
  }

  static void _writeOverUnderExample(
    StringBuffer buffer,
    HintData data,
    HintType hintType,
    double win,
    double lose,
    double winHalf,
    double loseHalf,
  ) {
    final isOver = data.isOver;
    final h1f = _handicapPlus1Floor(data.handicap);
    final sum = switch (data.market) {
      MarketCategory.cornerOverUnder => 'Tổng số lần phạt góc',
      MarketCategory.bookingsOverUnder => 'Tổng số thẻ phạt',
      MarketCategory.homeOverUnder =>
        'Số ${_sumWord(data.sportId)} của ${data.homeName}',
      MarketCategory.awayOverUnder =>
        'Số ${_sumWord(data.sportId)} của ${data.awayName}',
      _ => 'Tổng số ${_sumWord(data.sportId)}',
    };
    final winMoney = OddsCalculator.formatMoney(win);
    final loseMoney = OddsCalculator.formatMoney(lose);

    switch (hintType) {
      case HintType.overUnderRound:
        var winValue = h1f;
        var sign = '≥';
        var drawValue = winValue - 1;
        if (!isOver) {
          winValue -= 2;
          sign = winValue > 0 ? '≤' : '=';
          drawValue = winValue + 1;
        }
        buffer.writeln(' • TH1: $sum $sign $winValue → thắng $winMoney.');
        buffer.writeln(' • TH2: $sum = $drawValue → hoàn tiền cược.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;

      case HintType.overUnderHalf:
        var winValue = h1f;
        var sign = '≥';
        if (!isOver) {
          winValue -= 1;
          sign = winValue > 0 ? '≤' : '=';
        }
        buffer.writeln(' • TH1: $sum $sign $winValue → thắng $winMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;

      case HintType.overUnderQuarter:
      case HintType.overUnder3Quarter:
        final is3Q = hintType == HintType.overUnder3Quarter;
        var winValue = h1f + (is3Q ? 1 : 0);
        var sign = '≥';
        var midValue = winValue - 1;
        var midIsWin = is3Q;
        if (!isOver) {
          winValue -= 2;
          sign = winValue > 0 ? '≤' : '=';
          midValue = winValue + 1;
          midIsWin = !is3Q;
        }
        final midMoney = midIsWin
            ? 'thắng ${OddsCalculator.formatMoney(winHalf)}'
            : 'thua ${OddsCalculator.formatMoney(loseHalf)}';
        buffer.writeln(' • TH1: $sum $sign $winValue → thắng $winMoney.');
        buffer.writeln(' • TH2: $sum = $midValue → $midMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;

      default:
        break;
    }
  }

  static bool _isHandicapType(HintType type) {
    return type == HintType.asianHandicapRound ||
        type == HintType.asianHandicapHalf ||
        type == HintType.asianHandicapQuarterOver ||
        type == HintType.asianHandicapQuarterUnder ||
        type == HintType.asianHandicap3QuarterOver ||
        type == HintType.asianHandicap3QuarterUnder;
  }

  static bool _isOverUnderType(HintType type) {
    return type == HintType.overUnderRound ||
        type == HintType.overUnderHalf ||
        type == HintType.overUnderQuarter ||
        type == HintType.overUnder3Quarter;
  }

  static int _handicapPlus1Floor(double handicap) =>
      (handicap.abs() + 1).floor();

  static String _fmtNum(num value) {
    if (value == value.truncate()) return value.truncate().toString();
    return value.toString();
  }

  static String _handicapDetail(double handicapAbs) {
    final n = handicapAbs.floor();
    final fraction = handicapAbs - n;
    double a = n.toDouble();
    double b = n.toDouble();
    if ((fraction - 0.25).abs() < 0.001) {
      b += 0.5;
    } else if ((fraction - 0.75).abs() < 0.001) {
      a += 0.5;
      b += 1;
    }
    if (a == b) return '';
    return ' (${_fmtNum(a)}-${_fmtNum(b)})';
  }

  static String _diffText(
    MarketCategory market,
    int sportId,
    String team,
    bool isGreaterEqual,
    int diff,
  ) {
    switch (market) {
      case MarketCategory.cornerHandicap:
        return _getCornerText(team, isGreaterEqual, diff);
      case MarketCategory.bookingsHandicap:
        return _getBookingsText(team, isGreaterEqual, diff);
      default:
        return _getScoreText(team, isGreaterEqual, diff, _unitWord(sportId));
    }
  }

  static String _getScoreText(
    String team,
    bool isGreaterEqual,
    int diff,
    String sub,
  ) {
    if (isGreaterEqual) {
      if (diff > 1) return '$team thắng cách biệt ≥ $diff $sub';
      if (diff == 1) return '$team thắng';
      if (diff == 0) return '$team thắng hoặc hoà';
      return '$team không thua cách biệt hơn ${-diff} $sub';
    } else {
      if (diff >= 1) return '$team thắng cách biệt $diff $sub';
      if (diff == 0) return 'Hòa';
      return '$team thua cách biệt ${-diff} $sub';
    }
  }

  static String _getCornerText(String team, bool isGreaterEqual, int diff) {
    if (isGreaterEqual) {
      if (diff > 1) return '$team có số lần phạt góc cách biệt ≥ $diff';
      if (diff == 1) return '$team có số lần phạt góc cách biệt nhiều hơn';
      if (diff == 0) return '$team có số lần phạt góc nhiều hơn hoặc bằng';
      return '$team có số lần phạt góc không thua cách biệt hơn ${-diff}';
    } else {
      if (diff >= 1) return '$team có số lần phạt góc cách biệt $diff lần';
      if (diff == 0) return '2 đội có số lần phạt góc bằng nhau';
      return '$team có số lần phạt góc cách biệt ít hơn ${-diff} lần';
    }
  }

  static String _getBookingsText(String team, bool isGreaterEqual, int diff) {
    if (isGreaterEqual) {
      if (diff > 1) return '$team có số thẻ phạt cách biệt ≥ $diff';
      if (diff == 1) return '$team có số thẻ phạt cách biệt nhiều hơn';
      if (diff == 0) return '$team có số thẻ phạt nhiều hơn hoặc bằng';
      return '$team có số thẻ phạt không thua cách biệt hơn ${-diff}';
    } else {
      if (diff >= 1) return '$team có số thẻ phạt cách biệt $diff lần';
      if (diff == 0) return '2 đội có số thẻ phạt bằng nhau';
      return '$team có số thẻ phạt cách biệt ít hơn ${-diff} lần';
    }
  }

  static String _get1X2Code(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return '1';
      case HintTeamType.away:
        return '2';
      case HintTeamType.draw:
        return 'X';
      default:
        return '';
    }
  }

  static String _get1X2WinCondition(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return '${data.homeName} thắng';
      case HintTeamType.away:
        return '${data.awayName} thắng';
      case HintTeamType.draw:
        return 'Hòa';
      default:
        return '';
    }
  }

  static String _getDoubleChanceName(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return 'Đội nhà hoặc hoà';
      case HintTeamType.away:
        return 'Đội khách hoặc hoà';
      case HintTeamType.draw:
        return 'Đội nhà hoặc khách';
      default:
        return '';
    }
  }

  static String _getDoubleChanceCode(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return '1X';
      case HintTeamType.away:
        return 'X2';
      case HintTeamType.draw:
        return '12';
      default:
        return '';
    }
  }

  static String _exampleSubject(HintData data) {
    switch (data.getHintType()) {
      case HintType.correctScore:
        return 'tỷ số [${data.teamName}]';
      case HintType.totalScore:
        return 'tổng bàn thắng ${_totalScoreLabel(data.teamName)}';
      default:
        break;
    }
    switch (data.market) {
      case MarketCategory.corner1X2:
      case MarketCategory.bookings1X2:
        return _oneX2Name(data);
      case MarketCategory.cornerOddEven:
        return _cornerOddEvenName(data);
      case MarketCategory.cornerRange:
        return 'tổng ${_cornerRangeSum(data)} ${_totalScoreLabel(data.teamName)}';
      case MarketCategory.homeCleanSheet:
      case MarketCategory.awayCleanSheet:
        return _cleanSheetSelection(data);
      case MarketCategory.whichTeamToScore:
        return _whichTeamToScoreSelection(data);
      default:
        return data.selectionName;
    }
  }

  static String _totalScoreLabel(String value) {
    return value.length > 1 ? '[$value]' : '($value)';
  }

  static const _otherMarkets = {
    MarketCategory.nextGoal,
    MarketCategory.lastGoal,
    MarketCategory.lastCorner,
    MarketCategory.toQualify,
    MarketCategory.penaltyWinner,
    MarketCategory.whichTeamKickOff,
    MarketCategory.whichTeamToScore,
    MarketCategory.homeCleanSheet,
    MarketCategory.awayCleanSheet,
    MarketCategory.corner1X2,
    MarketCategory.cornerOddEven,
    MarketCategory.cornerRange,
    MarketCategory.bookings1X2,
  };

  static String? _v6041ResultTitle(HintData data) {
    switch (data.market) {
      case MarketCategory.halfTimeFullTime:
        return 'kèo Hiệp 1/Toàn trận, cược ${data.teamName}';
      case MarketCategory.restOfMatchWinner:
        final restSel = switch (data.team) {
          HintTeamType.home => data.homeName,
          HintTeamType.away => data.awayName,
          _ => 'Hòa',
        };
        return 'kèo Đội thắng thời gian còn lại, cược $restSel';
      case MarketCategory.europeanNextGoal:
        final engSel = switch (data.team) {
          HintTeamType.home => data.homeName,
          HintTeamType.away => data.awayName,
          _ => 'Không có bàn thắng',
        };
        return 'kèo Đội tiếp theo ghi bàn (Châu Âu), cược $engSel';
      case MarketCategory.europeanHandicapGoal:
        return 'kèo Chấp châu Âu, cược ${data.teamName}';
      case MarketCategory.europeanHandicapCorner:
        return 'kèo Chấp phạt góc châu Âu, cược ${data.teamName}';
      case MarketCategory.cornerOverExactlyUnder:
        final oeuSel = switch (data.team) {
          HintTeamType.home => 'Tài',
          HintTeamType.away => 'Xỉu',
          _ => 'Chính xác',
        };
        return 'kèo Phạt góc Tài/Chính xác/Xỉu, cược $oeuSel';
      case MarketCategory.winToNil:
        final wtnSel = data.team == HintTeamType.home ? 'Có' : 'Không';
        return 'kèo Thắng giữ sạch lưới, cược $wtnSel';
      case MarketCategory.highestScoringHalf:
        final hshSel = switch (data.team) {
          HintTeamType.home => 'Hiệp 1',
          HintTeamType.away => 'Hiệp 2',
          _ => 'Hòa',
        };
        return 'kèo Hiệp nhiều bàn thắng nhất, cược $hshSel';
      case MarketCategory.exactCorner:
        return 'kèo Số phạt góc chính xác, cược ${data.teamName}';
      case MarketCategory.nextCorner3Way:
        final nc3Sel = switch (data.team) {
          HintTeamType.home => data.homeName,
          HintTeamType.away => data.awayName,
          _ => 'Không có phạt góc',
        };
        return 'kèo Phạt góc tiếp theo, cược $nc3Sel';
      case MarketCategory.nextPenaltyScored:
        final npsSel = data.team == HintTeamType.home ? 'Có' : 'Không';
        return 'kèo Quả phạt đền tiếp theo ghi bàn, cược $npsSel';
      case MarketCategory.combo:
        return 'kèo tổ hợp, cược ${data.teamName}';
      case MarketCategory.yellowCards1X2:
        return 'kèo Thẻ vàng 1X2, cược ${data.teamName}';
      case MarketCategory.yellowCardsOverUnder:
        final ycSel = data.team == HintTeamType.home ? 'Tài' : 'Xỉu';
        return 'kèo Thẻ vàng Tài/Xỉu, cược $ycSel';
      case MarketCategory.yellowCardsDoubleChance:
        final ycdcSel = switch (data.team) {
          HintTeamType.home => '1X',
          HintTeamType.away => 'X2',
          _ => '12',
        };
        return 'kèo Thẻ vàng Cơ hội kép, cược $ycdcSel';
      default:
        return null;
    }
  }

  static const _threeWayOtherMarkets = {
    MarketCategory.nextGoal,
    MarketCategory.lastGoal,
    MarketCategory.lastCorner,
  };

  static String _buildOtherResultText(HintData data) {
    final period = data.period.text;
    final buffer = StringBuffer();

    final title = switch (data.market) {
      MarketCategory.nextGoal => 'kèo Bàn thắng kế tiếp',
      MarketCategory.lastGoal => 'kèo Bàn thắng cuối cùng',
      MarketCategory.lastCorner => 'kèo Phạt góc cuối cùng',
      MarketCategory.toQualify => 'kèo Đội vào vòng trong',
      MarketCategory.penaltyWinner => 'kèo Đội thắng Penalty',
      MarketCategory.whichTeamKickOff => 'kèo Đội giao bóng trước',
      MarketCategory.whichTeamToScore =>
        'kèo Đội ghi bàn thắng, cược ${_whichTeamToScoreSelection(data)}',
      MarketCategory.homeCleanSheet =>
        'kèo Đội nhà giữ sạch lưới, cược ${_cleanSheetSelection(data)}',
      MarketCategory.awayCleanSheet =>
        'kèo Đội khách giữ sạch lưới, cược ${_cleanSheetSelection(data)}',
      MarketCategory.corner1X2 =>
        'kèo Phạt Góc 1X2 $period, cược ${_oneX2Name(data)}',
      MarketCategory.cornerOddEven =>
        'kèo Phạt Góc Lẻ/Chẵn $period, cược ${_cornerOddEvenName(data)}',
      MarketCategory.cornerRange =>
        'kèo Tổng ${_cornerRangeSum(data)} $period, cược tổng ${_cornerRangeSum(data)} ${_totalScoreLabel(data.teamName)}',
      MarketCategory.bookings1X2 =>
        'kèo Thẻ Phạt 1X2 $period, cược ${_oneX2Name(data)}',
      _ => 'kèo',
    };

    buffer.writeln('Kết quả $title:');
    buffer.writeln(' • Thắng.');
    if (_threeWayOtherMarkets.contains(data.market)) {
      buffer.writeln(' • Hoàn tiền cược.');
    }
    buffer.writeln(' • Thua.');
    return buffer.toString().trim();
  }

  static void _writeOtherExample(
    StringBuffer buffer,
    HintData data,
    double win,
    double lose,
  ) {
    final winMoney = OddsCalculator.formatMoney(win);
    final loseMoney = OddsCalculator.formatMoney(lose);
    final name = data.teamName;

    final winCondition = switch (data.market) {
      MarketCategory.nextGoal => 'Bàn thắng kế tiếp thuộc đội $name',
      MarketCategory.lastGoal => 'Bàn thắng cuối cùng thuộc đội $name',
      MarketCategory.lastCorner => '$name đá phạt góc cuối cùng',
      MarketCategory.toQualify => '$name vào vòng trong',
      MarketCategory.penaltyWinner => '$name thắng Penalty',
      MarketCategory.whichTeamKickOff => '$name giao bóng trước',
      MarketCategory.whichTeamToScore => _whichTeamToScoreSelection(data),
      MarketCategory.homeCleanSheet =>
        '${data.homeName} ${_cleanSheetSelection(data)}',
      MarketCategory.awayCleanSheet =>
        '${data.awayName} ${_cleanSheetSelection(data)}',
      MarketCategory.corner1X2 => _oneX2WinCondition(data, 'lần phạt góc'),
      MarketCategory.bookings1X2 => _oneX2WinCondition(data, 'thẻ phạt'),
      MarketCategory.cornerOddEven =>
        'Tổng số lần phạt góc là số ${_oddEvenExample(data.team == HintTeamType.away)}',
      MarketCategory.cornerRange =>
        'Tổng ${_cornerRangeSum(data)} là ${_totalScoreLabel(data.teamName)}',
      _ => '',
    };

    buffer.writeln(' • TH1: $winCondition → thắng $winMoney.');
    if (_threeWayOtherMarkets.contains(data.market)) {
      final refund = switch (data.market) {
        MarketCategory.nextGoal => 'Không có bàn thắng kế tiếp',
        MarketCategory.lastGoal => 'Không có bàn thắng cuối cùng',
        MarketCategory.lastCorner => 'Không có đội nào đá phạt góc cuối cùng',
        _ => '',
      };
      buffer.writeln(' • TH2: $refund → hoàn tiền cược.');
    }
    buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
  }

  static String _oneX2Name(HintData data) {
    switch (data.team) {
      case HintTeamType.away:
        return data.awayName;
      case HintTeamType.draw:
        return 'Hoà';
      default:
        return data.homeName;
    }
  }

  static String _oneX2WinCondition(HintData data, String unit) {
    if (data.team == HintTeamType.draw) {
      return '2 đội có số $unit bằng nhau';
    }
    final name = data.team == HintTeamType.away ? data.awayName : data.homeName;
    return '$name có số $unit nhiều hơn';
  }

  static String _cornerOddEvenName(HintData data) {
    return data.team == HintTeamType.away ? 'Chẵn' : 'Lẻ';
  }

  static String _cornerRangeSum(HintData data) {
    switch (data.marketId) {
      case 134:
        return 'số lần phạt góc của ${data.homeName}';
      case 135:
        return 'số lần phạt góc của ${data.awayName}';
      default:
        return 'số lần phạt góc';
    }
  }

  static String _oddEvenExample(bool isEven) {
    return isEven ? 'chẵn (vd: 0, 2, 4, ...)' : 'lẻ (vd: 1, 3, 5, ...)';
  }

  static String _cleanSheetSelection(HintData data) {
    return data.team == HintTeamType.home
        ? 'giữ sạch lưới'
        : 'không giữ sạch lưới';
  }

  static String _whichTeamToScoreSelection(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return 'chỉ đội nhà ghi bàn';
      case HintTeamType.away:
        return 'chỉ đội khách ghi bàn';
      case HintTeamType.draw:
        return 'cả hai đội đều ghi bàn';
      default:
        return 'không đội nào ghi bàn';
    }
  }

  static String _getDoubleChanceWinCondition(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return '${data.homeName} thắng hoặc hòa';
      case HintTeamType.away:
        return '${data.awayName} thắng hoặc hòa';
      case HintTeamType.draw:
        return '${data.homeName} thắng hoặc ${data.awayName} thắng';
      default:
        return '';
    }
  }
}

class HintContent {
  final String simpleText;
  final String infoText;
  final String ratioText;
  final String resultText;
  final String exampleText;

  final String homeName;
  final String awayName;

  const HintContent({
    required this.simpleText,
    required this.infoText,
    required this.ratioText,
    required this.resultText,
    required this.exampleText,
    this.homeName = '',
    this.awayName = '',
  });

  String get fullText {
    return '$simpleText\n\n$infoText\n\n$ratioText\n\n$resultText\n\n$exampleText';
  }
}
