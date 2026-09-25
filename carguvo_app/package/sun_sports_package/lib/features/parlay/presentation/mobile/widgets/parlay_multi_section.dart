import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ParlayMultiSection extends ConsumerStatefulWidget {
  const ParlayMultiSection({super.key});

  @override
  ConsumerState<ParlayMultiSection> createState() => _ParlayMultiSectionState();
}

class _ParlayMultiSectionState extends ConsumerState<ParlayMultiSection> {
  final _formatter = NumberFormat.decimalPattern('vi');
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final bets = ref.read(multiBetsProvider);
    for (var i = 0; i < bets.length; i++) {
      _controllers[i] = TextEditingController(
        text: bets[i].stake > 0 ? _formatter.format(bets[i].stake) : '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiBets = ref.watch(multiBetsProvider);
    final notifier = ref.read(parlayStateProvider.notifier);

    ref.listen<List<ParlayMultiBet>>(multiBetsProvider, (previous, next) {
      if (previous?.length != next.length) {
        return;
      }
      for (var i = 0; i < next.length; i++) {
        final previousStake = previous?[i].stake;
        final currentStake = next[i].stake;
        if (previousStake == currentStake) continue;
        final formatted = currentStake > 0
            ? _formatter.format(currentStake)
            : '';
        final controller = _controllers[i] ??= TextEditingController(
          text: formatted,
        );
        if (controller.text != formatted) {
          controller.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    });

    for (var i = 0; i < multiBets.length; i++) {
      _controllers.putIfAbsent(
        i,
        () => TextEditingController(
          text: multiBets[i].stake > 0
              ? _formatter.format(multiBets[i].stake)
              : '',
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < multiBets.length; i++) ...[
          _MultiBetCard(
            bet: multiBets[i],
            formatter: _formatter,
            controller: _controllers[i]!,
            onChanged: (raw) {
              final numeric = raw.replaceAll(RegExp(r'[^0-9]'), '');
              if (numeric.isEmpty) {
                notifier.clearMultiStake(i);
                return;
              }
              notifier.setMultiStake(i, int.parse(numeric));
            },
            onClear: () => notifier.clearMultiStake(i),
          ),
          if (i < multiBets.length - 1) const Gap(8),
        ],
      ],
    );
  }
}

class _MultiBetCard extends StatelessWidget {
  final ParlayMultiBet bet;
  final NumberFormat formatter;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _MultiBetCard({
    required this.bet,
    required this.formatter,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (bet.isLive) ...[_PulseDot(), const Gap(8)],
                        Expanded(
                          child: Text(
                            bet.status,
                            style: AppTextStyles.labelSmall(
                              color: AppColorStyles.contentSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      bet.title,
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: SoundTap.wrap(() {}),
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(255, 255, 255, 0.12),
                Color.fromRGBO(255, 255, 255, 0.06),
                Color.fromRGBO(255, 255, 255, 0),
              ],
              stops: [0, 0.12, 1],
            ),
            color: AppColorStyles.backgroundQuaternary,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bet.market,
                      style: AppTextStyles.paragraphXSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      bet.pick,
                      style: AppTextStyles.labelMedium(
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ImageHelper.load(
                    path: AppIcons.iconInfo,
                    width: 18,
                    height: 18,
                    color: AppColorStyles.contentSecondary,
                  ),
                  const Gap(6),
                  Text(
                    bet.odd.toStringAsFixed(2),
                    style: AppTextStyles.labelMedium(
                      color: const Color(0xFFFDE272),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColorStyles.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColorStyles.borderPrimary,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.labelMedium(
                          color: AppColorStyles.contentPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Nhập số tiền',
                          hintStyle: AppTextStyles.labelMedium(
                            color: AppColorStyles.contentTertiary,
                          ),
                        ),
                        onChanged: onChanged,
                      ),
                    ),
                    const Gap(12),
                    const SCoinIcon(),
                    const Gap(12),
                    InkWell(
                      onTap: SoundTap.wrap(onClear),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColorStyles.backgroundTertiary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColorStyles.contentPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _LimitText(label: 'Min:', value: bet.minStake),
                  _LimitText(label: 'Max:', value: bet.maxStake),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LimitText extends StatelessWidget {
  final String label;
  final int value;

  const _LimitText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: AppTextStyles.labelXSmall(
          color: AppColorStyles.contentSecondary,
        ),
      ),
      const Gap(4),
      Text(
        NumberFormat.decimalPattern('vi').format(value),
        style: AppTextStyles.labelXSmall(color: AppColorStyles.contentPrimary),
      ),
    ],
  );
}

class _PulseDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 20,
    height: 20,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFFF5172).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: const Color(0xFFFF5172).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFFFF5172),
            shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );
}
