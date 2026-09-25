import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class GamePlayerNewTabPlaceholder extends ConsumerStatefulWidget {
  const GamePlayerNewTabPlaceholder({
    required this.game,
    required this.gameUrl,
    required this.alreadyOpened,
    required this.onOpened,
    required this.onClose,
    super.key,
  });

  final LobbyGame game;
  final String gameUrl;
  final bool alreadyOpened;
  final VoidCallback onOpened;
  final VoidCallback onClose;

  @override
  ConsumerState<GamePlayerNewTabPlaceholder> createState() =>
      _GamePlayerNewTabPlaceholderState();
}

class _GamePlayerNewTabPlaceholderState
    extends ConsumerState<GamePlayerNewTabPlaceholder> {
  bool _popupBlocked = false;

  @override
  void initState() {
    super.initState();
    if (!widget.alreadyOpened) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openGameTab();
      });
    }
  }

  void _openGameTab() {
    final popupSuccess = openNewTab(widget.gameUrl);
    if (!popupSuccess) {
      if (mounted) setState(() => _popupBlocked = true);
      return;
    }

    widget.onOpened();
  }

  @override
  Widget build(BuildContext context) {
    return GamePlayerBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_new_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text(
                _popupBlocked
                    ? 'Trình duyệt đã chặn popup'
                    : 'Game đang chơi ở tab khác',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.game.gameName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_popupBlocked) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Mở lại game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: SoundTap.wrap(_openGameTab),
                ),
                const SizedBox(height: 12),
              ],
              TextButton(
                onPressed: SoundTap.wrap(widget.onClose),
                child: Text(
                  'Quay lại',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
