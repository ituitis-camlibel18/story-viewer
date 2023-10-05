part of 'counter_bloc.dart';

@immutable
abstract class CounterState {}

class CounterInitial extends CounterState {}

class UpdateState extends CounterState {
  final int counter;
  final List<Map> stories;
  final VideoPlayerController controller;
  final String mediaType;

  UpdateState(this.counter, this.stories, this.controller, this.mediaType);
}
