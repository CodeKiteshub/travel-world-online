import 'package:flutter/material.dart';

// Playfair Display: display styles ONLY (18px minimum — strict rule from design system v1.1)
// DM Sans: all UI text (buttons, body, labels, captions)
abstract final class AppTypography {
  // — Display (Playfair Display only) —

  static const TextStyle displayXl = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.2,
  );

  static const TextStyle displayLg = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.25,
  );

  // Minimum allowed Playfair Display size. Never define a Playfair style below 18px.
  static const TextStyle displayMd = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 1.3,
  );

  // — UI (DM Sans only) —

  static const TextStyle heading = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.4,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: 'DMSans',
    fontWeight: FontWeight.w600,
    fontSize: 10,
    height: 1.4,
    letterSpacing: 1.2,
  );
}
