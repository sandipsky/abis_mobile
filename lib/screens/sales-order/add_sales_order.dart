import 'package:abis_mobile/services/dropdown.service.dart';
import 'package:abis_mobile/widgets/dropdown.dart';
import 'package:abis_mobile/widgets/nepalidatepicker.dart';
import 'package:flutter/material.dart';

class AddSalesOrder extends StatefulWidget {
  const AddSalesOrder({super.key});

  @override
  State<AddSalesOrder> createState() => _AddSalesOrderState();
}

class _AddSalesOrderState extends State<AddSalesOrder> {
  List customerList = [];
  List headquarterList = [];
  List divisionList = [];
  List salesRepresentativeList = [];
  List<Map<String, dynamic>> productList = [
    {
      'product': null,
      'unit': 'pcs',
      'qty': 0,
      'rate': 0.0,
      'total': 0.0,
    },
  ];

  TextEditingController customerName = TextEditingController();
  TextEditingController salesRepresentativeName = TextEditingController();
  TextEditingController hqName = TextEditingController();
  TextEditingController divisionName = TextEditingController();
  TextEditingController transactionType = TextEditingController();
  TextEditingController orderDate = TextEditingController();
  int divisionId = 0;
  int hqId = 0;

  getCustomerList(String searchTerm) async {
    try {
      var response = await DropDownService().getCustomerDropdown(searchTerm);
      if (response.statusCode == 200) {
        setState(() {
          customerList = response.data;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  getSalesRepresentativeList(String searchTerm) async {
    try {
      var response = await DropDownService()
              .getSalesRepresentativeDropdown(searchTerm, hqId, divisionId) ??
          [];
      if (response.statusCode == 200) {
        setState(() {
          salesRepresentativeList = response.data;
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
  void initState() {
    super.initState();
    getHeadquarterList();
    getDivisionList();
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
        child: ListView(children: [
          MyDropdown(
            labelText: 'Customer',
            placeholder: 'Select Customer',
            items: customerList,
            onChanged: (value) {
              setState(() {
                customerName.text = value['name'];
              });
            },
            controller: customerName,
            showSearch: true,
            onSearch: (query) {
              getCustomerList(query);
            },
          ),
          const SizedBox(height: 20),
          NpDatePicker(
              onChanged: (date) => {},
              controller: orderDate,
              labelText: 'Order Date',
              placeholder: 'Tap to Select Date'),
          const SizedBox(height: 20),
          MyDropdown(
            labelText: 'Headquarter',
            placeholder: 'Select Headquarter',
            items: headquarterList,
            onChanged: (value) {
              setState(() {
                hqName.text = value['name'];
              });
            },
            controller: hqName,
          ),
          const SizedBox(height: 20),
          MyDropdown(
            labelText: 'Division',
            placeholder: 'Select Division',
            items: divisionList,
            onChanged: (value) {
              setState(() {
                divisionName.text = value['name'];
              });
            },
            controller: divisionName,
          ),
          const SizedBox(height: 20),
          MyDropdown(
            labelText: 'Sales Representative',
            placeholder: 'Select Representative',
            items: salesRepresentativeList,
            onChanged: (value) {
              setState(() {
                salesRepresentativeName.text = value['name'];
              });
            },
            controller: salesRepresentativeName,
            showSearch: true,
            onSearch: (query) {
              getSalesRepresentativeList(query);
            },
          ),
          const SizedBox(height: 20),
          MyDropdown(
            labelText: 'Transaction Type',
            placeholder: 'Select Transaction Type',
            items: const [
              {'name': 'Cash'},
              {'name': 'Credit'}
            ],
            onChanged: (value) {
              setState(() {
                transactionType.text = value['name'];
              });
            },
            controller: divisionName,
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
