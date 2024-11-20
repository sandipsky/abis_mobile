import 'package:abis_mobile/utils/colors.dart';
import 'package:flutter/material.dart';

class TFloatingButtonTheme {
  TFloatingButtonTheme._();

  static var lightAppBarTheme = FloatingActionButtonThemeData(
    backgroundColor: MyColor.primaryColor,
    foregroundColor: MyColor.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
  );
  static var darkAppBarTheme = FloatingActionButtonThemeData(
    backgroundColor: MyColor.primaryColor,
    foregroundColor: MyColor.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
  );
}
