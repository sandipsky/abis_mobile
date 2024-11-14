import 'package:abis_mobile/auth/auth.interceptor.dart';
import 'package:abis_mobile/cubit/config.cubit.dart';
import 'package:dio/dio.dart';

class ConfigService {
  final baseUrl = 'http://182.93.83.242:9001';
  Dio dio = Dio();

  ConfigService() {
    AuthInterceptor().interceptor(dio);
  }

  Future getConfig() async {
    final response = await dio.get(
      '$baseUrl/master/configuration/view',
    );
    return response;
  }

  void setConfig(List<dynamic> response, ConfigCubit configCubit) {
    final configs = convertConfig(response);
    configCubit.updateConfig(configs);
  }

  Map<String, String> convertConfig(List<dynamic> configList) {
    Map<String, String> configMap = {
      for (var item in configList) item['name']: item['value']
    };
    return configMap;
  }
}
