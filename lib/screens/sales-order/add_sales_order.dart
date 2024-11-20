import 'dart:io';
import 'package:abis_mobile/services/dropdown.service.dart';
import 'package:abis_mobile/widgets/dropdown.dart';
import 'package:abis_mobile/widgets/nepalidatepicker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final List<Map<String, dynamic>> _rows = [];
  final List uploadedFiles = [];

  bool _isExpanded = false;

  TextEditingController customerName = TextEditingController();
  TextEditingController salesRepresentativeName = TextEditingController();
  TextEditingController hqName = TextEditingController();
  TextEditingController divisionName = TextEditingController();
  TextEditingController transactionType = TextEditingController();
  TextEditingController orderDate = TextEditingController();
  final TextEditingController purchaseOrderNoController =
      TextEditingController();
  final TextEditingController purchaseOrderDateController =
      TextEditingController();
  final TextEditingController requestDeliveryDateController =
      TextEditingController();
  int divisionId = 0;
  int hqId = 0;
  double total = 0.0;

  void _addRow() {
    setState(() {
      _rows.add({
        'product': '',
        'unit': '-',
        'qty': 0,
        'rate': 0.0,
        'amount': 0.0,
      });
    });
  }

  void _calculateTotal() {
    total = _rows.fold(
      0.0,
      (sum, row) => sum + (row['amount'] ?? 0.0),
    );
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        uploadedFiles.add(image);
      });
    }
  }

  void _deleteFile(int index) {
    setState(() {
      uploadedFiles.removeAt(index);
    });
  }

  void _viewFile(XFile file) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(file.path)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(XFile file) async {
    try {
      final Directory downloadsDir = Directory('/storage/emulated/0/Download');
      if (!downloadsDir.existsSync()) {
        throw Exception("Downloads directory not available.");
      }
      final String savePath = '${downloadsDir.path}/${file.name}';
      final File newFile = File(savePath);
      await newFile.writeAsBytes(await file.readAsBytes());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved to: $savePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save file: $e')),
        );
      }
    }
  }

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
    _addRow();
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
          const Text('Customer'),
          MyDropdown(
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
          const Text('Order Date'),
          NpDatePicker(
              onChanged: (date) => {},
              controller: orderDate,
              placeholder: 'Tap to Select Date'),
          const SizedBox(height: 20),
          const Text('Headquarter'),
          MyDropdown(
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
          const Text('Division'),
          MyDropdown(
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
          const Text('Sales Representative'),
          MyDropdown(
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
          const Text('Transaction Type'),
          MyDropdown(
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
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(_isExpanded ? 'See Less' : 'See More'),
            ),
          ),
          const SizedBox(height: 20),
          // Conditionally show the form fields
          if (_isExpanded) ...[
            const Text('Purchase Order No.'),
            TextFormField(
                controller: purchaseOrderNoController,
                decoration: const InputDecoration(
                  hintText: 'Enter Purchase Order No.',
                )),
            const SizedBox(height: 20),
            const Text('Purchase Order Date'),
            NpDatePicker(
                onChanged: (date) => {},
                controller: purchaseOrderDateController,
                placeholder: 'Purchase Order Date'),
            const SizedBox(height: 20),
            const Text('Request Delivery Date'),
            NpDatePicker(
                onChanged: (date) => {},
                controller: requestDeliveryDateController,
                placeholder: 'Request Delivery Date'),
          ],
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Unit')),
                DataColumn(label: Text('Qty.')),
                DataColumn(label: Text('Rate')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Action')),
              ],
              rows: _rows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                return DataRow(
                  cells: [
                    DataCell(
                      MyDropdown(
                        placeholder: 'Select Product',
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
                    ),
                    DataCell(Text(row['unit'])),
                    DataCell(TextField(
                      decoration: const InputDecoration(hintText: 'Qty.'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          row['qty'] = int.tryParse(value) ?? 0;
                          row['amount'] = row['qty'] * (row['rate'] ?? 0.0);
                          _calculateTotal();
                        });
                      },
                    )),
                    DataCell(TextField(
                      decoration: const InputDecoration(hintText: 'Rate'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          row['rate'] = double.tryParse(value) ?? 0.0;
                          row['amount'] = (row['qty'] ?? 0) * row['rate'];
                          _calculateTotal();
                        });
                      },
                    )),
                    DataCell(Text(row['amount'].toStringAsFixed(2))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _rows.removeAt(index);
                            _calculateTotal();
                          });
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add),
            label: const Text('ADD ROW'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18)),
              Text(total.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 20),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Enter remarks here...',
              border: OutlineInputBorder(),
            ),
          ),
          // #ATTACHMENT SECTION
          const SizedBox(height: 20),
          const Text('Attachments'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.add),
            label: const Text('Add Attachment'),
          ),
          const SizedBox(height: 16),

          // Uploaded files list
          if (uploadedFiles.isNotEmpty)
            ...uploadedFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final XFile fileName = entry.value;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 20),
                      const SizedBox(width: 8),
                      Text(fileName.name, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          _viewFile(fileName);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          _downloadFile(fileName);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteFile(index);
                        },
                      ),
                    ],
                  ),
                ],
              );
            }),
          if (uploadedFiles.isNotEmpty) const SizedBox(height: 16),

          // Show Pending Orders link
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Show Pending Orders clicked"),
              ));
            },
            child: const Text(
              "Show Pending Orders",
            ),
          ),
          const SizedBox(height: 16),

          // Save and Cancel buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Save clicked"),
                  ));
                },
                icon: const Icon(Icons.save),
                label: const Text("SAVE"),
              ),
              const SizedBox(
                width: 20,
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("CANCEL"),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
