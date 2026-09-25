import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/error/betting_api_error_messages.dart';
import 'package:sun_sports/core/services/websocket/betslip_subscription_manager.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/bet_success/bet_success.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_header.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_match_card.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_multi_section.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_shimmer_loading.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_stake_section.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_summary_section.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_tab_bar.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class ParlayMobileScreen extends ConsumerStatefulWidget {
  const ParlayMobileScreen({super.key});

  @override
  ConsumerState<ParlayMobileScreen> createState() => _ParlayMobileScreenState();
}

class _ParlayMobileScreenState extends ConsumerState<ParlayMobileScreen> {
  bool _hasTriggeredRecalculate = false;

  bool _isPlacingBet = false;

  bool _showSuccessView = false;

  List<SingleBetData> _successfulBets = [];

  bool _showComboSuccessView = false;

  ComboBetSuccessData? _comboBetSuccessData;

  @override
  void initState() {
    super.initState();
    BetslipSubscriptionManager.instance?.setSlipVisible(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerRecalculateIfReady();
    });
  }

  @override
  void dispose() {
    BetslipSubscriptionManager.instance?.setSlipVisible(false);
    super.dispose();
  }

  void _triggerRecalculateIfReady() {
    if (!mounted || _hasTriggeredRecalculate) return;

    final isBettingReady = ref.read(isBettingReadyProvider);
    if (isBettingReady) {
      _hasTriggeredRecalculate = true;
      debugPrint(
        '[ParlayMobileScreen] Triggering recalculateAllBets on sheet open',
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
        '[ParlayMobileScreen] Syncing ${scoresMap.length} scores from events cache',
      );
      ref.read(parlayStateProvider.notifier).syncScoresFromCache(scoresMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(
      parlayStateProvider.select((state) => state.tab),
    );
    final isBettingReady = ref.watch(isBettingReadyProvider);

    ref.listen<bool>(isBettingReadyProvider, (previous, next) {
      if (next && !_hasTriggeredRecalculate) {
        _hasTriggeredRecalculate = true;
        debugPrint(
          '[ParlayMobileScreen] Triggering recalculateAllBets on betting ready',
        );
        ref.read(parlayStateProvider.notifier).recalculateAllBets();
      }
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(parlayStateProvider.notifier).saveAllToStorage();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, AppColorStyles.backgroundSecondary],
            stops: [0, 0.25],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColorStyles.backgroundSecondary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.75),
                    blurRadius: 80,
                    offset: Offset(-20, 4),
                  ),
                ],
              ),
              child: _showSuccessView
                  ? _buildSuccessView()
                  : _showComboSuccessView
                  ? _buildComboSuccessView()
                  : AbsorbPointer(
                      absorbing: _isPlacingBet,
                      child: Column(
                        children: [
                          const ParlayHeader(),
                          const ParlayTabBar(),
                          const Gap(12),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: isBettingReady
                                  ? _buildContent(currentTab)
                                  : _buildShimmerLoading(currentTab),
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
    );
  }

  Future<void> _handlePlaceBet() async {
    debugPrint('[ParlayMobileScreen] _handlePlaceBet called');

    final state = ref.read(parlayStateProvider);

    if (state.tab == ParlayTab.combo) {
      await _handlePlaceComboBet();
      return;
    }

    final betsToPlace = state.singleBets
        .where((bet) => bet.canPlaceBet)
        .toList();

    if (betsToPlace.isEmpty) {
      debugPrint('[ParlayMobileScreen] No valid bets to place');
      return;
    }

    setState(() {
      _isPlacingBet = true;
    });

    try {

      if (!mounted) return;

      if (true) {

        setState(() {
          _isPlacingBet = false;
        });

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        debugPrint('[ParlayMobileScreen] All bets failed');
        setState(() {
          _isPlacingBet = false;
        });
        if (mounted) {
        }
      }

    } catch (e) {
      debugPrint('[ParlayMobileScreen] Place bet error: $e');
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
    return '${formatter.format(amountInVnd)}';
  }

  Future<void> _handlePlaceComboBet() async {
    debugPrint('[ParlayMobileScreen] _handlePlaceComboBet called');

    final state = ref.read(parlayStateProvider);
    final comboBets = List<SingleBetData>.from(state.comboBets);

    if (comboBets.isEmpty) {
      return;
    }

    if (!state.canPlaceBet) {
      debugPrint(
        '[ParlayMobileScreen] Cannot place combo bet - validation failed',
      );
      return;
    }

    setState(() {
      _isPlacingBet = true;
    });

    try {
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

        debugPrint(
          '[ParlayMobileScreen] Combo bet placed successfully, closing sheet',
        );
        setState(() {
          _isPlacingBet = false;
        });

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        debugPrint('[ParlayMobileScreen] Combo bet placement failed');
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
      debugPrint('[ParlayMobileScreen] Place combo bet error: $e');
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
    Navigator.of(context).pop();
  }

  void _handleViewMyBets() {
    setState(() {
      _showSuccessView = false;
      _successfulBets = [];
    });
    Navigator.of(context).pop();
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
    Navigator.of(context).pop();
  }

  void _handleViewMyBetsCombo() {
    setState(() {
      _showComboSuccessView = false;
      _comboBetSuccessData = null;
    });
    Navigator.of(context).pop();
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
