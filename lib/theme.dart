import 'package:flutter/material.dart';

// Extension pour les espacements cohérents
extension SpacingExtension on BuildContext {
  EdgeInsets get smallPadding => const EdgeInsets.all(8);
  EdgeInsets get mediumPadding => const EdgeInsets.all(16);
  EdgeInsets get largePadding => const EdgeInsets.all(24);

  SizedBox get smallGap => const SizedBox(height: 12);
  SizedBox get mediumGap => const SizedBox(height: 24);
  SizedBox get largeGap => const SizedBox(height: 36);

  double get iconSizeSmall => 24;
  double get iconSizeMedium => 36;
  double get iconSizeLarge => 48;
}

// Extension pour les animations
extension AnimationExtension on BuildContext {
  Duration get shortAnimation => const Duration(milliseconds: 200);
  Duration get mediumAnimation => const Duration(milliseconds: 350);
  Duration get longAnimation => const Duration(milliseconds: 500);

  Curve get standardCurve => Curves.easeInOutCubic;
}
