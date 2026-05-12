import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double sm = 6; // inputs
  static const double md = 12; // cards
  static const double lg = 20; // bottom sheets
  static const double xl = 28; // hero cards
  static const double full = 999; // pills, avatars

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}
