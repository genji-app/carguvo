import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:carguvo/core/constants/app_constants.dart';
import 'package:carguvo/data/models/trip_model.dart';
import 'package:carguvo/data/models/cargo_model.dart';
import 'package:carguvo/data/models/delivery_point_model.dart';
import 'package:carguvo/data/models/timeline_model.dart';

class HiveService {
  static Future<void> init() async {
    debugPrint('DEBUG: HiveService.init starting...');
    debugPrint('DEBUG: Hive.initFlutter starting');
    await Hive.initFlutter();
    debugPrint('DEBUG: Hive.initFlutter finished');

    // Register adapters
    Hive.registerAdapter(TripModelAdapter());
    Hive.registerAdapter(DeliveryPointModelAdapter());
    Hive.registerAdapter(CargoModelAdapter());
    Hive.registerAdapter(TimelineModelAdapter());

    // Open boxes
    debugPrint('DEBUG: Opening tripBox');
    await Hive.openBox<TripModel>(AppConstants.tripBox);
    debugPrint('DEBUG: Opening cargoBox');
    await Hive.openBox<CargoModel>(AppConstants.cargoBox);
    debugPrint('DEBUG: Opening deliveryPointBox');
    await Hive.openBox<DeliveryPointModel>(AppConstants.deliveryPointBox);
    debugPrint('DEBUG: Opening timelineBox');
    await Hive.openBox<TimelineModel>(AppConstants.timelineBox);
    debugPrint('DEBUG: Opening settingsBox');
    await Hive.openBox(AppConstants.settingsBox);
    debugPrint('DEBUG: All boxes opened successfully');
  }

  // ── Box Accessors ──

  static Box<TripModel> get tripBox =>
      Hive.box<TripModel>(AppConstants.tripBox);

  static Box<CargoModel> get cargoBox =>
      Hive.box<CargoModel>(AppConstants.cargoBox);

  static Box<DeliveryPointModel> get deliveryPointBox =>
      Hive.box<DeliveryPointModel>(AppConstants.deliveryPointBox);

  static Box<TimelineModel> get timelineBox =>
      Hive.box<TimelineModel>(AppConstants.timelineBox);

  static Box get settingsBox => Hive.box(AppConstants.settingsBox);

  // ── Settings Helpers ──

  static bool get isOnboardingCompleted =>
      settingsBox.get(AppConstants.onboardingCompleted, defaultValue: false);

  static Future<void> setOnboardingCompleted() =>
      settingsBox.put(AppConstants.onboardingCompleted, true);

  // ── Clear All Data ──

  static Future<void> clearAll() async {
    await tripBox.clear();
    await cargoBox.clear();
    await deliveryPointBox.clear();
    await timelineBox.clear();
  }
}
