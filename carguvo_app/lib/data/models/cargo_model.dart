import 'package:hive/hive.dart';
import 'package:carguvo/core/enums/enums.dart';

class CargoModel extends HiveObject {
  String id;
  String tripId;
  String deliveryPointId;
  String cargoCode;
  String cargoName;
  String cargoType;
  int quantity;
  int statusIndex; // CargoStatus index
  String note;
  DateTime createdAt;

  CargoModel({
    required this.id,
    required this.tripId,
    this.deliveryPointId = '',
    required this.cargoCode,
    required this.cargoName,
    this.cargoType = '',
    this.quantity = 1,
    this.statusIndex = 0,
    this.note = '',
    required this.createdAt,
  });

  CargoStatus get status => CargoStatus.values[statusIndex];
  set status(CargoStatus value) => statusIndex = value.index;

  /// Hàng còn trên xe = loaded
  bool get isOnTruck => status == CargoStatus.loaded;

  CargoModel copyWith({
    String? id,
    String? tripId,
    String? deliveryPointId,
    String? cargoCode,
    String? cargoName,
    String? cargoType,
    int? quantity,
    int? statusIndex,
    String? note,
    DateTime? createdAt,
  }) {
    return CargoModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      deliveryPointId: deliveryPointId ?? this.deliveryPointId,
      cargoCode: cargoCode ?? this.cargoCode,
      cargoName: cargoName ?? this.cargoName,
      cargoType: cargoType ?? this.cargoType,
      quantity: quantity ?? this.quantity,
      statusIndex: statusIndex ?? this.statusIndex,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CargoModelAdapter extends TypeAdapter<CargoModel> {
  @override
  final int typeId = 2;

  @override
  CargoModel read(BinaryReader reader) {
    return CargoModel(
      id: reader.readString(),
      tripId: reader.readString(),
      deliveryPointId: reader.readString(),
      cargoCode: reader.readString(),
      cargoName: reader.readString(),
      cargoType: reader.readString(),
      quantity: reader.readInt(),
      statusIndex: reader.readInt(),
      note: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, CargoModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.tripId);
    writer.writeString(obj.deliveryPointId);
    writer.writeString(obj.cargoCode);
    writer.writeString(obj.cargoName);
    writer.writeString(obj.cargoType);
    writer.writeInt(obj.quantity);
    writer.writeInt(obj.statusIndex);
    writer.writeString(obj.note);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
