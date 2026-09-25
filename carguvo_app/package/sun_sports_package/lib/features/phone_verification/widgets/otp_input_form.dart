import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';
import 'package:sun_sports/shared/widgets/form_submit_button/form_submit_button_lib.dart';
import 'package:sun_sports/shared/widgets/input/input.dart';

class _OtpInputFormLogger with LoggerMixin {}

class OtpInputForm extends ConsumerStatefulWidget {
  const OtpInputForm({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.onCompleted,
    this.onSubmit,
    this.onResend,
    this.label,
    this.errorText,
  });

  final TextEditingController? controller;

  final FormFieldValidator<String>? validator;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onCompleted;

  final Future<bool> Function(String otp)? onSubmit;

  final Future<bool> Function()? onResend;

  final Widget? label;

  final String? errorText;

  @override
  ConsumerState<OtpInputForm> createState() => _OtpInputFormState();
}

class _OtpInputFormState extends ConsumerState<OtpInputForm> {
  final _logger = _OtpInputFormLogger();
  late final TextEditingController _otpController;
  late final FormControlController _submitController;
  bool _ownsController = false;

  static const _buttonSize = Size.fromHeight(44);

  @override
  void initState() {
    super.initState();
    _otpController = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
    _submitController = FormControlController(
      initialState: FormControlState.disabled,
    );
  }

  @override
  void dispose() {
    if (_ownsController) {
      _otpController.dispose();
    }
    _submitController.dispose();
    super.dispose();
  }

  void _updateSubmitButtonState(String pin) {
    if (widget.validator == null || widget.validator!(pin) == null) {
      _submitController.enable();
    } else {
      _submitController.disable();
    }
  }

  Future<bool> _handleVerify() async {
    _logger.logInfo('OTP verification started');

    if (widget.onSubmit != null) {
      final otp = _otpController.text;
      _logger.logInfo('Verifying OTP: ${otp.substring(0, 2)}****');

      final result = await widget.onSubmit!(otp);
      _logger.logInfo('OTP verification result: $result');
      return result;
    }
    return true;
  }

  Future<bool> _handleResend() async {
    _logger.logInfo('OTP resend requested');

    if (widget.onResend != null) {
      final result = await widget.onResend!();
      _logger.logInfo('OTP resend result: $result');
      return result;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: StyledPinput(
                controller: _otpController,
                length: 6,
                pinWidth: 48,
                pinHeight: 48,
                label: widget.label,
                errorText: widget.errorText,
                validator: widget.validator,
                onCompleted: (pin) {
                  _updateSubmitButtonState(pin);
                  widget.onCompleted?.call(pin);
                },
                onChanged: (pin) {
                  _updateSubmitButtonState(pin);
                  widget.onChanged?.call(pin);
                },
                showCursor: true,
              ),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: FormSubmitButton(
                controller: _submitController,
                size: _buttonSize,
                text: I18n.txtVerify,
                resetOnError: true,
                errorDuration: Duration.zero,
                resetOnSuccess: true,
                successDuration: Duration.zero,
                onSubmit: _handleVerify,
              ),
            ),
            Expanded(
              child: FormSubmitButton(
                style: FormSubmitButtonStyle.secondary,
                size: _buttonSize,
                text: I18n.txtResendCode,
                resetOnError: true,
                errorDuration: Duration.zero,
                resetOnSuccess: true,
                successDuration: Duration.zero,
                onSubmit: _handleResend,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
