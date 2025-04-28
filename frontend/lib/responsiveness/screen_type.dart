import 'package:flutter/material.dart';

enum ScreenTypes { mobile, tablet, desktop }

class Screens {
  static ScreenTypes getType(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    if (width < 600) {
      return ScreenTypes.mobile;
    } else if (width < 900) {
      return ScreenTypes.tablet;
    } else {
      return ScreenTypes.desktop;
    }
  }
}