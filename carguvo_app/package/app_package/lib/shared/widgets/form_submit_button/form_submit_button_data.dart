import 'package:flutter/material.dart';

class FormSubmitButtonData {
  const FormSubmitButtonData({
    required this.text,
    this.loadingIndicatorSize = 18.0,
    this.loadingIndicatorStroke = 2.0,
    this.size,
  });

  final String text;

  final double loadingIndicatorSize;

  final double loadingIndicatorStroke;

  final Size? size;
}
