import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/error/betting_api_error_messages.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/features/parlay/presentation/providers/parlay_overlay_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/bet_success/bet_success.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_header.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_match_card.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_multi_section.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_shimmer_loading.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_stake_section.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_summary_section.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_tab_bar.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class ParlayDesktopOverlay extends ConsumerStatefulWidget {
  const ParlayDesktopOverlay({super.key});

  @override
  ConsumerState<ParlayDesktopOverlay> createState() =>
      _ParlayDesktopOverlayState();
}

class _ParlayDesktopOverlayState extends ConsumerState<ParlayDesktopOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  bool _hasTriggeredRecalculate = false;

  bool _isPlacingBet = false;

  bool _showSuccessView = false;

  List<SingleBetData> _successfulBets = [];

  bool _showComboSuccessView = false;

  ComboBetSuccessData? _comboBetSuccessData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerRecalculateIfReady() {
    if (!mounted || _hasTriggeredRecalculate) return;

    final isBettingReady = ref.read(isBettingReadyProvider);
    if (isBettingReady) {
      _hasTriggeredRecalculate = true;
      debugPrint(
        '[ParlayDesktopOverlay] Triggering recalculateAllBets on overlay open',
      );

      _syncScoresFromEventsCache();

      ref.read(parlayStateProvider.notifier).recalculateAllBets();
    }
  }

  void _syncScoresFromEventsCache() {
    final parlayState = ref.read(parlayStateProvider);
    final eventsCache = ref.read(eventsProvider).eventCache;

    final eventIds = <int>{};
    for (final bet in parlayState.singleBets) {
      eventIds.add(bet.eventData.eventId);
    }
    for (final bet in parlayState.comboBets) {
      eventIds.add(bet.eventData.eventId);
    }

    if (eventIds.isEmpty) return;

    final scoresMap = <int, ({int home, int away})>{};
    for (final eventId in eventIds) {
      final cachedEvent = eventsCache[eventId];
      if (cachedEvent != null && cachedEvent.score != null) {
        scoresMap[eventId] = (
          home: cachedEvent.score!.home,
          away: cachedEvent.score!.away,
        );
      }
    }

    if (scoresMap.isNotEmpty) {
      debugPrint(
        '[ParlayDesktopOverlay] Syncing ${scoresMap.length} scores from events cache',
      );
      ref.read(parlayStateProvider.notifier).syncScoresFromCache(scoresMap);
    }
  }

  void _resetOverlayState() {
    if (!mounted) return;

    setState(() {
      _isPlacingBet = false;
      _showSuccessView = false;
      _successfulBets = [];
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });

    ref.read(parlayStateProvider.notifier).resetPlacingState();
  }

  void _closeOverlay() {
    _resetOverlayState();
    ref.read(parlayStateProvider.notifier).saveAllToStorage();
    ref.read(parlayOverlayVisibleProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(parlayOverlayVisibleProvider);
    final tab = ref.watch(parlayStateProvider.select((s) => s.tab));
    final isBettingReady = ref.watch(isBettingReadyProvider);

    if (isVisible) {
      _animationController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerRecalculateIfReady();
      });
    } else {
      _animationController.reverse();
      _hasTriggeredRecalculate = false;
    }

    ref.listen<bool>(isBettingReadyProvider, (previous, next) {
      if (next && !_hasTriggeredRecalculate && isVisible) {
        _hasTriggeredRecalculate = true;
        debugPrint(
          '[ParlayDesktopOverlay] Triggering recalculateAllBets on betting ready',
        );
        ref.read(parlayStateProvider.notifier).recalculateAllBets();
      }
    });

    if (!isVisible && !_animationController.isAnimating) {
      return const SizedBox.shrink();
    }

    return SizedBox.expand(
      child: Stack(
        children: [
          if (isVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: SoundTap.wrap(_closeOverlay),
                child: Container(color: Colors.transparent),
              ),
            ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                color: Colors.transparent,
                child: SafeArea(
                  left: false,
                  right: false,
                  child: Container(
                    width: 400,
                    decoration: const BoxDecoration(
                      color: AppColors.gray950,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          blurRadius: 80,
                          offset: Offset(-20, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      child: _showSuccessView
                          ? _buildSuccessView()
                          : _showComboSuccessView
                          ? _buildComboSuccessView()
                          : AbsorbPointer(
                              absorbing: _isPlacingBet,
                              child: Column(
                                children: [
                                  ParlayHeader(onClose: _closeOverlay),
                                  const ParlayTabBar(),
                                  const Gap(12),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: isBettingReady
                                          ? _buildContent(tab)
                                          : _buildShimmerLoading(tab),
                                    ),
                                  ),
                                  ParlaySummarySection(
                                    isPlacingBetOverride: _isPlacingBet,
                                    onPlaceBetPressed: _handlePlaceBet,
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
        ],
      ),
    );
  }

  Future<void> _handlePlaceBet() async {
    debugPrint('[ParlayDesktopOverlay] _handlePlaceBet called');

    final state = ref.read(parlayStateProvider);

    if (state.tab == ParlayTab.combo) {
      await _handlePlaceComboBet();
      return;
    }

    final betsToPlace = state.singleBets
        .where((bet) => bet.canPlaceBet)
        .toList();

    if (betsToPlace.isEmpty) {
      debugPrint('[ParlayDesktopOverlay] No valid bets to place');
      return;
    }

    setState(() {
      _isPlacingBet = true;
    });

    try {
      final result = await ref
          .read(parlayStateProvider.notifier)
          .placeAllSingleBetsParallel();

      if (!mounted) return;

      if (result.hasSuccessfulBets) {
        final formattedStake = _formatCurrency(result.totalStake);
        AppToast.showSuccess(
          context,
          message:
              'Cược đơn của bạn trị giá \$$formattedStake đã được đặt thành công',
        );

        debugPrint(
          '[ParlayDesktopOverlay] Showing success view with ${result.successCount} successful bets',
        );
        setState(() {
          _isPlacingBet = false;
          _showSuccessView = true;
          _successfulBets = result.successfulBets;
        });
      } else {
        debugPrint('[ParlayDesktopOverlay] All bets failed');
        setState(() {
          _isPlacingBet = false;
        });
        if (mounted) {
          AppToast.showError(
            context,
            message:
                result.firstErrorMessage ?? bettingApiPlaceBetFailureFallback,
          );
        }
      }

      if (result.hasFailedBets) {
        debugPrint(
          '[ParlayDesktopOverlay] ${result.failedCount} bets failed and remain in list',
        );
      }
    } catch (e) {
      debugPrint('[ParlayDesktopOverlay] Place bet error: $e');
      if (!mounted) return;
      setState(() {
        _isPlacingBet = false;
      });
      AppToast.showError(context, message: bettingApiPlaceBetFailureFallback);
    }
  }

  String _formatCurrency(int amountInVnd) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amountInVnd);
  }

  Future<void> _handlePlaceComboBet() async {
    debugPrint('[ParlayDesktopOverlay] _handlePlaceComboBet called');

    final state = ref.read(parlayStateProvider);
    final comboBets = List<SingleBetData>.from(state.comboBets);

    if (comboBets.isEmpty) {
      return;
    }

    if (!state.canPlaceBet) {
      debugPrint(
        '[ParlayDesktopOverlay] Cannot place combo bet - validation failed',
      );
      return;
    }

    setState(() {
      _isPlacingBet = true;
    });

    try {
      final comboBetDataForSuccess = ComboBetSuccessData(
        selections: comboBets,
        totalOdds: state.totalOdds,
        stake: state.stake,
        potentialWin: state.stake * state.totalOdds,
      );

      final success = await ref
          .read(parlayStateProvider.notifier)
          .placeComboParlay();

      if (!mounted) return;

      if (success) {
        final formattedStake = _formatCurrency(state.stake);
        AppToast.showSuccess(
          context,
          message:
              'Cược Xiên của bạn trị giá \$$formattedStake đã được đặt thành công',
        );

        debugPrint('[ParlayDesktopOverlay] Showing combo success view');
        setState(() {
          _isPlacingBet = false;
          _showComboSuccessView = true;
          _comboBetSuccessData = comboBetDataForSuccess;
        });
      } else {
        debugPrint('[ParlayDesktopOverlay] Combo bet placement failed');
        setState(() {
          _isPlacingBet = false;
        });

        final error = ref.read(parlayErrorProvider);
        if (mounted) {
          AppToast.showError(
            context,
            message: error ?? bettingApiParlayComboFailureFallback,
          );
        }
      }
    } catch (e) {
      debugPrint('[ParlayDesktopOverlay] Place combo bet error: $e');
      if (!mounted) return;
      setState(() {
        _isPlacingBet = false;
      });
      AppToast.showError(
        context,
        message: bettingApiParlayComboFailureFallback,
      );
    }
  }

  Widget _buildSuccessView() => BetSuccessView(
    successfulBets: _successfulBets,
    onClose: _handleCloseSuccess,
    onViewMyBets: _handleViewMyBets,
    onRemoveBet: _handleRemoveSuccessBet,
    onReuseBets: _handleReuseBets,
    onClearAll: _handleClearAll,
  );

  Widget _buildComboSuccessView() => ComboSuccessView(
    comboBetData: _comboBetSuccessData!,
    onClose: _handleCloseComboSuccess,
    onViewMyBets: _handleViewMyBetsCombo,
    onReuseBet: _handleReuseComboBet,
    onClearAll: _handleClearAllCombo,
  );

  void _handleCloseSuccess() {
    setState(() {
      _showSuccessView = false;
      _successfulBets = [];
    });
    _closeOverlay();
  }

  void _handleViewMyBets() {
    setState(() {
      _showSuccessView = false;
      _successfulBets = [];
    });
    _closeOverlay();
    _openMyBetHistory();
  }

  void _handleRemoveSuccessBet(int index) {
    setState(() {
      _successfulBets = List.from(_successfulBets)..removeAt(index);
      if (_successfulBets.isEmpty) {
        _showSuccessView = false;
      }
    });
  }

  void _handleReuseBets() {
    for (final bet in _successfulBets) {
      ref
          .read(parlayStateProvider.notifier)
          .addSingleBetDirect(
            bet.copyWith(stake: 0),
          );
    }
    setState(() {
      _showSuccessView = false;
      _successfulBets = [];
    });
  }

  void _handleClearAll() {
    setState(() {
      _showSuccessView = false;
      _successfulBets = [];
    });
    ref.read(parlayStateProvider.notifier).clearAllSingleBets();
  }

  void _handleCloseComboSuccess() {
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
    _closeOverlay();
  }

  void _handleViewMyBetsCombo() {
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
    _closeOverlay();
    _openMyBetHistory();
  }

  Future<void> _openMyBetHistory() async {
    if (!mounted) return;

    ref.read(myBetHubControllerProvider).open(initialMenu: MyBetMenu.myBets);
  }

  void _handleReuseComboBet() {
    if (_comboBetSuccessData != null) {
      final notifier = ref.read(parlayStateProvider.notifier);
      for (final bet in _comboBetSuccessData!.selections) {
        notifier.addComboBetDirect(bet);
      }
      notifier.clearStake();
      notifier.calculateComboParlay();
    }
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
  }

  void _handleClearAllCombo() {
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
  }

  Widget _buildContent(ParlayTab tab) => switch (tab) {
    ParlayTab.single => const Column(children: [ParlayMatchCard(), Gap(24)]),
    ParlayTab.combo => const Column(children: [ParlayStakeSection(), Gap(24)]),
    ParlayTab.multi => const Column(children: [ParlayMultiSection(), Gap(24)]),
  };

  Widget _buildShimmerLoading(ParlayTab tab) => switch (tab) {
    ParlayTab.single => const Column(
      children: [
        ParlayShimmerLoading(cardCount: 2, type: ParlayShimmerType.single),
        Gap(24),
      ],
    ),
    ParlayTab.combo => const Column(
      children: [
        ParlayShimmerLoading(type: ParlayShimmerType.combo),
        Gap(24),
      ],
    ),
    ParlayTab.multi => const Column(
      children: [
        ParlayShimmerLoading(cardCount: 2, type: ParlayShimmerType.single),
        Gap(24),
      ],
    ),
  };
}
