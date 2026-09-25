import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/buttons/buttons.dart';
import 'package:sun_sports/shared/widgets/form_control/form_control.dart';
import '../form_submit_button_data.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class PrimaryYellowButtonBuilder
    implements FormControlBuilder<FormSubmitButtonData> {
  const PrimaryYellowButtonBuilder();

  @override
  Widget buildIdle(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    return ShineButton(
      style: ShineButtonStyle.primaryYellow,
      onPressed: controller.submit,
      text: data.text,
      height: data.size?.height,
      width: data.size?.width,
    );
  }

  @override
  Widget buildDisabled(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    return _DisabledButton(size: data.size, child: Text(data.text));
  }

  @override
  Widget buildProcessing(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    return _DisabledButton(
      size: data.size,
      child: SizedBox.square(
        dimension: data.loadingIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: data.loadingIndicatorStroke,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColorStyles.contentSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildSuccess(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    return ElevatedButton(
      onPressed: SoundTap.wrap(controller.reset),
      style: ElevatedButton.styleFrom(
        fixedSize: data.size,
        backgroundColor: const Color(0xFF4CAF50),
        disabledBackgroundColor: const Color(0xFF4CAF50),
        disabledForegroundColor: Colors.white,
        elevation: 0,
      ),
      child: const Icon(Icons.check, color: Colors.white),
    );
  }

  @override
  Widget buildError(
    BuildContext context,
    FormSubmitButtonData data,
    FormControlController controller,
  ) {
    return ElevatedButton(
      onPressed: SoundTap.wrap(controller.reset),
      style: ElevatedButton.styleFrom(
        fixedSize: data.size,
        backgroundColor: const Color(0xFFF44336),
        disabledBackgroundColor: const Color(0xFFF44336),
        disabledForegroundColor: Colors.white,
        elevation: 0,
      ),
      child: const Icon(Icons.close, color: Colors.white),
    );
  }
}

class _DisabledButton extends StatelessWidget {
  const _DisabledButton({required this.child, this.size});

  final Widget child;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        fixedSize: size,
        elevation: 0,
        textStyle: AppTextStyles.buttonMedium(),
        disabledBackgroundColor: AppColors.gray600,
        disabledForegroundColor: AppColorStyles.contentTertiary,
      ),
      child: child,
    );
  }
}
