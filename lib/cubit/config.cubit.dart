import 'package:flutter_bloc/flutter_bloc.dart';

class ConfigCubit extends Cubit<Map<String, dynamic>?> {
  ConfigCubit() : super(null);

  void updateConfig(Map<String, dynamic> config) {
    emit(config);
  }
}
