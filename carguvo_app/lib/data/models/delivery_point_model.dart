import 'package:hive/hive.dart';
import 'package:carguvo/core/enums/enums.dart';

class DeliveryPointModel extends HiveObject {
  String id;
  String tripId;
  String receiverName;
  String phone;
  String address;
  String note;
  int statusIndex; // DeliveryStatus index

  DeliveryPointModel({
    required this.id,
    required this.tripId,
    required this.receiverName,
    this.phone = '',
    this.address = '',
    this.note = '',
    this.statusIndex = 0,
  });

  DeliveryStatus get status => DeliveryStatus.values[statusIndex];
  set status(DeliveryStatus value) => statusIndex = value.index;

  DeliveryPointModel copyWith({
    String? id,
    String? tripId,
    String? receiverName,
    String? phone,
    String? address,
    String? note,
    int? statusIndex,
  }) {
    return DeliveryPointModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      receiverName: receiverName ?? this.receiverName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      note: note ?? this.note,
      statusIndex: statusIndex ?? this.statusIndex,
    );
  }
}

class DeliveryPointModelAdapter extends TypeAdapter<DeliveryPointModel> {
  @override
  final int typeId = 1;

  @override
  DeliveryPointModel read(BinaryReader reader) {
    return DeliveryPointModel(
      id: reader.readString(),
      tripId: reader.readString(),
      receiverName: reader.readString(),
      phone: reader.readString(),
      address: reader.readString(),
      note: reader.readString(),
      statusIndex: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryPointModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.tripId);
    writer.writeString(obj.receiverName);
    writer.writeString(obj.phone);
    writer.writeString(obj.address);
    writer.writeString(obj.note);
    writer.writeInt(obj.statusIndex);
  }
}
