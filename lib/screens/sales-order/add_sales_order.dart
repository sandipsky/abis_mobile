import 'package:abis_mobile/services/dropdown.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddSalesOrder extends StatefulWidget {
  const AddSalesOrder({super.key});

  @override
  State<AddSalesOrder> createState() => _AddSalesOrderState();
}

class _AddSalesOrderState extends State<AddSalesOrder> {
  List<Map<String, dynamic>> customerList = [];
  List<Map<String, dynamic>> headquarterList = [];
  List<Map<String, dynamic>> divisionList = [];
  List<Map<String, dynamic>> userList = [];
  final List<String> transactionTypes = [
    'Cash',
    'Credit',
  ];

  TextEditingController customer_name = TextEditingController();
  TextEditingController transaction_type = TextEditingController();
  int divisionId = 0;
  int hqId = 0;

  getCustomerList(String searchTerm) async {
    try {
      var response =
          await DropDownService().getCustomerDropdown(searchTerm) ?? [];
      if (response.statusCode == 200) {
        setState(() {
          customerList = response.data;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  getUserList(String searchTerm) async {
    try {
      var response = await DropDownService()
              .getSalesRepresentativeDropdown(searchTerm, hqId, divisionId) ??
          [];
      if (response.statusCode == 200) {
        setState(() {
          userList = response.data;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  getHeadquarterList() async {
    try {
      var response = await DropDownService().getHeadquarterDropdown() ?? [];
      if (response.statusCode == 200) {
        setState(() {
          headquarterList = response.data;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  getDivisionList() async {
    try {
      var response = await DropDownService().getDivisionDropdown() ?? [];
      if (response.statusCode == 200) {
        setState(() {
          divisionList = response.data;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Sales Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer Name'),
            // TypeAheadField(
            //   controller: customer_name,
            //   suggestionsCallback: (pattern) async {
            //     await getCustomerList(pattern);
            //     return customerList;
            //   },
            //   itemBuilder: (context, Map<String, dynamic> suggestion) {
            //     return ListTile(
            //       title: Text(suggestion['name']),
            //     );
            //   },
            //   onSelected: (Map<String, dynamic> suggestion) {
            //     setState(() {
            //       customer_name.text = suggestion['name'];
            //     });
            //   },
            // ),
            const SizedBox(height: 20),
            const Text('Transaction Type'),
            DropdownButtonFormField<String>(
              value: transaction_type.text.isNotEmpty
                  ? transaction_type.text
                  : null,
              items: transactionTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  transaction_type.text = value!;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Select Transaction Type',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
