import 'package:flutter/material.dart';

import 'package:sun_sports/shared/widgets/status_information/status_information.dart';

class SliverFillLoadingError extends StatelessWidget {
  const SliverFillLoadingError({
    required this.message,
    this.onRetry,
    this.onChangeFilter,
    super.key,
  });

  final Widget message;
  final VoidCallback? onRetry;
  final VoidCallback? onChangeFilter;

  @override
  Widget build(BuildContext context) => SliverFillRemaining(
    hasScrollBody: false,
    child: LoadingError(
      message: message,
      onRetry: onRetry != null ? () => onRetry!() : null,
      onChangeFilter: onChangeFilter,
    ),
  );
}
