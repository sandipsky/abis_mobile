import 'package:abis_mobile/widgets/drawer.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ABIS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const MyDrawer(),
      body: const Column(
        children: [Text('Welcome')],
      ),
    );
  }
}
