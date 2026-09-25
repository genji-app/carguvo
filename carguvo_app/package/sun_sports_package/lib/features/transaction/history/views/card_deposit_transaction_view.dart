import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/pagination/pagination.dart';
import 'package:sun_sports/core/services/repositories/transaction_repository/transaction_repository.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:sun_sports/features/transaction/transaction.dart';
import 'package:sun_sports/shared/animations/animations.dart';
import 'package:sun_sports/shared/listener/listener.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/slivers/slivers.dart';

class CardDepositTransactionView extends ConsumerWidget {
  const CardDepositTransactionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = TransactionFilter.cardDeposit;
    final canLoadMore = ref.watch(
      transactionHistoryProvider(filter).select((s) => s.canLoadMore),
    );
    final notifier = ref.read(transactionHistoryProvider(filter).notifier);

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await notifier.refresh();
      },
      child: LoadMoreListener(
        onLoadMore: notifier.loadMore,
        listen: canLoadMore,
        child: CustomScrollView(
          key: const PageStorageKey<String>(
            'card_deposit_transaction_scroll_key',
          ),
          slivers: [
            const SliverToBoxAdapter(child: Gap(20)),
            Consumer(
              builder: (context, ref, _) {
                final data = ref.watch(
                  transactionHistoryProvider(filter).select((s) => s.data),
                );
                return DateGroupedSliverList(
                  data ?? [],
                  onItemPressed: (t) {
                    ref
                        .read(transactionNavigatorProvider)
                        .pushToTransactionDetails(context, t);
                  },
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final status = ref.watch(
                  transactionHistoryProvider(filter).select((s) => s.status),
                );

                return switch (status) {
                  PaginatedStatus.loading => const SliverLoadingIndicator(),
                  PaginatedStatus.loadingMore => const SliverLoadingIndicator(),
                  PaginatedStatus.noData => _SliverNoTransactionData(
                    onDepositPressed: () => showDepositFlow(context, ref),
                  ),
                  PaginatedStatus.error => SliverFillLoadingError(
                    message: const Text(I18n.msgSomethingWentWrong),
                    onRetry: notifier.loadInitial,
                  ),
                  _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
                };
              },
            ),
            const SliverBottomPadding(),
          ],
        ),
      ),
    );
  }
}

class _SliverNoTransactionData extends StatelessWidget {
  const _SliverNoTransactionData({this.onDepositPressed});

  final VoidCallback? onDepositPressed;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: ImmediateOpacityAnimation(
        duration: Durations.short4,
        child: Container(
          alignment: AlignmentDirectional.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 160,
                child: ImageHelper.load(
                  path: AppImages.imgTransactionEmpty,
                  fit: BoxFit.contain,
                ),
              ),
              const Gap(48),
              DefaultTextStyle(
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
                child: const Text(I18n.msgNoTransaction),
              ),
              const Gap(16),
              ShineButton(
                style: ShineButtonStyle.primaryYellow,
                text: I18n.msgDepositNow,
                onPressed: onDepositPressed,
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
