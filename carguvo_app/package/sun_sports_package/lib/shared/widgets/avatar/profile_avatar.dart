import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({
    this.child,
    this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.fallback,
    this.onPressed,
    super.key,
  }) : url = null,
       _useProvider = false;

  const ProfileAvatar.url(
    this.url, {
    this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.fallback,
    this.onPressed,
    super.key,
  }) : child = null,
       _useProvider = false;

  const ProfileAvatar.user({
    this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.fallback,
    this.onPressed,
    super.key,
  }) : url = null,
       child = null,
       _useProvider = true;

  final BorderRadiusGeometry? borderRadius;
  final Size? size;
  final Widget? child;
  final Widget? fallback;
  final String? url;
  final VoidCallback? onPressed;
  final bool _useProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveUrl = _useProvider
        ? ref.watch(userInfoProvider)?.avatarUrl
        : url;

    final urlEmpty = effectiveUrl?.isEmpty ?? true;

    final Widget defaultFallback = _useProvider
        ? ImageHelper.load(path: AppIcons.avatar, fit: BoxFit.cover)
        : const SizedBox.shrink();

    final avatarWidget = urlEmpty
        ? (fallback ?? defaultFallback)
        : ImageHelper.load(path: effectiveUrl!, fit: BoxFit.cover);

    final effectiveBorderRadius = borderRadius is BorderRadius
        ? borderRadius as BorderRadius
        : null;

    final decorated = Ink(
      width: size?.width,
      height: size?.height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        border: Border.all(
          color: const Color(0x1FFFFCDB),
          width: 1.25,
        ),
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: child ?? avatarWidget,
      ),
    );

    if (onPressed != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: SoundTap.wrap(onPressed),
          borderRadius: effectiveBorderRadius,
          mouseCursor: SystemMouseCursors.click,
          child: decorated,
        ),
      );
    }

    return SizedBox.fromSize(size: size, child: decorated);
  }
}
