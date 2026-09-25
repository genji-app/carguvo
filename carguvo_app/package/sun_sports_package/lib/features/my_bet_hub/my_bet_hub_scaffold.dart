import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class MyBetHubScaffold extends StatelessWidget {
  const MyBetHubScaffold({
    super.key,
    this.backgroundColor = AppColorStyles.backgroundSecondary,
    this.bodyPadding = const EdgeInsets.only(top: 20),
    this.body,
    this.title,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.onClosePressed,
    this.onBackPressed,
  });

  final Color? backgroundColor;
  final EdgeInsetsGeometry? bodyPadding;
  final Widget? body;
  final Widget? title;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final VoidCallback? onClosePressed;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: PlatformUtils.isAndroid,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _MyBetAppBar(
          title: title,
          onClosePressed: onClosePressed,
          onBackPressed: onBackPressed,
        ),
        body: Container(padding: bodyPadding, child: body),
        bottomNavigationBar: bottomNavigationBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        primary: primary,
      ),
    );
  }
}

class _MyBetAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MyBetAppBar({this.title, this.onBackPressed, this.onClosePressed});

  final Widget? title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onClosePressed;

  static const kPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 12);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final canPop = navigator.canPop();
    final effectiveOnBackPressed =
        onBackPressed ?? (canPop ? () => navigator.pop() : null);

    final hasBackButton = effectiveOnBackPressed != null;
    final hasCloseButton = onClosePressed != null;

    return SizedBox.expand(
      child: Container(
        padding: kPadding,
        color: AppColorStyles.backgroundSecondary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 12,
          children: [
            if (hasBackButton)
              _AppBarAction(
                icon: ImageHelper.load(path: AppIcons.icBack, fit: BoxFit.fill),
                onPressed: effectiveOnBackPressed,
              )
            else
              const SizedBox(width: 36, height: 36),
            if (title != null)
              Flexible(
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headingXXXSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                  child: title!,
                ),
              ),
            if (hasCloseButton)
              _AppBarAction(
                onPressed: onClosePressed,
                icon: const Icon(Icons.close),
              )
            else
              const SizedBox(width: 36, height: 36),
          ],
        ),
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({required this.onPressed, required this.icon});

  final VoidCallback? onPressed;
  final Widget icon;

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
