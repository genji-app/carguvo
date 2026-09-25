import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/providers/live_chat_expanded_provider.dart';
import 'package:sun_sports/core/providers/scroll_hide_provider.dart';
import 'package:sun_sports/providers/auth_provider.dart';
import 'package:sun_sports/providers/main_content_provider.dart';
import 'package:sun_sports/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:sun_sports/shared/widgets/chat/chat_login_overlay.dart';
import 'package:sun_sports/shared/widgets/authenticated_widget.dart';
import 'package:sun_sports/shared/layouts/shell_scroll_header_bar.dart';

const shellGuestChatContentTypes = {
  MainContentType.home,
  MainContentType.sport,
  MainContentType.live,
  MainContentType.upcoming,
  MainContentType.tournaments,
  MainContentType.leagueDetail,
  MainContentType.sportDetail,
  MainContentType.betDetail,
};

final shellHasChatProvider = Provider<bool>((ref) {
  if (ref.watch(isAuthenticatedProvider)) return true;
  return shellGuestChatContentTypes.contains(ref.watch(mainContentProvider));
});

abstract final class ShellTopMetrics {
  static const double header = ScrollHideNotifier.headerHeight;

  static const double chatCollapsed = ChatLineMetrics.collapsed;

  static const double chatExpanded = ChatLineMetrics.expanded;

  static double chat(WidgetRef ref) {
    final authed = ref.watch(isAuthenticatedProvider);
    return authed && ref.watch(liveChatExpandedProvider)
        ? chatExpanded
        : chatCollapsed;
  }

  static bool hasChat(WidgetRef ref) => ref.watch(shellHasChatProvider);

  static double blockHeight(WidgetRef ref) {
    return header + (hasChat(ref) ? chat(ref) : 0.0);
  }

  static double blockSlide(bool hasChat) => hasChat
      ? ScrollHideNotifier.maxOffset - ShellScrollHeaderBar.barHeight
      : ScrollHideNotifier.maxOffset;

  static double blockBottom({
    required double topPadding,
    required bool hasChat,
    required double chatHeight,
    required double hideProgress,
  }) {
    final headerVisible =
        header - hideProgress.clamp(0.0, 1.0) * blockSlide(hasChat);
    return topPadding + headerVisible + (hasChat ? chatHeight : 0.0);
  }
}

class ShellContentTopSpacer extends ConsumerWidget {
  const ShellContentTopSpacer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = ShellTopMetrics.blockHeight(ref);
    return SliverToBoxAdapter(
      child: SizedBox(height: height),
    );
  }
}

class ShellStickyLiveChatDelegate extends SliverPersistentHeaderDelegate {
  ShellStickyLiveChatDelegate({
    required this.minHeight,
    required this.maxHeight,
    this.onStickyChanged,
    this.showLoginOverlay = false,
    this.isMobile = false,
  });

  final double minHeight;
  final double maxHeight;
  final ValueChanged<bool>? onStickyChanged;
  final bool showLoginOverlay;
  final bool isMobile;

  bool _lastStickyState = false;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isSticky = shrinkOffset >= maxHeight - minHeight;
    if (isSticky != _lastStickyState) {
      _lastStickyState = isSticky;
      onStickyChanged?.call(isSticky);
    }

    Widget chatChild = const RepaintBoundary(
      child: SportLiveChat(isMobile: true),
    );

    if (showLoginOverlay) {
      chatChild = AuthenticatedWidget(
        fallback: ChatLoginOverlay(isMobile: isMobile),
        child: chatChild,
      );
    }

    return Container(
      color: const Color(0xFF141414),
      height: maxHeight,
      child: chatChild,
    );
  }

  @override
  bool shouldRebuild(covariant ShellStickyLiveChatDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight;
  }
}

class ShellLiveChatSliver extends ConsumerWidget {
  const ShellLiveChatSliver({
    super.key,
    this.onStickyChanged,
    this.showLoginOverlay = false,
    this.isMobile = false,
  });

  final ValueChanged<bool>? onStickyChanged;
  final bool showLoginOverlay;
  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final isExpanded = ref.watch(liveChatExpandedProvider);
    final liveChatHeight =
        isExpanded ? ShellTopMetrics.chatExpanded : ShellTopMetrics.chatCollapsed;

    return SliverPersistentHeader(
      pinned: true,
      delegate: ShellStickyLiveChatDelegate(
        minHeight: liveChatHeight,
        maxHeight: liveChatHeight,
        onStickyChanged: onStickyChanged,
        showLoginOverlay: showLoginOverlay,
        isMobile: isMobile,
      ),
    );
  }
}
