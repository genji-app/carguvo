class MiniGameActiveScopes {
  int _taiXiu = 0;
  int _trenDuoi = 0;
  int _slots = 0;

  bool get taiXiuActive => _taiXiu > 0;

  bool get trenDuoiActive => _trenDuoi > 0;

  bool get slotsActive => _slots > 0;

  void retainTaiXiu() => _taiXiu++;
  void releaseTaiXiu() => _taiXiu = _taiXiu > 0 ? _taiXiu - 1 : 0;

  void retainTrenDuoi() => _trenDuoi++;
  void releaseTrenDuoi() => _trenDuoi = _trenDuoi > 0 ? _trenDuoi - 1 : 0;

  void retainSlots() => _slots++;
  void releaseSlots() => _slots = _slots > 0 ? _slots - 1 : 0;
}
