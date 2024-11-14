import 'dart:convert';
import 'package:abis_mobile/auth/auth.service.dart';
import 'package:abis_mobile/cubit/config.cubit.dart';
import 'package:abis_mobile/cubit/user.cubit.dart';
import 'package:abis_mobile/services/config.service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abis_mobile/utils/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final ConfigService _configService = ConfigService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final Map<String, dynamic> data = {
      'username': username.text,
      'password': password.text,
    };
    setState(() {
      _isLoading = true;
    });

    try {
      var response = await _authService.login(data);
      if (response.statusCode == 200) {
        if (mounted) {
          final userCubit = context.read<UserCubit>();
          await _authService.setUserInfo(response, userCubit);
          await _getConfigs();
          if (mounted) Navigator.pushReplacementNamed(context, '/home');
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        String message = json.decode(response.body)['message'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please Check your connection'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  _getConfigs() async {
    try {
      var response = await _configService.getConfig();
      if (response.statusCode == 200) {
        if (mounted) {
          final configCubit = context.read<ConfigCubit>();
          _configService.setConfig(response.data, configCubit);
        }
      } else {
        String message = json.decode(response.body)['message'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please Check your connection'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey, // Attach the form key here
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Log in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    prefixIconConstraints:
                        BoxConstraints(maxHeight: 30, maxWidth: 30),
                    // prefixIcon: Padding(
                    //   padding: const EdgeInsets.only(right: 8.0),
                    //   child: SvgPicture.asset(
                    //     'assets/user.svg',
                    //     width: 30,
                    //     height: 30,
                    //   ),
                    // ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIconConstraints:
                        const BoxConstraints(maxHeight: 30, maxWidth: 30),
                    // prefixIcon: Padding(
                    //   padding: const EdgeInsets.only(right: 8.0),
                    //   child: SvgPicture.asset(
                    //     'assets/lock.svg',
                    //     width: 30,
                    //     height: 30,
                    //   ),
                    // ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: MyColor.subTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _isLoading ? null : _login();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: MyColor.textColor,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
