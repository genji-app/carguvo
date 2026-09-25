import 'package:flutter/widgets.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/shared/widgets/input/input.dart';

class GameFilterInput extends StatelessWidget {
  const GameFilterInput({super.key, this.onChanged, this.dense = false});

  final void Function(String)? onChanged;

  final bool dense;

  @override
  Widget build(BuildContext context) {
    return StyledTextField(
      filled: true,
      fillColor: AppColorStyles.backgroundTertiary,
      hoverColor: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(10),
      isDense: dense,
      contentPadding: EdgeInsets.symmetric(
        vertical: dense ? 6 : 8,
        horizontal: 12,
      ),
      prefixIcon: SizedBox.square(
        dimension: 24,
        child: ImageHelper.load(path: AppIcons.icSearch),
      ),
      hintText: I18n.txtSearchGame,
      onChanged: onChanged,
    );
  }
}
