import 'package:abis_mobile/cubit/config.cubit.dart';
import 'package:abis_mobile/cubit/user.cubit.dart';
import 'package:abis_mobile/routes.dart';
import 'package:abis_mobile/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserCubit(),
        ),
        BlocProvider(
          create: (_) => ConfigCubit(),
        ),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.light,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
