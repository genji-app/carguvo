import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/error/betting_api_error_messages.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/my_bet_hub/my_bet_hub.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/bet_success/bet_success.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_match_card.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_multi_section.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_shimmer_loading.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_stake_section.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_summary_section.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_tab_bar.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class ParlayView extends ConsumerStatefulWidget {
  const ParlayView({super.key});

  @override
  ConsumerState<ParlayView> createState() => _ParlayViewState();
}

class _ParlayViewState extends ConsumerState<ParlayView> {
  bool _hasTriggeredRecalculate = false;

  bool _isPlacingBet = false;

  bool _showSuccessView = false;

  List<SingleBetData> _successfulBets = [];

  bool _showComboSuccessView = false;

  ComboBetSuccessData? _comboBetSuccessData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerRecalculateIfReady();
    });
  }

  void _triggerRecalculateIfReady() {
    if (!mounted || _hasTriggeredRecalculate) return;

    final isBettingReady = ref.read(isBettingReadyProvider);
    if (isBettingReady) {
      _hasTriggeredRecalculate = true;
      debugPrint('[ParlayView] Triggering recalculateAllBets on sheet open');

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
        '[ParlayView] Syncing ${scoresMap.length} scores from events cache',
      );
      ref.read(parlayStateProvider.notifier).syncScoresFromCache(scoresMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parlayStateProvider);
    final isBettingReady = ref.watch(isBettingReadyProvider);

    ref.listen<bool>(isBettingReadyProvider, (previous, next) {
      if (next && !_hasTriggeredRecalculate) {
        _hasTriggeredRecalculate = true;
        debugPrint(
          '[ParlayView] Triggering recalculateAllBets on betting ready',
        );
        ref.read(parlayStateProvider.notifier).recalculateAllBets();
      }
    });

    ref.listen<bool>(myBetOverlayVisibleProvider, (previous, next) {
      if (next && previous != true) {
        ref.read(parlayStateProvider.notifier).reconcileBetslipEvents();
      }
    });

    if (ResponsiveBuilder.isDesktop(context)) {
      ref.listen<int>(
        parlayStateProvider.select(
          (s) => s.singleBets.length + s.comboBets.length,
        ),
        (previous, next) {
          if (previous != null &&
              next > previous &&
              (_showSuccessView || _showComboSuccessView)) {
            setState(() {
              _showSuccessView = false;
              _successfulBets = [];
              _showComboSuccessView = false;
              _comboBetSuccessData = null;
            });
          }
        },
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(parlayStateProvider.notifier).saveAllToStorage();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: 
          _showSuccessView
              ? _buildSuccessView()
              : _showComboSuccessView
              ? _buildComboSuccessView()
              : AbsorbPointer(
                  absorbing: _isPlacingBet,
                  child: Column(
                    children: [
                      const ParlayTabBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: isBettingReady
                              ? _buildContent(state)
                              : _buildShimmerLoading(state.tab),
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
    );
  }

  Future<void> _handlePlaceBet() async {
    debugPrint('[ParlayView] _handlePlaceBet called');

    final state = ref.read(parlayStateProvider);

    if (state.tab == ParlayTab.combo) {
      await _handlePlaceComboBet();
      return;
    }

    final betsToPlace = state.singleBets
        .where((bet) => bet.canPlaceBet)
        .toList();

    if (betsToPlace.isEmpty) {
      debugPrint('[ParlayView] No valid bets to place');
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
          '[ParlayView] Showing success view with ${result.successCount} successful bets',
        );
        ref.read(userProvider.notifier).refreshBalance();
        setState(() {
          _isPlacingBet = false;
          _showSuccessView = true;
          _successfulBets = result.successfulBets;
        });
      } else {
        debugPrint('[ParlayView] All bets failed');
        setState(() {
          _isPlacingBet = false;
        });
        if (mounted) {
          AppToast.showError(
            context,
            message:
                result.firstErrorMessage ??
                bettingApiPlaceBetFailureFallback,
          );
        }
      }

      if (result.hasFailedBets) {
        debugPrint(
          '[ParlayView] ${result.failedCount} bets failed and remain in list',
        );
      }
    } catch (e) {
      debugPrint('[ParlayView] Place bet error: $e');
      if (!mounted) return;
      setState(() {
        _isPlacingBet = false;
      });
      AppToast.showError(
        context,
        message: bettingApiPlaceBetFailureFallback,
      );
    }
  }

  String _formatCurrency(int amountInVnd) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amountInVnd);
  }

  Future<void> _handlePlaceComboBet() async {
    debugPrint('[ParlayView] _handlePlaceComboBet called');

    final state = ref.read(parlayStateProvider);
    final comboBets = List<SingleBetData>.from(state.comboBets);

    if (comboBets.isEmpty) {
      return;
    }

    if (!state.canPlaceBet) {
      debugPrint('[ParlayView] Cannot place combo bet - validation failed');
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
              'Cược Xiên của bạn trị giá \$$formattedStakeđ đã được đặt thành công',
        );
        ref.read(userProvider.notifier).refreshBalance();
        debugPrint('[ParlayView] Showing combo success view');
        setState(() {
          _isPlacingBet = false;
          _showComboSuccessView = true;
          _comboBetSuccessData = comboBetDataForSuccess;
        });
      } else {
        debugPrint('[ParlayView] Combo bet placement failed');
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
      debugPrint('[ParlayView] Place combo bet error: $e');
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
    ref.read(myBetHubControllerProvider).close();
  }

  void _handleViewMyBets() {
    setState(() {
      _showSuccessView = false;
      _successfulBets = [];
    });
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
    ref.read(myBetHubControllerProvider).close();
  }

  void _handleCloseComboSuccess() {
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
    ref.read(myBetHubControllerProvider).close();
  }

  void _handleViewMyBetsCombo() {
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
    _openMyBetHistory();
  }

  Future<void> _openMyBetHistory() async {
    if (!mounted) return;

    ref.read(myBetHubControllerProvider).changeMenu(MyBetMenu.myBets);
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

  Widget _buildContent(ParlayState state) => switch (state.tab) {
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
