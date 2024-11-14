import 'dart:convert';
import 'package:abis_mobile/cubit/user.cubit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final baseUrl = 'http://182.93.83.242:9001';

  Future<dynamic> login(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return response;
  }

  Future<void> setUserInfo(response, UserCubit userCubit) async {
    String token = json.decode(response.body)['authorization']['token'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    var userInfo = {
      "username": json.decode(response.body)['user']['username'],
      "id": json.decode(response.body)['user_information']['id'],
      "name": json.decode(response.body)['user_information']['name'],
    };
    await prefs.setString('userInfo', jsonEncode(userInfo));
    userCubit.updateUserInfo(userInfo);
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userInfo');
    if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoString = prefs.getString('userInfo');
    if (userInfoString != null) {
      return jsonDecode(userInfoString);
    }
    return null;
  }
}
