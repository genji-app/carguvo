import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/notification/presentation/notification_provider.dart';

class NotificationPanelRoot extends ConsumerStatefulWidget {
  const NotificationPanelRoot({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationPanelRoot> createState() =>
      _NotificationPanelRootState();
}

class _NotificationPanelRootState extends ConsumerState<NotificationPanelRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(notificationsProvider);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
