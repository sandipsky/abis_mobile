import 'package:abis_mobile/auth/auth.service.dart';
import 'package:abis_mobile/cubit/user.cubit.dart';
import 'package:flutter/material.dart';
import 'package:abis_mobile/utils/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final AuthService authService = AuthService();
    final username = context.read<UserCubit>().state!['name'];

    return Drawer(
      backgroundColor: MyColor.drawerBackground,
      width: 200,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color:
                MyColor.drawerBackground, // Set your desired background color
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome,',
                  style: TextStyle(
                      color: MyColor.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '$username',
                  style: const TextStyle(
                      color: MyColor.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: MyColor.textColor),
            tileColor: currentRoute == '/home'
                ? MyColor.activeTileColor
                : Colors.transparent,
            title: const Text(
              'Home',
              style: TextStyle(
                color: MyColor.textColor,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: MyColor.textColor),
            tileColor: currentRoute == '/salesorder'
                ? MyColor.activeTileColor
                : Colors.transparent,
            title: const Text(
              'Sales Order',
              style: TextStyle(
                color: MyColor.textColor,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/salesorder');
            },
          ),
          const Divider(
            color: MyColor.textColor,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: MyColor.textColor),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: MyColor.textColor,
              ),
            ),
            onTap: () {
              authService.logout(context);
            },
          ),
        ],
      ),
    );
  }
}
