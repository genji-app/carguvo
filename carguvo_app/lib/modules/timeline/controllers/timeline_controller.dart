import 'package:get/get.dart';
import 'package:carguvo/data/models/timeline_model.dart';
import 'package:carguvo/data/repositories/timeline_repository.dart';

class TimelineController extends GetxController {
  final _timelineRepo = Get.find<TimelineRepository>();

  final timelineEntries = <TimelineModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTimeline();
  }

  void loadTimeline() {
    timelineEntries.value = _timelineRepo.getAll();
  }
}
