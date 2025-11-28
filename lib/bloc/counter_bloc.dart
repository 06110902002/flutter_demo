// lib/counter/bloc/counter_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter_event.dart';
import 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState.initial()) {
    // 监听 Increment 事件
    on<Increment>((event, emit) {
      emit(state.copyWith(count: state.count + 1));
    });

    // 监听 Decrement 事件
    on<Decrement>((event, emit) {
      emit(state.copyWith(count: state.count - 1));
    });

    // 监听 Reset 事件
    on<Reset>((event, emit) {
      emit(CounterState.initial());
    });
  }
}