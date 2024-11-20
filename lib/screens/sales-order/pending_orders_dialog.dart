import 'package:flutter/material.dart';

class PendingOrdersDialog extends StatefulWidget {
  final List<Map<String, dynamic>> pendingOrders;
  final Function(dynamic) onChanged;

  const PendingOrdersDialog({
    super.key,
    required this.pendingOrders,
    required this.onChanged,
  });

  @override
  State<PendingOrdersDialog> createState() => _PendingOrdersDialogState();
}

class _PendingOrdersDialogState extends State<PendingOrdersDialog> {
  late List<bool> _selectedOrders;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    // Initialize all checkboxes as unchecked
    _selectedOrders = List<bool>.filled(widget.pendingOrders.length, false);
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      for (int i = 0; i < _selectedOrders.length; i++) {
        _selectedOrders[i] = _selectAll;
      }
    });
  }

  void _toggleIndividual(int index, bool? value) {
    setState(() {
      _selectedOrders[index] = value ?? false;
      _selectAll = _selectedOrders.every((isChecked) => isChecked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Pending Orders", style: TextStyle(fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 8.0, // Reduce space between columns
          headingTextStyle:
              const TextStyle(fontSize: 14), // Smaller heading font
          dataTextStyle: const TextStyle(fontSize: 14), // Smaller data font
          horizontalMargin: 4.0, // Less horizontal padding
          columns: [
            DataColumn(
              label: Checkbox(
                value: _selectAll,
                onChanged: _toggleSelectAll,
              ),
            ),
            const DataColumn(label: Text('SN.')),
            const DataColumn(label: Text('Order No.')),
            const DataColumn(label: Text('Order Date')),
            const DataColumn(
                label: Text('Sales Representative',
                    style: TextStyle(fontSize: 12))),
            const DataColumn(label: Text('Product')),
            const DataColumn(label: Text('Unit')),
            const DataColumn(label: Text('Qty')),
            const DataColumn(label: Text('Rate')),
            const DataColumn(label: Text('Total')),
          ],
          rows: widget.pendingOrders
              .asMap()
              .entries
              .map(
                (entry) => DataRow(
                  cells: [
                    DataCell(
                      Checkbox(
                        value: _selectedOrders[entry.key],
                        onChanged: (value) =>
                            _toggleIndividual(entry.key, value),
                      ),
                    ),
                    DataCell(Text('${entry.key + 1}')),
                    DataCell(Text(entry.value['orderNo']!)),
                    DataCell(Text(entry.value['orderDate']!)),
                    DataCell(Text(entry.value['salesRepresentative']!)),
                    DataCell(Text(entry.value['product']!)),
                    DataCell(Text(entry.value['unit']!)),
                    DataCell(Text(entry.value['qty']!.toString())),
                    DataCell(Text(entry.value['rate']!.toString())),
                    DataCell(Text(entry.value['total']!.toString())),
                  ],
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: () {
            // Collect selected items
            List<Map<String, dynamic>> selectedOrders = [];
            for (int i = 0; i < _selectedOrders.length; i++) {
              if (_selectedOrders[i]) {
                selectedOrders.add(widget.pendingOrders[i]);
              }
            }
            Navigator.pop(context);
            widget.onChanged(selectedOrders);
          },
          child: const Text("APPLY"),
        ),
      ],
    );
  }
}
