import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart' as timeago;

import '../../features/main_screen/presentation/widgets/widgets.dart';
import '../resources/constants.dart';

class Utils {
  static double? getScreenWidth(BuildContext context, double screenWidth) {
    return screenWidth > 1137
        ? null
        : Responsive.isDesktop(context)
            ? 1137
            : 640;
  }

  static double? getScreenHeight(BuildContext context, double screenHeight) {
    return Responsive.isDesktop(context)
        ? screenHeight > 783
            ? screenHeight
            : 783
        : null;
  }

  static double getAppBarTitlePadding(BuildContext context) {
    return Responsive.isDesktop(context) ? 50 : 0.0;
  }

  static double getAppBarActionMenuPadding(
      BuildContext context, double mobilePadding) {
    return Responsive.isDesktop(context) ? 30 : mobilePadding;
  }

  static Widget getDeviceIcon(String? type) {
    switch (type) {
      case kWaterFontTypeKey:
      case kWaterLevelType:
        return Image.asset(
          'assets/icons/water_level_icon.png',
          fit: BoxFit.contain,
        );
      case kTempAndHumidityType:
        return Image.asset(
          'assets/icons/temp_hum_accent.png',
          fit: BoxFit.contain,
        );
      case kControllerType:
        return Image.asset(
          'assets/icons/controller_icon.png',
          fit: BoxFit.contain,
        );
      case kAnimalTypeKey:
      case kPaddockTypeKey:
      case kEarTagType:
        return Image.asset(
          'assets/icons/cow_accent.png',
          fit: BoxFit.contain,
        );
      case kBatchTypeKey:
        return Image.asset(
          'assets/icons/batch_accent.png',
          fit: BoxFit.contain,
        );
      default:
        return const Placeholder();
    }
  }

  static String getLongDate(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  static String getShortDate(DateTime date) {
    return DateFormat.yMd().add_jm().format(date);
  }

  static String getTimeAgoDate(int? dateInMilliseconds, {String? locale}) {
    if (dateInMilliseconds != null) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(dateInMilliseconds);
      return timeago.format(date, locale: locale);
    }
    return '';
  }
}
