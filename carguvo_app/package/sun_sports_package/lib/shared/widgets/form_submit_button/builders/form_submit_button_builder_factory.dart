import 'package:sun_sports/shared/widgets/form_control/form_control.dart';
import '../form_submit_button_data.dart';
import '../form_submit_button_style.dart';
import 'primary_yellow_button_builder.dart';
import 'secondary_button_builder.dart';

class FormSubmitButtonBuilderFactory {
  static final Map<
    FormSubmitButtonStyle,
    FormControlBuilder<FormSubmitButtonData>
  >
  _builders = {
    FormSubmitButtonStyle.primaryYellow: const PrimaryYellowButtonBuilder(),
    FormSubmitButtonStyle.secondary: const SecondaryButtonBuilder(),
  };

  static FormControlBuilder<FormSubmitButtonData> getBuilder(
    FormSubmitButtonStyle style,
  ) {
    return _builders[style]!;
  }
}
