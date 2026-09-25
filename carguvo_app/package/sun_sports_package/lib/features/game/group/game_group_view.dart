import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/game/game.dart';

class GameGroupView extends ConsumerWidget {
  const GameGroupView({
    required this.collectionId,
    super.key,
    this.onGamePressed,
    this.title,
    this.spacing,
    this.horizontalPadding,
  });

  const GameGroupView.featured({
    this.collectionId = 'featured',
    super.key,
    this.onGamePressed,
    this.title = const Text('Casino nổi bật'),
    this.spacing = 8,
    this.horizontalPadding = 4,
  });

  const GameGroupView.liveCasino({
    this.collectionId = 'live',
    super.key,
    this.onGamePressed,
    this.title = const Text('Live Casino'),
    this.spacing = 8,
    this.horizontalPadding = 4,
  });

  final String collectionId;

  final void Function(LobbyGame game)? onGamePressed;

  final Widget? title;

  final double? spacing;

  final double? horizontalPadding;

  void _defaultOnGamePressed(
    BuildContext context,
    WidgetRef ref,
    LobbyGame game,
  ) => ref.read(gameLauncherProvider.notifier).launch(context, game);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gameCollectionProvider(collectionId));

    if (games.isEmpty) {
      final ready = ref.watch(lobbyConfigReadyProvider);
      return ready.maybeWhen(
        data: (_) => const SizedBox.shrink(),
        orElse: () => const GameHorizontalSectionShimmer(),
      );
    }

    return GameHorizontalSection(
      title: title,
      games: games,
      horizontalPadding: horizontalPadding,
      spacing: spacing,
      onGamePressed:
          onGamePressed ?? (game) => _defaultOnGamePressed(context, ref, game),
    );
  }
}
