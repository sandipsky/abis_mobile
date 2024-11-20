import 'package:abis_mobile/utils/colors.dart';
import 'package:abis_mobile/utils/themes/appbar_theme.dart';
import 'package:abis_mobile/utils/themes/elevated_button_theme.dart';
import 'package:abis_mobile/utils/themes/floating_button_theme.dart';
import 'package:abis_mobile/utils/themes/outlined_button_theme.dart';
import 'package:abis_mobile/utils/themes/text_field_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      disabledColor: MyColor.grey,
      brightness: Brightness.light,
      primaryColor: MyColor.primaryColor,
      scaffoldBackgroundColor: MyColor.white,
      elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
      outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
      inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
      appBarTheme: TAppBarTheme.lightAppBarTheme,
      floatingActionButtonTheme: TFloatingButtonTheme.lightAppBarTheme);

  static ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      disabledColor: MyColor.grey,
      brightness: Brightness.dark,
      primaryColor: MyColor.primaryColor,
      scaffoldBackgroundColor: MyColor.black,
      elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
      outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
      inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
      appBarTheme: TAppBarTheme.darkAppBarTheme,
      floatingActionButtonTheme: TFloatingButtonTheme.darkAppBarTheme);
}
