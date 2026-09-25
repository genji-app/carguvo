import 'package:flutter/material.dart' hide BoxShadow;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/shared/widgets/balance_container.dart';

class WalletBalanceView extends ConsumerWidget implements PreferredSizeWidget {
  const WalletBalanceView({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceVND = ref.watch(balanceInVNDProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF000000),
                  Color(0x00000000),
                ],
                stops: [
                  0.0,
                  1.0,
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColorStyles.borderSecondary,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: BalanceContainer(balance: balanceVND, width: 210),
        ),
      ],
    );
  }
}
