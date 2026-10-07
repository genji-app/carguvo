import 'package:flutter/material.dart';
import 'package:app_package/features/sport/presentation/widgets/sport_hot_section.dart';
import 'package:app_package/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:app_package/shared/widgets/authenticated_widget.dart';
import 'package:app_package/shared/widgets/chat/chat_login_overlay.dart';

class SportDesktopRightSidebar extends StatelessWidget {
  const SportDesktopRightSidebar({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 340,
    child: Container(
      padding: const EdgeInsets.all(12),
      child: const Column(
        children: [
          SportHotSection(),
          SizedBox(height: 12),
          Expanded(
            child: AuthenticatedWidget(
              fallback: ChatLoginOverlay(),
              child: SportLiveChat(),
            ),
          ),
        ],
      ),
    ),
  );
}
