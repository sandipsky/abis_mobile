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
}
