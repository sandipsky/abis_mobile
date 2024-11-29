import 'package:abis_mobile/screens/sales-order/add_sales_order.dart';
import 'package:abis_mobile/screens/sales-order/filter_drawer.dart';
import 'package:abis_mobile/screens/sales-order/sales_order.service.dart';
import 'package:abis_mobile/utils/colors.dart';
// import 'package:abis_mobile/services/dropdown.service.dart';
import 'package:abis_mobile/widgets/drawer.dart';
import 'package:flutter/material.dart';

class SalesOrderList extends StatefulWidget {
  const SalesOrderList({super.key});

  @override
  State<SalesOrderList> createState() => _SalesOrderListState();
}

class _SalesOrderListState extends State<SalesOrderList> {
  String dateType = 'BS';
  String fromDate = '2081-08-01';
  String toDate = '2081-08-07';
  List hqIds = [1];
  List divisionIds = [1];

  int pageIndex = 0;
  int pageSize = 25;
  bool isLoading = false;
  bool isFirstLoading = false;

  List salesOrderList = [];

  final ScrollController _scrollController = ScrollController();

  getSalesOrderList() async {
    setState(() {
      if (pageIndex == 0) {
        isFirstLoading = true;
      }
      isLoading = true;
    });
    var filter = {
      'filter': [
        {
          'field': dateType == "BS" ? 'fromNepaliDate' : 'fromEnglishDate',
          'value': fromDate,
        },
        {
          'field': dateType == "BS" ? 'toNepaliDate' : 'toEnglishDate',
          'value': toDate,
        },
        {'field': 'hq_id', 'value': '', 'operator': 'in'},
        {'field': 'division_id', 'value': '', 'operator': 'in'},
        {
          'field': 'user_id',
          'value': '',
        },
      ],
      'pagination': {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      },
      'sortDTO': [
        {
          'field': 'systemOrderNo',
          'orderType': 'desc',
        },
      ],
    };

    try {
      var response = await SalesOrderService().getSalesOrderList(filter) ?? [];
      if (response.statusCode == 200) {
        setState(() {
          if (pageIndex == 0) {
            salesOrderList = response.data['content'];
            // last = response.data['last'];
            setState(() {
              isLoading = false;
              isFirstLoading = false;
            });
          } else {
            salesOrderList = [...salesOrderList, ...response.data['content']];
            setState(() {
              isLoading = false;
              isFirstLoading = false;
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isFirstLoading = false;
      });
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getSalesOrderList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          pageIndex++;
        });
        getSalesOrderList();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [Text('')],
      ),
      drawer: const MyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search Box
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0), // Space between SearchBox and Icon
                // Filter Icon
                Builder(builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.tune),
                    color: Colors.black,
                  );
                }),
              ],
            ),
          ),
          // Filters Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Filter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 8.0,
              children: [],
            ),
          ),
          // Record Count
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '13 Appointments record(s)',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: isFirstLoading == true
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : salesOrderList.isEmpty
                    ? const Center(
                        child: Text('No sales orders found.'),
                      )
                    : ListView.builder(
                        itemCount: salesOrderList.length + (isLoading ? 1 : 0),
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          if (index == salesOrderList.length) {
                            // Show loading indicator at the bottom
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          var salesOrder = salesOrderList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        salesOrder['status'] ?? 'No Status',
                                        style: TextStyle(
                                            color: MyColor.salesOrder[
                                                salesOrder['status']
                                                    .toString()]),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 300,
                                        child: Text(
                                          salesOrder['customer_name'] ??
                                              'No Name',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                16, // Restrict to a single line
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          "Order Date: ${salesOrder['order_date'] ?? '-'}"),
                                      const SizedBox(height: 4),
                                      Text(
                                          "Order No: ${salesOrder['system_order_no'] ?? '-'}"),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Total: ${salesOrder['total'] != null ? (salesOrder['total'] as num).toStringAsFixed(2) : '-'}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  // Text(
                                  //   'Order No: ${salesOrder['system_order_no']}',
                                  //   style: const TextStyle(
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
      endDrawer: const FilterDrawer(),
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
