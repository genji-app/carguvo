library;

class MauBinhCard {
  final int n;

  final int s;

  const MauBinhCard(this.n, this.s);

  factory MauBinhCard.decode(int code) {
    final s = code % 4 + 1;
    var n = (code ~/ 4) + 1;
    if (n == 1) n = 14;
    return MauBinhCard(n, s);
  }

  String get porkerSuitName => switch (s) {
    1 => 'spade',
    2 => 'club',
    3 => 'diamond',
    _ => 'heart',
  };

  bool get isRedSuit => s == 3 || s == 4;

  String get porkerRank => switch (n) {
    11 => 'j',
    12 => 'q',
    13 => 'k',
    14 => 'a',
    _ => '$n',
  };

  String get faceAssetName => 'porker_${porkerSuitName}_$porkerRank';

  String get label => switch (n) {
    11 => 'J',
    12 => 'Q',
    13 => 'K',
    14 => 'A',
    _ => '$n',
  };

  int get reelRank => n == 14 ? 1 : n;
}

enum MauBinhResult {
  thungPhaSanh,
  tuQuy,
  cuLu,
  thung,
  sanh,
  xamCo,
  thu,
  doi,
  mauThau,
}

class MauBinhCardLib {
  MauBinhCardLib._();

  static const List<String> _resultStrings = [
    'Thùng phá sảnh',
    'Tứ quý',
    'Cù lũ',
    'Thùng',
    'Sảnh',
    'Xám',
    'Hai đôi',
    'Đôi J trở lên',
    'Mậu thầu',
  ];

  static List<MauBinhCard> _sortByN(List<MauBinhCard> v) {
    final list = List<MauBinhCard>.from(v);
    list.sort((a, b) => a.n > b.n ? 1 : -1);
    return list;
  }

  static List<MauBinhCard> _sortBySN(List<MauBinhCard> v) {
    final list = List<MauBinhCard>.from(v);
    list.sort((a, b) {
      if (a.s > b.s || (a.s == b.s && a.n > b.n)) return 1;
      return -1;
    });
    return list;
  }

  static int _indexA(List<MauBinhCard> hand) {
    for (var i = 0; i < hand.length; i++) {
      if (hand[i].n == 14) return i;
    }
    return 0;
  }

  static int _checkThung(List<MauBinhCard> input) {
    if (input.length == 3) return 0;
    var check = 0;
    var sum = 0;
    final hand = _sortBySN(input);
    final thung = <MauBinhCard>[];

    for (var i = 0; i < hand.length - 1; i++) {
      for (var j = i + 1; j < hand.length; j++) {
        if ((hand[i].s - hand[j].s) == 0) {
          check++;
        } else {
          break;
        }
      }
      if (check != 4) check = 0;
      if (check == 4) {
        thung
          ..add(hand[i])
          ..add(hand[i + 1])
          ..add(hand[i + 2])
          ..add(hand[i + 3])
          ..add(hand[i + 4]);
        break;
      }
    }
    if (thung.length == 5) {
      sum = 5 * 68 + hand[4].n;
      return sum;
    }
    return sum;
  }

  static int _checkSanh(List<MauBinhCard> input) {
    if (input.length == 3) return 0;
    var check = 0;
    var sum = 0;
    final hand = _sortByN(input);
    var sanh = <MauBinhCard>[];

    for (var i = 0; i < hand.length - 1; i++) {
      if (hand[i + 1].n - hand[i].n > 1) {
        check = 0;
        sanh = <MauBinhCard>[];
      } else {
        check = check + hand[i + 1].n - hand[i].n;
        if (hand[i + 1].n - hand[i].n == 1) {
          sanh.add(hand[i]);
          if (i == hand.length - 2) {
            sanh.add(hand[i + 1]);
            check++;
          }
        }
      }
      if (check == 3) {
        if (sanh[2].n == 4 && _indexA(hand) > 0) {
          sanh.add(hand[i + 1]);
          sanh.add(hand[_indexA(hand)]);
          check = 5;
          break;
        }
      }
      if (check == 4) {
        if (sanh[3].n == 5 && _indexA(hand) > 0) {
          sanh.add(hand[_indexA(hand)]);
          check++;
          break;
        } else {
          sanh.add(hand[i + 1]);
          check++;
          break;
        }
      }
      if (check == 5) break;
    }

    if (check == 5) {
      if (_indexA(hand) > 0) {
        if (sanh[0].n == 10) {
          sum = 4 * 68 + 14;
        } else if (sanh[0].n == 2) {
          sum = 4 * 68 + 5;
        } else {
          sum = 4 * 68 + sanh[4].n;
        }
      } else {
        sum = 4 * 68 + sanh[4].n;
      }
    }
    return sum;
  }

  static int _checkTPS(List<MauBinhCard> input) {
    if (input.length == 3) return 0;
    var sum = 0;
    final hand = _sortByN(input);
    if (_checkThung(hand) > 0 && _checkSanh(hand) > 0) {
      sum = 8 * 68 + hand[4].n;
    }
    return sum;
  }

  static int _checkCuLu(List<MauBinhCard> input) {
    if (input.length == 3) return 0;
    var check = 0;
    var sum = 0;
    final hand = _sortByN(input);
    final culu = <MauBinhCard>[];

    for (var i = 0; i < hand.length - 1; i++) {
      for (var j = i + 1; j < hand.length; j++) {
        if (hand[i].n == hand[j].n) {
          check++;
        } else {
          break;
        }
      }
      if (check != 2) check = 0;
      if (check == 2) {
        culu
          ..add(hand[i])
          ..add(hand[i + 1])
          ..add(hand[i + 2]);
        check = 0;
        break;
      }
    }
    for (final card in culu) {
      hand.remove(card);
    }
    for (var i = 0; i < hand.length - 1; i++) {
      if (hand[i].n == hand[i + 1].n) {
        culu.add(hand[i]);
        culu.add(hand[i + 1]);
        hand.removeAt(i);
        hand.removeAt(i);
        break;
      }
    }

    if (culu.length == 5) {
      return 6 * 68 + culu[0].n;
    }
    return sum;
  }

  static int _checkTuQuy(List<MauBinhCard> input) {
    if (input.length == 3) return 0;
    var check = 0;
    var sum = 0;
    var hand = _sortByN(input);
    final tuquy = <MauBinhCard>[];

    for (var i = 0; i < hand.length - 1; i++) {
      for (var j = i + 1; j < hand.length; j++) {
        if ((hand[i].n - hand[j].n) % 13 == 0) {
          check++;
        } else {
          break;
        }
      }
      if (check != 3) check = 0;
      if (check == 3) {
        tuquy
          ..add(hand[i])
          ..add(hand[i + 1])
          ..add(hand[i + 2])
          ..add(hand[i + 3]);
        break;
      }
    }
    for (final card in tuquy) {
      final idx = hand.indexOf(card);
      if (idx >= 0) {
        final removed = hand[idx];
        hand = <MauBinhCard>[removed];
      }
    }
    if (tuquy.length == 4) {
      if (hand.isNotEmpty) tuquy.add(hand[0]);
    }
    if (tuquy.length == 5) {
      return 7 * 68 + tuquy[0].n;
    }
    return sum;
  }

  static int _checkDoi(List<MauBinhCard> input) {
    var sum = 0;
    final hand = _sortByN(input);
    for (var i = 0; i < hand.length - 1; i++) {
      if (hand[i].n == hand[i + 1].n) {
        sum = 1 * 68 + hand[i].n;
        hand.removeAt(i);
        hand.removeAt(i);
        break;
      }
    }
    return sum;
  }

  static int _checkThu(List<MauBinhCard> input) {
    if (input.length == 3) return 0;
    var sum = 0;
    final hand = _sortByN(input);
    final baiThu = <MauBinhCard>[];
    var check = 0;

    for (var i = 0; i < hand.length - 1; i++) {
      for (var j = i + 1; j < hand.length; j++) {
        if (hand[i].n == hand[j].n) {
          check++;
        } else {
          break;
        }
      }
      if (check != 1) check = 0;
      if (check == 1) {
        baiThu.add(hand[i]);
        baiThu.add(hand[i + 1]);
        check = 0;
        break;
      }
    }
    for (final card in baiThu) {
      hand.remove(card);
    }
    for (var i = 0; i < hand.length - 1; i++) {
      for (var j = i + 1; j < hand.length; j++) {
        if (hand[i].n == hand[j].n && hand[i].n != baiThu[0].n) {
          check++;
        } else {
          break;
        }
      }
      if (check != 1) check = 0;
      if (check == 1) {
        baiThu.add(hand[i]);
        baiThu.add(hand[i + 1]);
        break;
      }
    }
    if (baiThu.length == 4) {
      sum = 2 * 68 + baiThu[3].n;
    }
    return sum;
  }

  static int _checkSam(List<MauBinhCard> input) {
    var check = 0;
    var sum = 0;
    final hand = _sortByN(input);
    for (var i = 0; i < hand.length - 1; i++) {
      for (var j = i + 1; j < hand.length; j++) {
        if (hand[i].n == hand[j].n) {
          check++;
        } else {
          break;
        }
      }
      if (check != 2) check = 0;
      if (check == 2) {
        sum = 3 * 68 + hand[i].n;
        break;
      }
    }
    if (check == 2) return sum;
    return sum;
  }

  static int getMark(List<MauBinhCard> cards) {
    var sum = 0;
    if ((sum = _checkTPS(cards)) > 0) return sum;
    if ((sum = _checkTuQuy(cards)) > 0) return sum;
    if ((sum = _checkCuLu(cards)) > 0) return sum;
    if ((sum = _checkThung(cards)) > 0) return sum;
    if ((sum = _checkSanh(cards)) > 0) return sum;
    if ((sum = _checkSam(cards)) > 0) return sum;
    if ((sum = _checkThu(cards)) > 0) return sum;
    if ((sum = _checkDoi(cards)) > 0) return sum;
    return sum;
  }

  static MauBinhResult getPokerMiniResult(List<MauBinhCard> cards) {
    final mark = getMark(cards);
    if (mark > 8 * 68) return MauBinhResult.thungPhaSanh;
    if (mark > 7 * 68) return MauBinhResult.tuQuy;
    if (mark > 6 * 68) return MauBinhResult.cuLu;
    if (mark > 5 * 68) return MauBinhResult.thung;
    if (mark > 4 * 68) return MauBinhResult.sanh;
    if (mark > 3 * 68) return MauBinhResult.xamCo;
    if (mark > 2 * 68) return MauBinhResult.thu;
    if (mark > 1 * 68) return MauBinhResult.doi;
    return MauBinhResult.mauThau;
  }

  static String getPokerMiniResultString(List<MauBinhCard> cards) =>
      _resultStrings[getPokerMiniResult(cards).index];
}
