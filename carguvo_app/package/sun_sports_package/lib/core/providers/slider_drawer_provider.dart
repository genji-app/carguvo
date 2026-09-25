import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

final GlobalKey<SliderDrawerState> sliderDrawerKey =
    GlobalKey<SliderDrawerState>();

final sliderDrawerKeyProvider = Provider<GlobalKey<SliderDrawerState>>((ref) {
  return sliderDrawerKey;
});
