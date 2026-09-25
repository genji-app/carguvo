import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';

import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/search/data/storage/casino_recent_games_storage.dart';
import 'package:sun_sports/features/search/data/storage/search_recent_storage.dart';
import 'package:sun_sports/features/search/presentation/providers/search_providers.dart';
import 'package:sun_sports/features/search/presentation/mobile/search_mobile_screen.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_body.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_tabs.dart';
import 'package:sun_sports/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

enum SearchDialogTab { sport, casino }

class SearchDialog extends ConsumerStatefulWidget {
  const SearchDialog({super.key, this.asFullHeightBottomSheet = false});

  final bool asFullHeightBottomSheet;

  static Future<void> show(BuildContext context) async {
    pushLivestreamOverlayBlock();
    try {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        barrierDismissible: false,
        builder: (ctx) => const SearchDialog(),
      );
    } finally {
      popLivestreamOverlayBlock();
    }
  }

  static Future<void> showAsFullHeightBottomSheet(BuildContext context) {
    return SearchMobileScreen.showAsBottomSheet(context);
  }

  @override
  ConsumerState<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<SearchDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _selectedTabIndex = 0;
  Timer? _debounceTimer;

  String _debouncePendingValue = '';

  static const _debounceDuration = Duration(milliseconds: 500);

  SearchDialogTab get _currentTab =>
      _selectedTabIndex == 0 ? SearchDialogTab.sport : SearchDialogTab.casino;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commitQuery(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    ref.read(searchDebouncedQueryProvider.notifier).state = query;
    if (_currentTab == SearchDialogTab.sport) {
      ref.invalidate(searchResultProvider(query));
    }
    setState(() {});
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      _debouncePendingValue = '';
      _debounceTimer?.cancel();
      ref.read(searchDebouncedQueryProvider.notifier).state = '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return;
    }

    if (trimmed == _debouncePendingValue) return;
    if (trimmed == ref.read(searchDebouncedQueryProvider)) return;
    _debouncePendingValue = trimmed;
    _debounceTimer?.cancel();
    setState(
      () {},
    );

    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return;
      final current = _controller.text.trim();
      final toCommit = current.isNotEmpty ? current : _debouncePendingValue;
      if (toCommit.isNotEmpty) {
        _commitQuery(toCommit);
      }
      _debouncePendingValue = '';
    });
  }

  void _onRecentKeywordTap(String keyword) {
    _controller.text = keyword;
    if (_currentTab == SearchDialogTab.sport) {
      SearchRecentStorage.addRecentSport(keyword);
      ref.invalidate(searchRecentSportProvider);
    }
    _onSearchChanged(keyword);
  }

  void _close() => Navigator.of(context).pop();

  Future<void> _onCasinoGameTap(LobbyGame game) async {
    await CasinoRecentGamesStorage.addGame(
      game.providerId,
      game.productId,
      game.gameCode,
    );
    ref.invalidate(casinoRecentKeysProvider);

    if (!mounted) return;
    _close();
    if (mounted) {
      ref.read(gameLauncherProvider.notifier).launch(context, game);
    } else if (mounted) {
      AppToast.showError(context, message: I18n.msgSomethingWentWrong);
    }
  }

  Widget _buildSearchContent({bool expandBody = false}) {
    final body = SearchBody(
      query: _controller.text,
      isSport: _currentTab == SearchDialogTab.sport,
      onRecentKeywordTap: _onRecentKeywordTap,
      onCasinoGameTap: _onCasinoGameTap,
    );
    return Column(
      mainAxisSize: expandBody ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: 8,
          ),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.paragraphMedium(
                color: AppColorStyles.contentPrimary,
              ),
              decoration: InputDecoration(
                hintText: _currentTab == SearchDialogTab.sport
                    ? 'Tìm kiếm trận đấu, đội bóng...'
                    : 'Tìm kiếm game casino...',
                hintStyle: AppTextStyles.paragraphMedium(
                  color: AppColorStyles.contentTertiary,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacingStyles.space300,
                    right: AppSpacingStyles.space200,
                  ),
                  child: ImageHelper.load(
                    path: AppIcons.icSearch,
                    width: 20,
                    height: 20,
                    color: AppColorStyles.contentTertiary,
                  ),
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: SoundTap.wrap(() {
                        _controller.clear();
                        _onSearchChanged('');
                      }),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColorStyles.contentTertiary,
                        ),
                      ),
                    );
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 14,
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                _debounceTimer?.cancel();
                final q = value.trim();
                if (q.isNotEmpty) _commitQuery(q);
              },
            ),
          ),
        ),
        SearchTabs(
          selectedIndex: _selectedTabIndex,
          onTabChanged: (index) => setState(() => _selectedTabIndex = index),
        ),
        if (expandBody) Expanded(child: body) else body,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asFullHeightBottomSheet) {
      final topPadding = MediaQuery.paddingOf(context).top;
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Container(
          height: MediaQuery.sizeOf(context).height - topPadding,
          decoration: const BoxDecoration(
            color: AppColorStyles.backgroundSecondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColorStyles.contentTertiary.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: SoundTap.wrap(_close),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildSearchContent(expandBody: true)),
            ],
          ),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height * 3 / 4;
    final screenWidth = MediaQuery.of(context).size.width * .33333;
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              _close();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: SoundTap.wrap(() => FocusScope.of(context).unfocus()),
              child: Dialog(
                backgroundColor: Colors.transparent,
                alignment: Alignment.topRight,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520, minWidth: 320),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          width: screenWidth,
                          height: screenHeight,
                          decoration: BoxDecoration(
                            color: AppColorStyles.backgroundSecondary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColorStyles.borderSecondary,
                              width: 1,
                            ),
                          ),
                          child: _buildSearchContent(),
                        ),
                      ),
                      const Gap(8),
                      GestureDetector(
                        onTap: SoundTap.wrap(_close),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.gray600,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: AppColorStyles.contentSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
