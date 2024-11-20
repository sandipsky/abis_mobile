import 'package:abis_mobile/auth/auth.interceptor.dart';
import 'package:dio/dio.dart';

class DropDownService {
  final baseUrl = 'http://182.93.83.242:9001';
  Dio dio = Dio();

  DropDownService() {
    AuthInterceptor().interceptor(dio);
  }

  Future getCustomerDropdown(String searchTerm) async {
    final response = await dio.get(
      '$baseUrl/dropdown/customers/$searchTerm',
    );
    return response;
  }

  Future getSalesRepresentativeDropdown(
      String searchTerm, int hqId, int divisionId) async {
    final response = await dio.get(
      '$baseUrl/dropdown/users/salesOrder/$searchTerm/$hqId/$divisionId',
    );
    return response;
  }

  Future getHeadquarterDropdown() async {
    final response = await dio.get(
      '$baseUrl/dropdown/report/hqs',
    );
    return response;
  }

  Future getDivisionDropdown() async {
    final response = await dio.get(
      '$baseUrl/dropdown/users/divisions',
    );
    return response;
  }

  Future getDivisionDropdownCustomer(int customerId) async {
    final response = await dio.get(
      '$baseUrl/dropdown/divisionsByCustomer/$customerId',
    );
    return response;
  }

  Future getProductsByTypeDivision(
      String type, String searchTerm, int? divisionId) async {
    final response = await dio.get(
        '$baseUrl/dropdown/productsByType/$type/${divisionId ?? 0}/$searchTerm');
    return response;
  }
}
