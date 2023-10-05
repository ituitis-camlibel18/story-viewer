part of 'counter_bloc.dart';

@immutable
abstract class CounterEvent {}

class NumberIncreaseEvent extends CounterEvent {}

class NumberDecreaseEvent extends CounterEvent {}

class NumberSetEvent extends CounterEvent {
  final int counter;

  NumberSetEvent(this.counter);
}

class StartTimerEvent extends CounterEvent {}
