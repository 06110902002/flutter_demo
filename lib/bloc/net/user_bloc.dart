// lib/user/bloc/user_bloc.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_model.dart';
import 'user_event.dart';
import 'user_state.dart';

///第五步：实现 Bloc（处理逻辑 + 网络请求）
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<FetchUser>(_onFetchUser);
  }

  Future<void> _onFetchUser(FetchUser event, Emitter<UserState> emit) async {
    emit(UserLoading()); // 开始加载

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users/${event.userId}'),
      );
      print("23------------resp = ${response.body}");
      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        emit(UserLoaded(user));
      } else {
        emit(UserError('Failed to load user: ${response.statusCode}'));
      }
    } catch (e) {
      emit(UserError('Network error: $e'));
    }
  }
}