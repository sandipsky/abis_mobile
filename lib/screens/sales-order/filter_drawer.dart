import 'package:abis_mobile/services/dropdown.service.dart';
import 'package:abis_mobile/widgets/dropdown.dart';
import 'package:abis_mobile/widgets/nepalidatepicker.dart';
import 'package:flutter/material.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  TextEditingController divisionName = TextEditingController();
  TextEditingController hqName = TextEditingController();
  TextEditingController salesRepresentativeName = TextEditingController();
  List salesRepresentativeList = [];
  List divisionList = [];
  List headquarterList = [];

  int hqId = 0;
  int divisionId = 0;
  int salesRepresentativeId = 0;

  getSalesRepresentativeList(String searchTerm) async {
    try {
      var response = await DropDownService()
              .getSalesRepresentativeDropdown(searchTerm, 0, 0) ??
          [];
      if (response.statusCode == 200) {
        setState(() {
          salesRepresentativeList = response.data
              .map((user) => {'name': user['name'], 'id': user['id']})
              .toList();
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('From'),
            NpDatePicker(
                onChanged: (date) => {},
                controller: fromDate,
                readonly: false,
                placeholder: 'Tap to Select Date'),
            const SizedBox(height: 16),
            const Text('To'),
            NpDatePicker(
                onChanged: (date) => {},
                controller: fromDate,
                readonly: false,
                placeholder: 'Tap to Select Date'),
            const SizedBox(height: 20),
            const Text('Headquarter'),
            TextFormField(
                controller: hqName,
                readOnly: true,
                decoration: const InputDecoration(
                  hintText: 'Select Headquarter',
                )),
            const SizedBox(height: 20),
            const Text('Division'),
            MyDropdown(
              placeholder: 'Select Division',
              selectedItem: divisionName.text.isNotEmpty
                  ? {
                      'id': divisionId,
                      'name': divisionName.text,
                      'hq_id': hqId,
                      'hq_name': hqName.text
                    }
                  : null,
              items: divisionList,
              onClear: () {},
              onChanged: (value) async {},
              controller: divisionName,
            ),
            const SizedBox(height: 20),
            const Text('Sales Representative'),
            MyDropdown(
              placeholder: 'Select Representative',
              items: salesRepresentativeList,
              selectedItem: null,
              onChanged: (value) {},
              controller: salesRepresentativeName,
              showSearch: true,
              onSearch: (query) {
                getSalesRepresentativeList(query);
              },
              onClear: () {
                setState(() {
                  salesRepresentativeId = 0;
                  salesRepresentativeName.text = '';
                });
              },
            ),
            const Spacer(),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
