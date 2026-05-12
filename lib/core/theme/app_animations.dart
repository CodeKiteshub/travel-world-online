import 'package:flutter/animation.dart';

abstract final class AppAnimations {
  static const Duration instant = Duration(milliseconds: 100); // hovers
  static const Duration fast = Duration(milliseconds: 200); // button presses
  static const Duration normal = Duration(milliseconds: 300); // card transitions
  static const Duration slow = Duration(milliseconds: 500); // page transitions

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve pageCurve = Cubic(0.4, 0.0, 0.2, 1.0);
}
