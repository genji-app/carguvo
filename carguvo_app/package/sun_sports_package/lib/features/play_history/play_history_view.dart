import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/pagination/paginated_notifier_mixin.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/features/play_history/play_history.dart';
import 'package:sun_sports/shared/listener/listener.dart';
import 'package:sun_sports/shared/widgets/slivers/slivers.dart';

class PlayHistoryView extends ConsumerStatefulWidget {
  const PlayHistoryView({super.key});

  @override
  ConsumerState<PlayHistoryView> createState() => PlayHistoryViewState();
}

class PlayHistoryViewState extends ConsumerState<PlayHistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playHistoryProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async => ref.read(playHistoryProvider.notifier).refresh(),
      child: LoadMoreListener(
        onLoadMore: ref.read(playHistoryProvider.notifier).loadMore,
        child: const CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              sliver: PlayHistorySliverList(),
            ),
            PlayHistoryStatusFooter(),
            SliverBottomPadding(),
          ],
        ),
      ),
    );
  }
}

class PlayHistorySliverList extends ConsumerWidget {
  const PlayHistorySliverList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(playHistoryProvider.select((s) => s.data)) ?? [];
    return SliverList.separated(
      itemCount: items.length,
      separatorBuilder: (_, i) => const Gap(12),
      itemBuilder: (context, i) => PlayHistoryCard(items[i]),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
    );
  }
}

class PlayHistoryStatusFooter extends ConsumerWidget {
  const PlayHistoryStatusFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(playHistoryProvider.select((s) => s.status));
    return switch (status) {
      PaginatedStatus.loading => const SliverLoadingIndicator(),
      PaginatedStatus.loadingMore => const SliverLoadingIndicator(),
      PaginatedStatus.noData => const _SliverNoData(),
      PaginatedStatus.error => SliverFillLoadingError(
        message: const Text(I18n.msgSomethingWentWrong),
        onRetry: ref.read(playHistoryProvider.notifier).loadInitial,
      ),
      _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
    };
  }
}

class _SliverNoData extends StatelessWidget {
  const _SliverNoData();

  @override
  Widget build(BuildContext context) {
    return SliverFillInfoMessage(
      primaryMessage: const Text(I18n.msgEmptyPlayHistory),
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
