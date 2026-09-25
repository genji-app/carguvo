import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sun_sports/features/game/player/game_player_experiments.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_casino_link.dart';
import 'package:sun_sports/features/mini_game/presentation/mini_game_minimized_hit_provider.dart';
import 'package:sun_sports/features/mini_game/presentation/widgets/mini_game_selection.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

class MiniGameMinimizedHitReporter extends ConsumerStatefulWidget {
  final String id;

  final MiniGameSelection game;

  final bool active;

  final Widget child;

  const MiniGameMinimizedHitReporter({
    required this.id,
    required this.game,
    required this.active,
    required this.child,
    super.key,
  });

  @override
  ConsumerState<MiniGameMinimizedHitReporter> createState() =>
      _MiniGameMinimizedHitReporterState();
}

class _MiniGameMinimizedHitReporterState
    extends ConsumerState<MiniGameMinimizedHitReporter> {
  final GlobalKey _boxKey = GlobalKey();

  StateController<Map<String, MiniGameMinimizedHit>>? _hits;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) _hits = ref.read(miniGameMinimizedHitsProvider.notifier);
  }

  @override
  void dispose() {
    final hits = _hits;
    final id = widget.id;
    if (hits != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => clearMiniGameMinimizedHitOn(hits, id, this),
      );
    }
    super.dispose();
  }

  void _report() {
    if (!kIsWeb || !mounted) return;
    if (!widget.active || !_needed) {
      ref.clearMiniGameMinimizedHit(widget.id, this);
      return;
    }
    final box = _boxKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    ref.setMiniGameMinimizedHit(
      id: widget.id,
      game: widget.game,
      rect: box.localToGlobal(Offset.zero) & box.size,
      owner: this,
    );
  }

  bool _needed = false;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;
    _needed =
        embedGameOnMobileWeb &&
        ref.watch(casinoGameOpenProvider) &&
        !ResponsiveBuilder.isDesktop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _report());
    return KeyedSubtree(key: _boxKey, child: widget.child);
  }
}
