import 'package:flutter/foundation.dart';
import 'form_control_state.dart';

class FormControlController extends ChangeNotifier {
  FormControlController({FormControlState initialState = FormControlState.idle})
    : _state = initialState;

  FormControlState _state;
  VoidCallback? _submitCallback;

  FormControlState get state => _state;

  bool get isIdle => _state == FormControlState.idle;

  bool get isDisabled => _state == FormControlState.disabled;

  bool get isProcessing => _state == FormControlState.processing;

  void setState(FormControlState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void disable() {
    setState(FormControlState.disabled);
  }

  void enable() {
    setState(FormControlState.idle);
  }

  void reset() {
    enable();
  }

  void submit() {
    if (_state == FormControlState.idle && _submitCallback != null) {
      _submitCallback!();
    }
  }

  void registerSubmitCallback(VoidCallback callback) {
    _submitCallback = callback;
  }

  void unregisterSubmitCallback() {
    _submitCallback = null;
  }
}
