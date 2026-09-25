import 'package:flutter/cupertino.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

class Sun88LoadingIndicator extends StatelessWidget {
  const Sun88LoadingIndicator({super.key});

  const Sun88LoadingIndicator.withDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      const CupertinoActivityIndicator(color: AppColorStyles.contentSecondary);
}
