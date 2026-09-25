import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/features/game/game.dart';

import 'game_lobby_failure_view.dart';

class GameLobbyView extends ConsumerWidget {
  const GameLobbyView({super.key, this.onGamePressed}) : _isSliver = false;

  const GameLobbyView.sliver({super.key, this.onGamePressed})
    : _isSliver = true;

  final void Function(LobbyGame gameBlock)? onGamePressed;
  final bool _isSliver;

  Widget _wrapSliver(Widget child) {
    return _isSliver ? SliverToBoxAdapter(child: child) : child;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lobbyState = ref.watch(gameLobbyProvider);

    if (lobbyState.isLoading) {
      return _wrapSliver(const GameLobbyShimmer());
    }

    if (lobbyState.isFailure) {
      return _wrapSliver(
        GameLobbyFailureView(onRetry: () => refreshGameLobby(ref)),
      );
    }

    if (lobbyState.lobbyBlocks.isEmpty) {
      return _wrapSliver(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(I18n.txtNoGamesAvailable),
          ),
        ),
      );
    }

    final itemCount = lobbyState.lobbyBlocks.length * 2 - 1;

    Widget itemBuilder(BuildContext context, int index) {
      if (index.isOdd) {
        return const SizedBox(height: 24);
      }

      final itemIndex = index ~/ 2;
      final item = lobbyState.lobbyBlocks[itemIndex];

      return switch (item) {
        LobbyBannerBlock() => const RepaintBoundary(child: BannerProviders()),
        LobbyGroupBlock() => GameHorizontalSection(
            title: Text(item.displayTitle),
            games: item.games,
            onGamePressed: onGamePressed,
          ),
      };
    }

    if (_isSliver) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
