import 'dart:async';
import 'dart:io';
import 'package:abis_mobile/screens/sales-order/pending_orders_dialog.dart';
import 'package:abis_mobile/screens/sales-order/sales_aging_dialog.dart';
import 'package:abis_mobile/screens/sales-order/sales_order.service.dart';
import 'package:abis_mobile/services/dropdown.service.dart';
import 'package:abis_mobile/services/util.service.dart';
import 'package:abis_mobile/widgets/dropdown.dart';
import 'package:abis_mobile/widgets/nepalidatepicker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_date_picker/np_date_picker.dart';

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
  List apiProductList = [];
  List pendingOrderList = [];
  List appliedOrderList = [];
  List dueInvoiceList = [];
  List _rows = [];
  List uploadedFiles = [];
  Map<String, dynamic> customerDetail = {};
  String discountCategoryName = '';
  String salesOrderNumber = '';
  num availableCredit = 0;
  num paymentTerms = 0;
  num creditLimit = 0;

  bool _isExpanded = false;

  TextEditingController customerName = TextEditingController();
  TextEditingController divisionName = TextEditingController();
  TextEditingController salesRepresentativeName = TextEditingController();
  TextEditingController hqName = TextEditingController();
  TextEditingController transactionType = TextEditingController();
  TextEditingController orderDate = TextEditingController();
  TextEditingController purchaseOrderNoController = TextEditingController();
  TextEditingController purchaseOrderDateController = TextEditingController();
  TextEditingController requestDeliveryDateController = TextEditingController();
  int customerId = 0;
  int divisionId = 0;
  int salesRepresentativeId = 0;
  int hqId = 0;
  double total = 0.0;

  void _addRow() {
    setState(() {
      _rows.add({
        'product_name': TextEditingController(),
        'product_id': '',
        'unit_id': '',
        'unit_name': '',
        'qty': TextEditingController(),
        'rate': TextEditingController(),
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

  resetForm(bool? customer) {
    setState(() {
      customerList = [];
      headquarterList = [];
      salesRepresentativeList = [];
      apiProductList = [];
      pendingOrderList = [];
      appliedOrderList = [];
      dueInvoiceList = [];
      _rows = [];
      uploadedFiles = [];
      customerDetail = {};
      discountCategoryName = '';
      availableCredit = 0;
      paymentTerms = 0;
      creditLimit = 0;
      _isExpanded = false;

      hqName.text = '';
      transactionType.text = '';
      purchaseOrderNoController.text = '';
      purchaseOrderDateController.text = '';
      requestDeliveryDateController.text = '';
      divisionName.text = '';
      salesRepresentativeName.text = '';

      divisionId = 0;
      salesRepresentativeId = 0;
      hqId = 0;
      total = 0.0;
    });

    _addRow();

    if (customer == true) {
      setState(() {
        customerName.text = '';
        customerId = 0;
        divisionList = [];
      });
    }
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
    if (hqId != 0 && divisionId != 0) {
      try {
        var response = await DropDownService()
                .getSalesRepresentativeDropdown(searchTerm, hqId, divisionId) ??
            [];
        if (response.statusCode == 200) {
          setState(() {
            salesRepresentativeList = response.data
                .map((user) => {'name': user['name'], 'id': user['id']})
                .toList();
            ;
          });
        }
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  getProductList(String searchTerm) async {
    if (divisionId != 0) {
      try {
        var response = await DropDownService().getProductsByTypeDivision(
                'sellable', searchTerm, divisionId) ??
            [];
        if (response.statusCode == 200) {
          setState(() {
            apiProductList = response.data
                .map(
                    (product) => {'name': product['name'], 'id': product['id']})
                .toList();
          });
        }
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  getProductDetail(int productId, int index) async {
    try {
      var response =
          await SalesOrderService().getProductDetail(productId) ?? [];
      if (response.statusCode == 200) {
        setState(() {
          _rows[index]['unit_id'] = response.data['unit_id'];
          _rows[index]['unit_name'] = response.data['unit_name'];
          _rows[index]['rate'].text = response.data['selling_price'].toString();
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  getCustomerDetail() async {
    try {
      var response =
          await SalesOrderService().getCustomerDetail(customerId) ?? {};
      if (response.statusCode == 200) {
        setState(() {
          customerDetail = response.data;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  getCustomerDivisions() async {
    if (customerId != 0) {
      try {
        var response =
            await DropDownService().getDivisionDropdownCustomer(customerId) ??
                [];
        if (response.statusCode == 200) {
          setState(() {
            divisionList = response.data;
          });
        }
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  getSalesOrderNo() async {
    try {
      var response = await SalesOrderService().getSalesOrderNumber() ?? {};
      if (response.statusCode == 200) {
        setState(() {
          salesOrderNumber = response.data;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  getPendingOrders() async {
    try {
      var response = await SalesOrderService()
              .getPendingSalesOrder(customerId, divisionId) ??
          [];
      if (response.statusCode == 200) {
        setState(() {
          pendingOrderList = response.data;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  getDueInvoices() async {
    try {
      var response = await SalesOrderService().getDueInvoices(customerId) ?? [];
      if (response.statusCode == 200) {
        setState(() {
          final today = DateTime.now();

          for (var invoice in response.data) {
            DateTime? relevantDate;
            if (invoice['dispatch_date'] != null &&
                invoice['dispatch_date'].isNotEmpty) {
              relevantDate = UtilService()
                  .convertNepaliDateToEnglish(invoice['dispatch_date']);
            } else if (invoice['invoice_date'] != null &&
                invoice['invoice_date'].isNotEmpty) {
              relevantDate = UtilService()
                  .convertNepaliDateToEnglish(invoice['invoice_date']);
            }

            if (relevantDate != null) {
              invoice['due_days'] = today.difference(relevantDate).inDays;
            } else {
              invoice['due_days'] = 0;
            }
          }

          dueInvoiceList = response.data.where((invoice) {
            int dueDays = invoice['due_days'] ?? 0;
            return dueDays > paymentTerms;
          }).toList();
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getSalesOrderNo();
    _addRow();
    setState(() {
      orderDate.text = NepaliDateTime.now().toString().split(' ')[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            const Text(
              'View Sales Order',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              salesOrderNumber,
              style: const TextStyle(
                  fontSize: 16), // Optional: smaller font for the number
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          const Text('Customer'),
          MyDropdown(
              placeholder: 'Select Customer',
              selectedItem: customerName.text.isNotEmpty
                  ? {
                      'id': customerId,
                      'name': customerName.text,
                    }
                  : null,
              items: customerList,
              onChanged: (value) {
                setState(() {
                  customerName.text = value['name'];
                  customerId = value['id'];
                  getCustomerDetail();
                  getCustomerDivisions();
                });
              },
              controller: customerName,
              showSearch: true,
              onSearch: (query) {
                getCustomerList(query);
              },
              onClear: () {
                resetForm(true);
              }),
          const SizedBox(height: 20),
          const Text('Order Date'),
          NpDatePicker(
              onChanged: (date) => {},
              controller: orderDate,
              readonly: true,
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
            onClear: () {
              resetForm(false);
            },
            onChanged: (value) async {
              final selectedDivisionDetails =
                  customerDetail['discount_details']?.firstWhere(
                (item) => item['division_id'] == value['id'],
                orElse: () => null,
              );
              setState(() {
                divisionName.text = value['name'];
                divisionId = value['id'];
                hqId = value['hq_id'];
                hqName.text = value['hq_name'];
                paymentTerms = selectedDivisionDetails?['credit_days'] ?? 0;
                availableCredit =
                    selectedDivisionDetails?['available_credit'] ?? 0;
                discountCategoryName =
                    selectedDivisionDetails?['discount_category']?['name'] ??
                        '';
                creditLimit = selectedDivisionDetails?['credit_limit'] ?? 0;
                salesRepresentativeName.text = '';
                salesRepresentativeId = 0;
                salesRepresentativeList = [];
              });
              await getPendingOrders();
              await getDueInvoices();

              var count = dueInvoiceList
                  .where((invoice) {
                    if (invoice['division_id'] != divisionId) {
                      return false;
                    }
                    return true;
                  })
                  .toList()
                  .length;
              if (count > 0) {
                showDialog(
                  context: context,
                  builder: (_) => SalesAgingDialog(
                    invoiceList: dueInvoiceList,
                    divisionId: divisionId,
                    creditDays: paymentTerms,
                    onClose: (data) {
                      if (data == false) {
                        resetForm(false);
                      }
                    },
                  ),
                  barrierDismissible: false,
                );
              }
            },
            controller: divisionName,
          ),
          const SizedBox(height: 20),
          const Text('Sales Representative'),
          MyDropdown(
            placeholder: 'Select Representative',
            items: salesRepresentativeList,
            selectedItem: salesRepresentativeName.text.isNotEmpty
                ? {
                    'id': salesRepresentativeId,
                    'name': salesRepresentativeName.text,
                  }
                : null,
            onChanged: (value) {
              setState(() {
                salesRepresentativeName.text = value['name'];
                salesRepresentativeId = value['id'];
              });
            },
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
            controller: transactionType,
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
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text("Customer Details"),
            initiallyExpanded: false,
            children: [
              ListTile(
                title: const Text("Reg No:"),
                subtitle: Text(customerDetail['registration_no'] ?? "-"),
              ),
              ListTile(
                title: const Text("Address:"),
                subtitle: Text(customerDetail['address'] ?? "-"),
              ),
              ListTile(
                title: const Text("Contact:"),
                subtitle: Text(customerDetail['contact_no'] ?? "-"),
              ),
              ListTile(
                title: const Text("Discount Category:"),
                subtitle: Text(discountCategoryName.isNotEmpty
                    ? discountCategoryName
                    : "-"),
              ),
              ListTile(
                title: const Text("Credit Limit:"),
                subtitle: Text(creditLimit.toStringAsFixed(2)),
              ),
              ListTile(
                title: const Text("Available Credit:"),
                subtitle: Text(availableCredit.toStringAsFixed(2)),
              ),
              ListTile(
                title: const Text("Payment Terms:"),
                subtitle: Text("$paymentTerms Days"),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                    key: ValueKey(row), // Add a unique key for each row
                    cells: [
                      DataCell(
                        MyDropdown(
                          placeholder: 'Select Product',
                          items: apiProductList,
                          controller: row['product_name'],
                          selectedItem: row['product_name'].text.isNotEmpty
                              ? {
                                  'id': row['product_id'],
                                  'name': row['product_name'].text
                                }
                              : null,
                          onChanged: (value) {
                            getProductDetail(value['id'], index);
                            setState(() {
                              row['product_name'].text = value['name'];
                              row['product_id'] = value['id'];
                              row['product'] = value;
                            });
                          },
                          showSearch: true,
                          onSearch: (query) {
                            getProductList(query);
                          },
                        ),
                      ),
                      DataCell(Text(row['unit_name'])),
                      DataCell(TextField(
                        decoration: const InputDecoration(hintText: 'Qty.'),
                        keyboardType: TextInputType.number,
                        controller: row['qty'],
                        onChanged: (value) {
                          setState(() {
                            row['qty'].text = value;
                            row['amount'] =
                                (double.tryParse(row['qty'].text) ?? 0) *
                                    (double.tryParse(row['rate'].text) ?? 0);
                            _calculateTotal();
                          });
                        },
                      )),
                      DataCell(TextField(
                        decoration: const InputDecoration(hintText: 'Rate'),
                        keyboardType: TextInputType.number,
                        controller: row['rate'],
                        onChanged: (value) {
                          setState(() {
                            row['rate'].text = value;
                            row['amount'] =
                                (double.tryParse(row['qty'].text) ?? 0) *
                                    (double.tryParse(row['rate'].text) ?? 0);
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
              )),
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
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => PendingOrdersDialog(
                  pendingOrders: pendingOrderList,
                  onChanged: (data) {
                    setState(() {});
                  },
                ),
              );
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
