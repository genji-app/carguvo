import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/platform_utils.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';

import 'profile_hub_appbar.dart';

class ProfileHubScaffold extends StatelessWidget {
  const ProfileHubScaffold({
    super.key,
    this.backgroundColor = AppColorStyles.backgroundSecondary,
    this.bodyPadding = kBodyVerticalPadding,
    this.body,
    this.bodyBuilder,
    this.appBar,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.primary = true,
  }) : assert(
         body == null || bodyBuilder == null,
         'Cannot provide both body and bodyBuilder',
       );

  ProfileHubScaffold.withDefaultAppBar({
    Widget? title,
    super.key,
    this.backgroundColor = AppColorStyles.backgroundSecondary,
    this.bodyPadding = kBodyVerticalPadding,
    this.body,
    this.bodyBuilder,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.primary = true,
  }) : appBar = ProfileHubAppBar.autoBack(title: title),
       assert(
         body == null || bodyBuilder == null,
         'Cannot provide both body and bodyBuilder',
       );

  ProfileHubScaffold.withCenterTitle({
    Widget? title,
    super.key,
    this.backgroundColor = AppColorStyles.backgroundSecondary,
    this.bodyPadding = kBodyVerticalPadding,
    this.body,
    this.bodyBuilder,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    bool hideBack = false,
  }) : appBar = ProfileHubAppBar.autoBack(title: title, hideBack: hideBack),
       assert(
         body == null || bodyBuilder == null,
         'Cannot provide both body and bodyBuilder',
       );

  final Color? backgroundColor;
  final EdgeInsetsGeometry? bodyPadding;
  final Widget? body;
  final WidgetBuilder? bodyBuilder;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;
  final bool primary;

  static const kBodyHorizontalPadding = EdgeInsets.symmetric(horizontal: 12);
  static const kBodyVerticalPadding = EdgeInsets.only(top: 20);

  @override
  Widget build(BuildContext context) {
    final effectiveBody = bodyBuilder != null
        ? Builder(builder: bodyBuilder!)
        : body;

    return SafeArea(
      bottom: PlatformUtils.isAndroid,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: Container(padding: bodyPadding, child: effectiveBody),
        bottomNavigationBar: bottomNavigationBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        primary: primary,
      ),
    );
  }
}
