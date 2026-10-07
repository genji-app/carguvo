library;

enum SlotPrefsField { bet, linesMask, turbo, auto, autoOwner }

const int slotPrefsMaxLines = 20;

String slotPrefsKeyFor(String prefix, SlotPrefsField field) =>
    switch (field) {
      SlotPrefsField.bet => '${prefix}_bet',
      SlotPrefsField.linesMask => '${prefix}_lines_mask',
      SlotPrefsField.turbo => '${prefix}_turbo',
      SlotPrefsField.auto => '${prefix}_auto',
      SlotPrefsField.autoOwner => '${prefix}_auto_uid',
    };

bool slotMaskMissing(int? mask) => mask == null || mask < 0;

int slotEncodeLines(List<int> lines) {
  var mask = 0;
  for (final l in lines) {
    if (l >= 0 && l < slotPrefsMaxLines) mask |= 1 << l;
  }
  return mask;
}

List<int> slotDecodeLines(int mask) {
  final out = <int>[];
  for (var i = 0; i < slotPrefsMaxLines; i++) {
    if (mask & (1 << i) != 0) out.add(i);
  }
  return out;
}

List<int>? slotDecodeLinesOrNull(int? mask) {
  if (mask == null || mask < 0) return null;
  return slotDecodeLines(mask);
}

bool? slotBoolValue(String? raw) => raw == null ? null : raw == 'true';
