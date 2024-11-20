import 'package:abis_mobile/utils/colors.dart';
import 'package:flutter/material.dart';

class TAppBarTheme{
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    backgroundColor: MyColor.primaryColor,
    iconTheme: IconThemeData(color: MyColor.white),
    titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: MyColor.white),
  );
  static const darkAppBarTheme = AppBarTheme(
    backgroundColor: MyColor.primaryColor,
    titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: MyColor.white),
  );
}