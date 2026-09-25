import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

class LiveIndicator extends StatelessWidget {
  final String? time;
  final bool isLive;

  const LiveIndicator({super.key, this.time, this.isLive = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLive) ...[
          Text('Live', style: AppTextStyles.labelXSmall(color: Colors.red)),
          const SizedBox(width: 4),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
        if (time != null) ...[
          const SizedBox(width: 8),
          Text(time!, style: AppTextStyles.labelXSmall()),
        ],
      ],
    );
  }
}
