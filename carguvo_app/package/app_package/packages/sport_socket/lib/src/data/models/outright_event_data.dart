import '../../proto/proto.dart';

class OutrightEventData {
  final int eventId;

  final int sportId;

  final int leagueId;

  String eventName;

  String? endDate;

  int endTime;

  bool isSuspended;

  List<OutrightLineData> lines;

  OutrightEventData({
    required this.eventId,
    required this.sportId,
    required this.leagueId,
    required this.eventName,
    this.endDate,
    this.endTime = 0,
    this.isSuspended = false,
    this.lines = const [],
  });

  factory OutrightEventData.fromProto(OutrightEventResponse proto) {
    return OutrightEventData(
      eventId: proto.eventId.toInt(),
      sportId: proto.sportId,
      leagueId: proto.leagueId,
      eventName: proto.eventName,
      endDate: proto.endDate.isEmpty ? null : proto.endDate,
      endTime: proto.endTime.toInt(),
      isSuspended: proto.isSuspended,
      lines: proto.lines.map(OutrightLineData.fromProto).toList(),
    );
  }

  void updateFromProto(OutrightEventResponse proto) {
    eventName = proto.eventName;
    if (proto.endDate.isNotEmpty) endDate = proto.endDate;
    endTime = proto.endTime.toInt();
    isSuspended = proto.isSuspended;
    lines = proto.lines.map(OutrightLineData.fromProto).toList();
  }
}

class OutrightLineData {
  String lineName;

  int lineOrder;

  List<OutrightOddsData> oddsList;

  OutrightLineData({
    this.lineName = '',
    this.lineOrder = 0,
    this.oddsList = const [],
  });

  factory OutrightLineData.fromProto(OutrightLineResponse proto) {
    return OutrightLineData(
      lineName: proto.lineName,
      lineOrder: proto.lineOrder,
      oddsList:
          proto.oddsList.map(OutrightOddsData.fromProto).toList(),
    );
  }
}

class OutrightOddsData {
  final String selectionId;

  String selectionName;

  String? selectionLogo;

  String offerId;

  double odds;

  String? cls;

  bool isSuspended;

  double? previousOdds;

  OutrightOddsData({
    required this.selectionId,
    required this.selectionName,
    this.selectionLogo,
    required this.offerId,
    required this.odds,
    this.cls,
    this.isSuspended = false,
    this.previousOdds,
  });

  factory OutrightOddsData.fromProto(OutrightOddsResponse proto) {
    return OutrightOddsData(
      selectionId: proto.selectionId,
      selectionName: proto.selectionName,
      selectionLogo: proto.selectionLogo.isEmpty ? null : proto.selectionLogo,
      offerId: proto.offerId,
      odds: proto.odds,
      cls: proto.cls.isEmpty ? null : proto.cls,
      isSuspended: proto.isSuspended,
    );
  }
}
