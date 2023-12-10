// Flutter imports:
import 'package:flutter/material.dart';
import 'package:podnotes/constants/app.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  final Widget largeDesktop;

  const Responsive({
    Key? key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.largeDesktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      screenWidth(context) < desktopWidthThreshold;

  //static bool isTablet(BuildContext context) =>
  //    screenWidth(context) < 1100 && screenWidth(context) >= 650;

  static bool isDesktop(BuildContext context) =>
      screenWidth(context) >= desktopWidthThreshold;

  static bool isLargeDesktop(BuildContext context) =>
      screenWidth(context) >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        return constraints.maxWidth >= desktopWidthThreshold ? desktop : mobile;
      },
    );
  }
}
