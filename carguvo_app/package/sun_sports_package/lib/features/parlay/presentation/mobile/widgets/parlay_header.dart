import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/widgets/parlay_match_card.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ParlayHeader extends StatefulWidget {
  final VoidCallback? onClose;

  final int? badgeCountOverride;

  const ParlayHeader({super.key, this.onClose, this.badgeCountOverride});

  @override
  State<ParlayHeader> createState() => _ParlayHeaderState();
}

class _ParlayHeaderState extends State<ParlayHeader>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: SoundTap.wrap(_toggleExpand),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageHelper.load(
                        path: AppIcons.iconBet,
                        width: 24,
                        height: 24,
                      ),
                      const Gap(8),
                      Text(
                        'Phiếu cược',
                        style: AppTextStyles.labelSmall(
                          color: AppColorStyles.contentPrimary,
                        ),
                      ),
                      const Gap(8),
                      Consumer(
                        builder: (context, ref, _) {
                          final int totalBetCount =
                              widget.badgeCountOverride ??
                              ref.watch(totalBetCountProvider);
                          if (totalBetCount <= 0)
                            return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.yellow400,
                              borderRadius: BorderRadius.circular(1000),
                            ),
                            child: Text(
                              totalBetCount > 99
                                  ? '99+'
                                  : totalBetCount.toString(),
                              style: AppTextStyles.labelXSmall(
                                color: AppColors.gray950,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          );
                        },
                      ),
                      const Gap(5),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more_rounded,
                          size: 27,
                          color: AppColorStyles.contentSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                onPressed: SoundTap.wrap(widget.onClose ?? () => Navigator.of(context).pop()),
                icon: const Icon(
                  Icons.close,
                  size: 24,
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            ],
          ),
        ),
        SlideTransition(
          position: _slideAnimation,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: _isExpanded ? 1.0 : 0.0,
              child: Container(
                color: AppColorStyles.backgroundSecondary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: const ParlayMatchCard(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
