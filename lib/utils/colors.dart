import 'package:flutter/material.dart';

class MyColor {
  static const Map<String, Color> salesOrder = {
    'Invoiced': Color(0xFF0568D2),
    'Pending': Color(0xFFFFA500),
    'Hold': Color(0xFFF16E00),
    'Dispatched': Color(0xFF14882E),
    'Cancelled': Color(0xFFDC3545), // Default for null or unknown status
  };
  static const Color primaryColor = Color(0xFF333333);
  static const Color white = Color(0xFFffffff);
  static const Color textColor = Colors.white;
  static const Color subTextColor = Colors.grey;
  static const Color grey = Colors.grey;
  static const Color black = Colors.black;
  static const Color drawerBackground = Color(0xFF363636);
  static const Color activeTileColor = Colors.white24;
  static const Color drawerHeaderColor = Colors.white24;
}
