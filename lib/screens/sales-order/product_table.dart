import 'package:abis_mobile/widgets/dropdown.dart';
import 'package:flutter/material.dart';

class ProductTable extends StatefulWidget {
  final List<Map<String, dynamic>> productList;

  const ProductTable({required this.productList, super.key});

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  List products = [];

  void _updateTotal(int index) {
    setState(() {
      widget.productList[index]['total'] =
          widget.productList[index]['qty'] * widget.productList[index]['rate'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Row
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 2,
                  child: Text('Product',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  child: Text('Unit',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  child: Text('Qty',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  child: Text('Rate',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  child: Text('Total',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const Divider(),

        // Data Rows
        ...widget.productList.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> row = entry.value;

          return Row(
            children: [
              // Product Dropdown
              Expanded(
                  flex: 2,
                  child: MyDropdown(
                      items: items,
                      onChanged: onChanged,
                      controller: controller,
                      labelText: labelText,
                      placeholder: placeholder)),
              // Unit Text
              Expanded(
                child: Text(row['unit']),
              ),
              // Qty TextField
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Qty',
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.productList[index]['qty'] =
                          double.tryParse(value) ?? 0;
                      _updateTotal(index);
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              // Rate TextField
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Rate',
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.productList[index]['rate'] =
                          double.tryParse(value) ?? 0.0;
                      _updateTotal(index);
                    });
                  },
                ),
              ),
              // Total Display
              Expanded(
                child: Text('${row['total'].toStringAsFixed(2)}'),
              ),
            ],
          );
        }),
      ],
    );
  }
}
