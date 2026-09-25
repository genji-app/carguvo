import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

import 'profile_hub.dart';

class ProfileHubAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ProfileHubAppBar({
    super.key,
    this.title,
    this.backgroundColor,
    this.surfaceColor = AppColorStyles.contentPrimary,
    this.padding = kPadding,
    this.onBackPressed,
    this.showBack = true,
    this.titleStyle,
    this.hideBack = false,
  }) : _autoHandleBack = false;

  const ProfileHubAppBar.autoBack({
    super.key,
    this.title,
    this.backgroundColor,
    this.surfaceColor = AppColorStyles.contentPrimary,
    this.padding = kPadding,
    this.titleStyle,
    this.hideBack = false,
  }) : _autoHandleBack = true,
       showBack = true,
       onBackPressed = null;

  const ProfileHubAppBar.closeOnly({
    super.key,
    this.title,
    this.backgroundColor,
    this.surfaceColor = AppColorStyles.contentPrimary,
    this.padding = kPadding,
    this.titleStyle,
  }) : _autoHandleBack = false,
       showBack = false,
       onBackPressed = null,
       hideBack = false;

  static const kPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 12);

  final Widget? title;
  final Color? backgroundColor;
  final Color? surfaceColor;
  final EdgeInsets? padding;
  final VoidCallback? onBackPressed;
  final bool _autoHandleBack;
  final bool showBack;
  final TextStyle? titleStyle;

  final bool hideBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    VoidCallback? effectiveOnBackPressed;
    if (_autoHandleBack) {
      final navigator = Navigator.of(context);
      final canPop = navigator.canPop();
      final goBack = canPop ? () => navigator.pop() : null;
      effectiveOnBackPressed = onBackPressed ?? goBack;
    }

    final profileNavigator = ProfileHub.maybeOf(context);
    final showCloseButton = profileNavigator != null;
    final handleClose = profileNavigator?.close;

    return SizedBox.expand(
      child: Container(
        padding: padding,
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 12,
          children: [
            if (showBack)
              hideBack
                  ? const SizedBox.square(dimension: 36)
                  : _AppBarAction(
                      icon: ImageHelper.load(
                        path: AppIcons.icBack,
                        fit: BoxFit.fill,
                      ),
                      onPressed: effectiveOnBackPressed,
                    ),
            if (title != null)
              Flexible(
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headingXXXSmall(
                    color: surfaceColor,
                  ).merge(titleStyle),
                  child: title!,
                ),
              ),

            !showCloseButton
                ? const SizedBox.shrink()
                : _AppBarAction(
                    onPressed: handleClose,
                    icon: const Icon(Icons.close),
                  ),
          ],
        ),
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({this.icon, this.onPressed});

  final Widget? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      color: AppColorStyles.contentSecondary,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(36),
        disabledBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        side: BorderSide.none,
        disabledForegroundColor: AppColorStyles.contentSecondary,
        foregroundColor: AppColorStyles.contentSecondary,
      ),
      padding: EdgeInsets.zero,
      iconSize: 24,
      onPressed: SoundTap.wrap(onPressed),
      icon: SizedBox.square(dimension: 24, child: icon),
    );
  }
}
