import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/features/search/data/storage/casino_recent_games_storage.dart';
import 'package:sun_sports/features/search/data/storage/search_recent_storage.dart';
import 'package:sun_sports/features/search/presentation/providers/search_providers.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_body.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_tabs.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

enum _SearchTab { sport, casino }

class SearchMobileScreen extends ConsumerStatefulWidget {
  const SearchMobileScreen({super.key});

  static Future<void> showAsBottomSheet(
    BuildContext context,
  ) => showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: slideAnimation, child: child);
    },
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SearchMobileScreen(),
  );

  @override
  ConsumerState<SearchMobileScreen> createState() => _SearchMobileScreenState();
}

class _SearchMobileScreenState extends ConsumerState<SearchMobileScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _selectedTabIndex = 0;
  Timer? _debounceTimer;
  String _debouncePendingValue = '';
  static const _debounceDuration = Duration(milliseconds: 500);

  _SearchTab get _currentTab =>
      _selectedTabIndex == 0 ? _SearchTab.sport : _SearchTab.casino;

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
    if (_currentTab == _SearchTab.sport) {
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
    setState(() {});

    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return;
      final current = _controller.text.trim();
      final toCommit = current.isNotEmpty ? current : _debouncePendingValue;
      if (toCommit.isNotEmpty) _commitQuery(toCommit);
      _debouncePendingValue = '';
    });
  }

  void _onRecentKeywordTap(String keyword) {
    _controller.text = keyword;
    if (_currentTab == _SearchTab.sport) {
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
    }
  }

  static const double _heightFraction = 0.95;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final maxHeight = screenSize.height * _heightFraction;

    return Dialog(
      backgroundColor: AppColorStyles.backgroundSecondary,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.only(top: statusBarHeight),
      child: Container(
        width: screenSize.width,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: AppColorStyles.backgroundSecondary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: SoundTap.wrap(_close),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: ImageHelper.load(
                          path: AppIcons.icBack,
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.only(left: 16, right: 8),
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
                            hintText: _currentTab == _SearchTab.sport
                                ? 'Tìm kiếm trận đấu, đội bóng...'
                                : 'Tìm kiếm game casino...',
                            hintStyle: AppTextStyles.paragraphMedium(
                              color: AppColorStyles.contentTertiary,
                            ),
                            suffixIcon:
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _controller,
                                  builder: (context, value, _) {
                                    if (value.text.isEmpty)
                                      return const SizedBox.shrink();
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
                  ],
                ),
              ),
              SearchTabs(
                selectedIndex: _selectedTabIndex,
                onTabChanged: (index) =>
                    setState(() => _selectedTabIndex = index),
              ),
              SearchBody(
                query: _controller.text,
                isSport: _currentTab == _SearchTab.sport,
                onRecentKeywordTap: _onRecentKeywordTap,
                onCasinoGameTap: _onCasinoGameTap,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
