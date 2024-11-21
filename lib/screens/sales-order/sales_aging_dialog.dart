import 'package:flutter/material.dart';

class SalesAgingDialog extends StatefulWidget {
  final List invoiceList;
  final Function(bool) onClose;
  final int divisionId;
  final num creditDays;

  const SalesAgingDialog(
      {super.key,
      required this.invoiceList,
      required this.onClose,
      required this.divisionId,
      required this.creditDays});

  @override
  State<SalesAgingDialog> createState() => _SalesAgingDialogState();
}

class _SalesAgingDialogState extends State<SalesAgingDialog> {
  bool showAllDivisions = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final filteredInvoices = widget.invoiceList.where((invoice) {
      if (!showAllDivisions && invoice['division_id'] != widget.divisionId) {
        return false;
      }
      return invoice['due_days'] > widget.creditDays;
    }).toList();

    return AlertDialog(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Alert", style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "The due date for following invoice has passed credit days. Are you sure you want to proceed?",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12.0,
              headingRowHeight: 40.0,
              headingTextStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              dataTextStyle: const TextStyle(fontSize: 12),
              columns: const [
                DataColumn(label: Text('SN.')),
                DataColumn(label: Text('Invoice Date')),
                DataColumn(label: Text('Invoice No.')),
                DataColumn(label: Text('Division')),
                DataColumn(label: Text('Invoice Amount')),
                DataColumn(label: Text('Dispatch Date')),
                DataColumn(label: Text('Due Amount')),
                DataColumn(label: Text('Due Days')),
              ],
              rows: filteredInvoices
                  .asMap()
                  .entries
                  .map(
                    (entry) => DataRow(
                      cells: [
                        DataCell(Text('${entry.key + 1}')),
                        DataCell(Text(entry.value['invoice_date'] ?? '')),
                        DataCell(Text(entry.value['invoice_number'] ?? '')),
                        DataCell(Text(entry.value['division_name'] ?? '')),
                        DataCell(Text(
                            entry.value['total_invoice_amount'].toString())),
                        DataCell(Text(entry.value['dispatch_date'] ?? '-')),
                        DataCell(Text(entry.value['due_amount'].toString())),
                        DataCell(Text(entry.value['due_days'].toString())),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: showAllDivisions,
                onChanged: (value) {
                  setState(() {
                    showAllDivisions = value!;
                  });
                },
              ),
              const Text("Show All Division"),
            ],
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onClose(false);
          },
          child: const Text("NO"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onClose(true);
          },
          child: const Text("YES"),
        ),
      ],
    );
  }
}
