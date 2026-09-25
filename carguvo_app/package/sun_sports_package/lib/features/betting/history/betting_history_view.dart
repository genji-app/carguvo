import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/pagination/paginated_notifier_mixin.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/shared/widgets/sb_tab_bar.dart';
import 'package:sun_sports/shared/widgets/slivers/slivers.dart';

import 'betting_history_provider.dart';

class BettingHistoryView extends ConsumerStatefulWidget {
  const BettingHistoryView({super.key});

  @override
  ConsumerState<BettingHistoryView> createState() => BettingHistoryViewState();
}

class BettingHistoryViewState extends ConsumerState<BettingHistoryView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bettingHistoryProvider.notifier).initialize();
      ref.read(userProvider.notifier).refreshBalance();
    });
  }

  void _onFilterChanged(MyBetFilter filter) {
    final notifier = ref.read(bettingHistoryProvider.notifier);
    notifier.setFilter(filter);
    notifier.loadInitial();
    ref.read(userProvider.notifier).refreshBalance();
  }

  Future<bool> _onSellConfirm(BetSlip bet) {
    final resellController = ref.read(betResellControllerProvider)(ref);
    return resellController.startResellFlow(context, bet);
  }

  Future<void> _onItemPressed(BetSlip bet) async {
    ref.read(bettingNavigatorProvider).pushToBetDetails(context, bet);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        ref.read(userProvider.notifier).refreshBalance();
        await ref.read(bettingHistoryProvider.notifier).refresh();
      },
      child: CustomScrollView(
        slivers: [
          PinnedHeaderSliver(
            child: BettingHistoryFilterTabbar(onChanged: _onFilterChanged),
          ),
          const SliverToBoxAdapter(child: Gap(20)),

          Consumer(
            builder: (context, ref, _) {
              final data =
                  ref.watch(bettingHistoryProvider.select((s) => s.data)) ?? [];
              return SliverPadding(
                sliver: BettingHistorySliverList(
                  data,
                  onSellConfirm: _onSellConfirm,
                  onItemPressed: _onItemPressed,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ).copyWith(bottom: 12),
              );
            },
          ),

          Consumer(
            builder: (context, ref, _) {
              final status = ref.watch(
                bettingHistoryProvider.select((s) => s.status),
              );
              return switch (status) {
                PaginatedStatus.loading => const SliverLoadingIndicator(),
                PaginatedStatus.loadingMore => const SliverLoadingIndicator(),
                PaginatedStatus.noData => const _SliverNoData(),
                PaginatedStatus.error => SliverFillLoadingError(
                  message: const Text(I18n.msgSomethingWentWrong),
                  onRetry: ref
                      .read(bettingHistoryProvider.notifier)
                      .loadInitial,
                ),
                _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
              };
            },
          ),
          const SliverBottomPadding(),
        ],
      ),
    );
  }
}

class BettingHistorySliverList extends StatelessWidget {
  const BettingHistorySliverList(
    this.data, {
    super.key,
    this.onItemPressed,
    this.onSellConfirm,
  });

  final List<BetSlip> data;
  final void Function(BetSlip bet)? onItemPressed;

  final Future<bool> Function(BetSlip bet)? onSellConfirm;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: data.length,
      separatorBuilder: (_, i) => const Gap(20),
      itemBuilder: (context, i) {
        final bet = data[i];

        final actionButton = bet.isCashoutAvailable
            ? BetSlipResellButton(
                buttonKey: bet.ticketId,
                onConfirm: () =>
                    onSellConfirm?.call(bet) ?? Future.value(false),
                amount: bet.cashOutAbleAmount?.toDouble() ?? 0,
              )
            : null;

        return BetSlipCard(
          bet: bet,
          onPressed: () => onItemPressed?.call(bet),
          actionButton: actionButton,
        );
      },
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
    );
  }
}

class BettingHistoryFilterTabbar extends StatelessWidget
    implements PreferredSizeWidget {
  const BettingHistoryFilterTabbar({this.onChanged, super.key});

  final ValueChanged<MyBetFilter>? onChanged;

  static final tabs = [
    SBTab(label: I18n.txtCurrentlyActive, icon: AppIcons.sportBetslipActive),
    SBTab(
      label: I18n.txtPaymentHasBeenMade,
      icon: AppIcons.sportBetslipHistory,
    ),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
    child: SBTabBar(
      initialIndex: 0,
      tabs: tabs,
      onChanged: (int value) {
        final filter = value == 0 ? MyBetFilter.active : MyBetFilter.settled;
        onChanged?.call(filter);
      },
    ),
  );
}

class _SliverNoData extends StatelessWidget {
  const _SliverNoData();

  @override
  Widget build(BuildContext context) {
    return SliverFillInfoMessage(
      primaryMessage: const Text(I18n.msgEmptyBettingSlip),
      secondaryMessage: const Text(I18n.msgStartBettingNow),
      image: SizedBox.square(
        dimension: 160,
        child: ImageHelper.load(
          path: AppImages.imgBetTicket,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
