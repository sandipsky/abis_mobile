import 'package:flutter_bloc/flutter_bloc.dart';

class UserCubit extends Cubit<Map<String, dynamic>?> {
  UserCubit() : super(null);

  void updateUserInfo(Map<String, dynamic> newUserInfo) {
    emit(newUserInfo);
  }
}
