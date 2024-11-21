import 'package:abis_mobile/auth/auth.interceptor.dart';
import 'package:dio/dio.dart';

class SalesOrderService {
  final baseUrl = 'http://182.93.83.242:9001';
  Dio dio = Dio();

  SalesOrderService() {
    AuthInterceptor().interceptor(dio);
  }

  Future getPendingSalesOrder(int customerId, int divisionId) async {
    final response = await dio.get(
      '$baseUrl/salesOrder/getPendingOrders/$customerId/$divisionId',
    );
    return response;
  }

  Future getProductDetail(int productId) async {
    final response = await dio.get(
      '$baseUrl/master/products/$productId',
    );
    return response;
  }

  Future getCustomerDetail(int customerId) async {
    final response = await dio.get(
      '$baseUrl/master/customers/$customerId',
    );
    return response;
  }

  Future getSalesOrderNumber() async {
    final response = await dio.get(
      '$baseUrl/salesOrder/salesInvoiceNumber',
    );
    return response;
  }

  Future getAttachment(String fileUrl) async {
    final response = await dio.get(
      fileUrl,
    );
    return response;
  }

  Future getSalesOrderById(int id) async {
    final response = await dio.get(
      '$baseUrl/salesOrder/operate/$id',
    );
    return response;
  }

  Future changeSalesOrderStatus(int id, dynamic data, String status) async {
    final response = await dio
        .put('$baseUrl/salesOrder/operate/status/$id/$status', data: data);
    return response;
  }

  Future createSalesOrder(dynamic data) async {
    final response = await dio.post('$baseUrl/salesOrder/operate', data: data);
    return response;
  }

  Future getSalesOrderList(dynamic data) async {
    final response =
        await dio.post('$baseUrl/salesOrder/operate/view', data: data);
    return response;
  }

  Future getDueInvoices(int customerId) async {
    final response = await dio.get(
      '$baseUrl/salesEntries/getSalesAgeing/$customerId',
    );
    return response;
  }
}
