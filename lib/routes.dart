import 'package:abis_mobile/screens/home/home.dart';
import 'package:abis_mobile/screens/sales-order/sales_order.dart';
import 'package:flutter/material.dart';
import 'package:abis_mobile/screens/login.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/login': (context) => const LoginPage(),
      '/home': (context) => const Home(),
      '/salesorder': (context) => const SalesOrderList(),
    };
  }
}
