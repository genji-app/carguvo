import 'package:hive/hive.dart';
import 'package:carguvo/core/enums/enums.dart';

class TripModel extends HiveObject {
  String id;
  String code;
  String note;
  DateTime createdAt;
  int statusIndex; // TripStatus index

  TripModel({
    required this.id,
    required this.code,
    this.note = '',
    required this.createdAt,
    this.statusIndex = 0,
  });

  TripStatus get status => TripStatus.values[statusIndex];
  set status(TripStatus value) => statusIndex = value.index;

  TripModel copyWith({
    String? id,
    String? code,
    String? note,
    DateTime? createdAt,
    int? statusIndex,
  }) {
    return TripModel(
      id: id ?? this.id,
      code: code ?? this.code,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      statusIndex: statusIndex ?? this.statusIndex,
    );
  }
}

class TripModelAdapter extends TypeAdapter<TripModel> {
  @override
  final int typeId = 0;

  @override
  TripModel read(BinaryReader reader) {
    return TripModel(
      id: reader.readString(),
      code: reader.readString(),
      note: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      statusIndex: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, TripModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.code);
    writer.writeString(obj.note);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.statusIndex);
  }
}
