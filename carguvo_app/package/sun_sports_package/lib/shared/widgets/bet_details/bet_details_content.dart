import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/betting_api_error_messages.dart';
import 'package:sun_sports/features/sport/presentation/providers/events_v2_provider.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/providers/betting_popup_provider.dart';
import 'package:sun_sports/shared/widgets/bet_details/widgets/bet_details_header.dart';
import 'package:sun_sports/shared/widgets/bet_details/widgets/match_stats_table.dart';
import 'package:sun_sports/shared/widgets/bet_details/widgets/handicap_section.dart';
import 'package:sun_sports/shared/widgets/bet_details/widgets/bet_amount_section.dart';
import 'package:sun_sports/shared/widgets/bet_details/widgets/bet_action_section.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

bool _isSpecialOutrightBet(BettingPopupData? data) {
  if (data == null) return false;
  return data.isSpecialOutright;
}

String _outrightSelectionLabel(BettingPopupData data) {
  return switch (data.outrightKind) {
    OutrightKind.player => 'Cầu thủ',
    OutrightKind.team => 'Đội',
    OutrightKind.groupWinner => 'Đội nhất bảng',
    OutrightKind.goalscorerAnytime ||
    OutrightKind.goalscorerFirst ||
    OutrightKind.goalscorerLast ||
    OutrightKind.hatTrick => 'Cầu thủ',
    OutrightKind.matchSpecial => 'Lựa chọn',
    OutrightKind.champion => 'Đội vô địch',
  };
}

String _outrightHintTitle(BettingPopupData data) {
  return switch (data.outrightKind) {
    OutrightKind.player => 'Cầu Thủ',
    OutrightKind.team => 'Đội',
    OutrightKind.groupWinner => 'Đội Nhất Bảng',
    OutrightKind.goalscorerAnytime => 'Cầu Thủ Ghi Bàn',
    OutrightKind.goalscorerFirst => 'Cầu Thủ Ghi Bàn Đầu Tiên',
    OutrightKind.goalscorerLast => 'Cầu Thủ Ghi Bàn Cuối Cùng',
    OutrightKind.hatTrick => 'Cầu Thủ Lập Hat-trick',
    OutrightKind.matchSpecial => 'Kèo Đặc Biệt',
    OutrightKind.champion => 'Đội Vô Địch',
  };
}

class BetDetailsContent extends ConsumerStatefulWidget {
  const BetDetailsContent({
    super.key,
    this.isMobile = false,
    this.isVibrating = false,
    this.isBottomSheet = false,
  });
  final bool isMobile;
  final bool isVibrating;
  final bool isBottomSheet;

  @override
  ConsumerState<BetDetailsContent> createState() => _BetDetailsContentState();
}

class _BetDetailsContentState extends ConsumerState<BetDetailsContent> {
  final _scrollController = ScrollController();

  bool _didAutoScroll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScrollToBottom());
  }

  void _autoScrollToBottom() {
    if (_didAutoScroll || !mounted) return;
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_didAutoScroll || !mounted || !_scrollController.hasClients) return;
        final retryMax = _scrollController.position.maxScrollExtent;
        if (retryMax <= 0) return;
        _didAutoScroll = true;
        _scrollController.animateTo(
          retryMax,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      return;
    }

    _didAutoScroll = true;
    _scrollController.animateTo(
      maxScroll,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isClosing = false;

  @override
  Widget build(BuildContext context) {
    final bettingState = ref.watch(bettingPopupProvider);
    final bettingNotifier = ref.read(bettingPopupProvider.notifier);

    if (bettingState.isClosed && !_isClosing) {
      _isClosing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentState = ref.read(bettingPopupProvider);
        if (!currentState.isClosed) {
          _isClosing = false;
          return;
        }

        if (currentState.error != null && context.mounted) {
          AppToast.showError(context, message: currentState.error!);

          final isOddsChangedError = bettingApiErrorIndicatesOddsChanged(
            errorCode: currentState.errorCode,
            message: currentState.error,
          );
          if (isOddsChangedError) {
            ref.read(eventsV2Provider.notifier).refresh();
          }
        }
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BetDetailsHeader(
            isVibrating: widget.isVibrating,
            isMobile: widget.isMobile,
            isBottomSheet: widget.isBottomSheet,
          ),
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isSpecialOutrightBet(bettingState.bettingData))
                          _SpecialOutrightBetDetails(
                            data: bettingState.bettingData,
                            currentOdds: bettingState.getCurrentOdds(),
                            stake: int.tryParse(bettingState.betAmount) ?? 100,
                          )
                        else ...[
                          MatchStatsTable(
                            data: bettingState.bettingData,
                            isVibrating: widget.isVibrating,
                          ),
                          const SizedBox(height: 8),
                          HandicapSection(
                            data: bettingState.bettingData,
                            currentOdds: bettingState.getCurrentOdds(),
                            stake: int.tryParse(bettingState.betAmount) ?? 100,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isSpecialOutrightBet(bettingState.bettingData) &&
                      bettingState.bettingData?.marketData.isParlay ==
                          false) ...[
                    const _ParlayNotSupportedNotification(),
                    const SizedBox(height: 16),
                  ],
                  ImageHelper.load(
                    path: AppIcons.sunLine,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BetAmountSection(
                      betAmount: bettingState.betAmount,
                      onBetAmountChanged: (amount) {
                        final cleanAmount = amount.replaceAll(',', '');
                        bettingNotifier.updateBetAmount(cleanAmount);
                      },
                      data: bettingState.bettingData,
                      minStake: bettingState.minStake,
                      maxStake: bettingState.maxStake,
                      userBalance: ref.watch(balanceInVNDProvider).floor(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          BetActionSection(isMobile: widget.isMobile),
        ],
      ),
    );
  }
}

class _ParlayNotSupportedNotification extends StatelessWidget {
  const _ParlayNotSupportedNotification();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x1FEF6820),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.orange500, size: 24),
          const Gap(12),
          Text(
            'Vé này không hỗ trợ cược xiên',
            style: AppTextStyles.labelMedium(color: AppColors.orange200),
          ),
        ],
      ),
    ),
  );
}

class _SpecialOutrightBetDetails extends StatelessWidget {
  final BettingPopupData? data;
  final double? currentOdds;
  final int stake;

  const _SpecialOutrightBetDetails({
    this.data,
    this.currentOdds,
    this.stake = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();

    final leagueLogo = data!.leagueData?.leagueLogo ?? '';

    final eventName = data!.eventData.eventName ?? '';
    final outrightName = eventName.isNotEmpty
        ? eventName
        : data!.getLeagueName().isNotEmpty
        ? data!.getLeagueName()
        : 'Outright Bet';

    String selectionName;
    if (data!.eventData.homeName.isNotEmpty) {
      selectionName = data!.eventData.homeName;
    } else if (data!.eventData.awayName.isNotEmpty) {
      selectionName = data!.eventData.awayName;
    } else {
      selectionName = data!.getSelectionName();
    }

    final oddsValue = data!.getDisplayOdds();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Positioned.fill(
              child: ImageHelper.load(
                path: AppIcons.backgroundSpecialLeague,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(96),
                      child: leagueLogo.isNotEmpty
                          ? ImageHelper.load(
                              path: leagueLogo,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorWidget: ImageHelper.load(
                                path: AppIcons.iconSoccer,
                                width: 48,
                                height: 48,
                              ),
                            )
                          : ImageHelper.load(
                              path: AppIcons.iconSoccer,
                              width: 48,
                              height: 48,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final yearPattern = RegExp(r'\d{4}/\d{4}');
                        final match = yearPattern.firstMatch(outrightName);

                        String leagueName;
                        String seasonInfo;

                        if (data!.outrightMatchName.isNotEmpty) {
                          leagueName = data!.outrightMatchName;
                          seasonInfo = outrightName;
                        } else if (match != null) {
                          leagueName = outrightName
                              .substring(0, match.start)
                              .trim();
                          seasonInfo = outrightName
                              .substring(match.start)
                              .trim();
                        } else {
                          leagueName = outrightName;
                          seasonInfo = '';
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              leagueName,
                              style: AppTextStyles.labelSmall(
                                color: AppColorStyles.contentPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (seasonInfo.isNotEmpty) ...[
                              const Gap(2),
                              Text(
                                seasonInfo,
                                style: AppTextStyles.labelSmall(
                                  color: AppColors.cyan500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _outrightSelectionLabel(data!),
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppColors.yellow300.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        selectionName.isNotEmpty ? selectionName : 'N/A',
                        style: AppTextStyles.labelMedium(
                          color: AppColors.yellow300,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: SoundTap.wrap(() => _showHintBubble(context)),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.help_outline,
                        size: 18,
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    oddsValue,
                    style: AppTextStyles.labelMedium(color: AppColors.green300),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showHintBubble(BuildContext context) {
    if (data == null) return;

    final odds = currentOdds ?? data!.getSelectedOddsValue();

    final stakeInVND = stake.toDouble();

    final hintData = HintDataFactory.fromBettingPopup(
      popupData: data!,
      currentOdds: odds,
      stake: stakeInVND,
    );

    showHintBubble(
      context: context,
      hintData: hintData,
      titleOverride: _outrightHintTitle(data!),
    );
  }
}
