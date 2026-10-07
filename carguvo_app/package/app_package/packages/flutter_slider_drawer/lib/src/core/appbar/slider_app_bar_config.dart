import 'package:flutter/widgets.dart';

class SliderAppBarConfig {
  final Widget title;

  final Color? backgroundColor;

  final EdgeInsets? padding;

  final Widget? trailing;

  final Color drawerIconColor;

  final double drawerIconSize;

  final bool isCupertino;

  final Color? splashColor;

  const SliderAppBarConfig(
      {this.title = const Text('AppBar'),
      this.backgroundColor,
      this.padding,
      this.trailing,
      this.drawerIconColor = const Color(0xff2c2b2b),
      this.drawerIconSize = 27,
      this.isCupertino = false,
      this.splashColor});

  SliderAppBarConfig copyWith(
      {double? height,
      Widget? title,
      bool? isTitleCenter,
      Color? backgroundColor,
      EdgeInsets? padding,
      Widget? trailing,
      Color? drawerIconColor,
      Widget? drawerIcon,
      double? drawerIconSize,
      double? elevation,
      bool? isCupertino,
      Color? splashColor}) {
    return SliderAppBarConfig(
      title: title ?? this.title,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      trailing: trailing ?? this.trailing,
      drawerIconColor: drawerIconColor ?? this.drawerIconColor,
      drawerIconSize: drawerIconSize ?? this.drawerIconSize,
      isCupertino: isCupertino ?? this.isCupertino,
      splashColor: splashColor ?? this.splashColor,
    );
  }
}
