import 'package:hive/hive.dart';
import 'package:carguvo/core/enums/enums.dart';

class TimelineModel extends HiveObject {
  String id;
  String cargoId;
  String tripId;
  int actionIndex; // TimelineAction index
  DateTime createdAt;
  String note;

  TimelineModel({
    required this.id,
    required this.cargoId,
    required this.tripId,
    required this.actionIndex,
    required this.createdAt,
    this.note = '',
  });

  TimelineAction get action => TimelineAction.values[actionIndex];
  set action(TimelineAction value) => actionIndex = value.index;
}

class TimelineModelAdapter extends TypeAdapter<TimelineModel> {
  @override
  final int typeId = 3;

  @override
  TimelineModel read(BinaryReader reader) {
    return TimelineModel(
      id: reader.readString(),
      cargoId: reader.readString(),
      tripId: reader.readString(),
      actionIndex: reader.readInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      note: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TimelineModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.cargoId);
    writer.writeString(obj.tripId);
    writer.writeInt(obj.actionIndex);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeString(obj.note);
  }
}
