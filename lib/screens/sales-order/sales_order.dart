import 'package:abis_mobile/cubit/user.cubit.dart';
import 'package:abis_mobile/screens/sales-order/add_sales_order.dart';
import 'package:abis_mobile/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesOrderList extends StatefulWidget {
  const SalesOrderList({super.key});

  @override
  State<SalesOrderList> createState() => _SalesOrderListState();
}

class _SalesOrderListState extends State<SalesOrderList> {
  @override
  Widget build(BuildContext context) {
    final userInfo = context.watch<UserCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const MyDrawer(),
      body: Column(children: [
        Text('$userInfo'),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSalesOrder()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
