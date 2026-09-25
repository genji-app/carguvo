import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/presentation/show_deposit_flow.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/scoin_icon.dart';

class SportTabletHeader extends StatelessWidget implements PreferredSizeWidget {
  const SportTabletHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveBuilder.responsive<double>(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );

    final fontSize = ResponsiveBuilder.responsive<double>(
      context,
      mobile: 12.0,
      tablet: 13.0,
      desktop: 14.0,
    );

    return Container(
      height: ResponsiveBuilder.responsive<double>(
        context,
        mobile: 56.0,
        tablet: 60.0,
        desktop: 60.0,
      ),
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                'Sunsport',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.zoom_in, size: 18, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                _StatItem(
                  label: 'Rút (24h):',
                  value: '55,22 tỷ',
                  fontSize: fontSize - 2,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'Thắng (24h):',
                  value: '105,35 tỷ',
                  fontSize: fontSize - 2,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'Online:',
                  value: '5,942',
                  fontSize: fontSize - 2,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'hakon-1000',
                      style: TextStyle(
                        fontSize: fontSize - 2,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '2,000,000,000',
                      style: TextStyle(
                        fontSize: fontSize - 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SCoinIcon(),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '4',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize - 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Phiếu', style: TextStyle(fontSize: fontSize - 2)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    Center(child: Icon(Icons.notifications_outlined, size: 18)),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Consumer(
                builder: (context, ref, _) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => showDepositFlow(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange[400]!, Colors.orange[600]!],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Nạp tiền',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize - 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final double fontSize;

  const _StatItem({
    Key? key,
    required this.label,
    required this.value,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
