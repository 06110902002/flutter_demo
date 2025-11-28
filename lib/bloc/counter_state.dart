// lib/counter/bloc/counter_state.dart

class CounterState {
  final int count;

  CounterState({required this.count});

  // 初始状态
  factory CounterState.initial() => CounterState(count: 0);

  // 复制并更新部分字段（不可变状态推荐做法）
  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
}