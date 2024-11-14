import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor {
  Future<void> interceptor(Dio dio) async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (err, handler) async {
          if (err.response != null && err.response!.statusCode == 403) {
            String? errorMessage = err.response!.data['message'];
            if (errorMessage != null &&
                errorMessage.contains('The Token has expired')) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
            }
          }
          return handler.next(err);
        },
      ),
    );
  }
}
