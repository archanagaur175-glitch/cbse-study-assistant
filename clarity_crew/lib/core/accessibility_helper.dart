import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessibilityHelper {
  AccessibilityHelper._();

  static Brightness get systemBrightness =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  static double get textScaleFactor =>
      WidgetsBinding.instance.platformDispatcher.textScaleFactor;

  static bool get isReducedMotion =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
          .reduceMotion;

  static bool get isHighContrast =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
          .highContrast;

  static bool get isScreenReaderOn =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
          .screenReader;

  static void hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  static void hapticSuccess() {
    HapticFeedback.mediumImpact();
  }

  static void hapticError() {
    HapticFeedback.heavyImpact();
  }

  static double responsiveFontSize(
    BuildContext context, {
    double base = 16,
    double minScale = 0.85,
    double maxScale = 1.3,
  }) {
    final scale = textScaleFactor.clamp(minScale, maxScale);
    return base * scale;
  }

  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return const EdgeInsets.all(12);
    if (width < 600) return const EdgeInsets.all(16);
    return const EdgeInsets.all(24);
  }

  static double responsiveWidth(BuildContext context, double fraction) {
    final width = MediaQuery.of(context).size.width;
    return (width * fraction).clamp(0, 420);
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  static bool isMediumScreen(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 360 && w < 600;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }
}
