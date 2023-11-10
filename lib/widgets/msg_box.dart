import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Color getContentColour(String contentType) {
  if (contentType == 'failure') {
    /// failure will show `CROSS`
    return const Color(0xffc72c41);
  } else if (contentType == 'success') {
    /// success will show `CHECK`
    return const Color(0xff2D6A4F);
  } else if (contentType == 'warning') {
    /// warning will show `EXCLAMATION`
    return const Color(0xffFCA652);
  } else if (contentType == 'help') {
    /// help will show `QUESTION MARK`
    return const Color(0xff3282B8);
  } else {
    return const Color.fromARGB(255, 252, 144, 82);
  }
}

String assetSVG(String contentType) {
  if (contentType == 'failure') {
    /// failure will show `CROSS`
    return AssetsPath.failure;
  } else if (contentType == 'success') {
    /// success will show `CHECK`
    return AssetsPath.success;
  } else if (contentType == 'warning') {
    /// warning will show `EXCLAMATION`
    return AssetsPath.warning;
  } else if (contentType == 'help') {
    /// help will show `QUESTION MARK`
    return AssetsPath.help;
  } else {
    return AssetsPath.failure;
  }
}

class AssetsPath {
  static const String help = 'assets/types/help.svg';
  static const String failure = 'assets/types/failure.svg';
  static const String success = 'assets/types/success.svg';
  static const String warning = 'assets/types/warning.svg';
  static const String back = 'assets/types/back.svg';
  static const String bubbles = 'assets/types/bubbles.svg';
}

class Languages {
  static const List<String> codes = [
    'ar',
    'ar',
    'ar',
    'ar',
    'ar',
    'ar',
    'ar',
    'he',
    'fa',
    'ar',
    'ku',
    'pa',
    'sd',
    'ur',
    'he',
  ];
}

double getWidgetHeight(String content) {
  if (content.length < 200) {
    return 0.125;
  } else if (content.length < 400) {
    return 0.190;
  } else if (content.length < 600) {
    return 0.250;
  } else {
    return 0.300;
  }
}

Container buildMsgBox(
    BuildContext context, String msgType, String title, String msg) {
  /// if you want to use this in materialBanner
  bool isRTL = false;

  final size = MediaQuery.of(context).size;

  final loc = Localizations.maybeLocaleOf(context);
  final localeLanguageCode = loc?.languageCode;

  if (localeLanguageCode != null) {
    for (var code in Languages.codes) {
      if (localeLanguageCode.toLowerCase() == code.toLowerCase()) {
        isRTL = true;
      }
    }
  }
  // screen dimensions
  bool isMobile = size.width <= 730;
  bool isTablet = size.width > 730 && size.width <= 1050;
  //bool isDesktop = size.width >= 1050;

  /// for reflecting different color shades in the SnackBar
  final hsl = HSLColor.fromColor(getContentColour(msgType));
  final hslDark = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0));

  double horizontalPadding = 0.0;
  double leftSpace = size.width * 0.12;
  double rightSpace = size.width * 0.12;

  if (isMobile) {
    horizontalPadding = size.width * 0.01;
  } else if (isTablet) {
    leftSpace = size.width * 0.05;
    horizontalPadding = size.width * 0.03;
  } else {
    leftSpace = size.width * 0.05;
    horizontalPadding = size.width * 0.04;
  }

  return Container(
    margin: EdgeInsets.symmetric(
      horizontal: horizontalPadding,
    ),
    height: !isMobile
        ? !isTablet
            ? size.height * (1500.0 / size.width) * getWidgetHeight(msg)
            : size.height * (1000.0 / size.width) * getWidgetHeight(msg)
        : size.height * (650.0 / size.width) * getWidgetHeight(msg),
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // background container
        Container(
          width: size.width,
          decoration: BoxDecoration(
            color: getContentColour(msgType),
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        /// SVGs in body
        Positioned(
          bottom: 0,
          left: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
            ),
            child: SvgPicture.asset(
              AssetsPath.bubbles,
              height: size.height * 0.06,
              width: size.width * 0.05,
              colorFilter: ColorFilter.mode(hslDark.toColor(), BlendMode.srcIn),
            ),
          ),
        ),

        Positioned(
          top: -size.height * 0.02,
          left: !isRTL
              ? leftSpace - (isMobile ? size.width * 0.075 : size.width * 0.035)
              : null,
          right: isRTL
              ? rightSpace -
                  (isMobile ? size.width * 0.075 : size.width * 0.035)
              : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                AssetsPath.back,
                height: size.height * 0.06,
                colorFilter:
                    ColorFilter.mode(hslDark.toColor(), BlendMode.srcIn),
              ),
              Positioned(
                top: size.height * 0.015,
                child: SvgPicture.asset(
                  assetSVG(msgType),
                  height: size.height * 0.022,
                ),
              )
            ],
          ),
        ),

        /// content
        Positioned.fill(
          left: isRTL ? size.width * 0.03 : leftSpace,
          right: isRTL ? rightSpace : size.width * 0.03,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// `title` parameter
                  Expanded(
                    flex: 3,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: !isMobile
                            ? size.height * 0.03
                            : size.height * 0.025,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.005,
              ),

              /// `message` body text parameter
              Expanded(
                child: Text(
                  msg,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: size.height * 0.022,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
            ],
          ),
        )
      ],
    ),
  );
}
