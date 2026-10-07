import 'package:flutter/material.dart';
import 'form_control_controller.dart';

abstract class FormControlBuilder<T> {
  const FormControlBuilder();

  Widget buildIdle(
    BuildContext context,
    T data,
    FormControlController controller,
  );

  Widget buildDisabled(
    BuildContext context,
    T data,
    FormControlController controller,
  );

  Widget buildProcessing(
    BuildContext context,
    T data,
    FormControlController controller,
  );

  Widget buildSuccess(
    BuildContext context,
    T data,
    FormControlController controller,
  );

  Widget buildError(
    BuildContext context,
    T data,
    FormControlController controller,
  );
}
