import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/providers/casino_provider_menu_provider.dart'
    show kCasinoProviderCategoryPrefix;

class GameCategorySelection {
  const GameCategorySelection({this.category});

  factory GameCategorySelection.fromCategory(LobbyCategory category) =>
      GameCategorySelection(category: category);

  final LobbyCategory? category;

  GameCategorySelection copyWith({
    LobbyCategory? category,
    bool clearCategory = false,
  }) {
    return GameCategorySelection(
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  bool get isEmpty => category == null;

  bool get isNotEmpty => !isEmpty;

  String get categoryId => category?.id ?? 'all';

  String? get providerId {
    final id = category?.id;
    if (id == null || !id.startsWith(kCasinoProviderCategoryPrefix)) {
      return null;
    }
    final raw = id.substring(kCasinoProviderCategoryPrefix.length);
    return raw.isEmpty ? null : raw;
  }

  bool get isProviderMenu =>
      category?.id == 'sun' || providerId != null;

  String get label => category?.displayName ?? I18n.txtGameCategoryAll;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameCategorySelection &&
          runtimeType == other.runtimeType &&
          category?.id == other.category?.id;

  @override
  int get hashCode => category?.id.hashCode ?? 0;
}

extension GameCategoryTabs on List<LobbyCategory> {
  GameCategorySelection selectionAt(int index) {
    if (index < 0 || index >= length) return const GameCategorySelection();
    final LobbyCategory category = this[index];
    return category.isAll
        ? const GameCategorySelection()
        : GameCategorySelection.fromCategory(category);
  }

  int indexOfSelection(GameCategorySelection selection) {
    if (selection.isNotEmpty) {
      final int i = indexWhere((c) => c.id == selection.category!.id);
      if (i >= 0) return i;
    }
    final int all = indexWhere((c) => c.isAll);
    return all < 0 ? 0 : all;
  }
}
