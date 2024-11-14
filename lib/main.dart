import 'package:abis_mobile/cubit/config.cubit.dart';
import 'package:abis_mobile/cubit/counter_cubit.dart';
import 'package:abis_mobile/cubit/user.cubit.dart';
import 'package:abis_mobile/routes.dart';
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
          create: (_) => CounterCubit(),
        ),
        BlocProvider(
          create: (_) => UserCubit(),
        ),
        BlocProvider(
          create: (_) => ConfigCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
