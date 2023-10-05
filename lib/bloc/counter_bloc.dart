import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:meta/meta.dart';
import 'package:untitled5/dataset.dart';
import 'package:video_player/video_player.dart';
part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  int counter = 0;
  List<Map> stories = myList;
  VideoPlayerController controller = VideoPlayerController.networkUrl(
      Uri.parse(myList[0]["stories"][myList[0]["current"]]["url"]))
    ..initialize().then((_) {});
  String mediaType = myList[0]["stories"][myList[0]["current"]]["mediaType"];

  CounterBloc() : super(CounterInitial()) {
    on<NumberIncreaseEvent>(onNumberIncrease);
    on<NumberDecreaseEvent>(onNumberDecrease);
    on<NumberSetEvent>(onNumberSet);
  }

  void onNumberSet(NumberSetEvent event, Emitter<CounterState> emit) async {
    counter = event.counter;
    await controller.dispose();
    mediaType =
        myList[counter]["stories"][myList[counter]["current"]]["mediaType"];
    if (mediaType == "video") {
      controller = VideoPlayerController.networkUrl(Uri.parse(
          myList[counter]["stories"][myList[counter]["current"]]["url"]));
    } else {
      controller = VideoPlayerController.networkUrl(Uri.parse(
          "https://player.vimeo.com/external/484732151.sd.mp4?s=920e951e2eb3ff30c108209d9bf1f4a95c80918f&profile_id=165"));
    }
    emit(UpdateState(counter, stories, controller, mediaType));
    await controller.initialize();
    await controller.play();

    emit(UpdateState(counter, stories, controller, mediaType));
  }

  void onNumberIncrease(
      NumberIncreaseEvent event, Emitter<CounterState> emit) async {
    if (stories[counter]["current"] + 1 < stories[counter]["stories"].length) {
      stories[counter]["current"]++;
      mediaType =
          myList[counter]["stories"][myList[counter]["current"]]["mediaType"];
      await controller.dispose();
      if (mediaType == "video") {
        controller = VideoPlayerController.networkUrl(Uri.parse(
            myList[counter]["stories"][myList[counter]["current"]]["url"]));
      } else {
        controller = VideoPlayerController.networkUrl(Uri.parse(
            "https://player.vimeo.com/external/484732151.sd.mp4?s=920e951e2eb3ff30c108209d9bf1f4a95c80918f&profile_id=165"));
      }
      emit(UpdateState(counter, stories, controller, mediaType));
      await controller.initialize();

      await controller.play();

      emit(UpdateState(counter, stories, controller, mediaType));
    } else {
      if (counter + 1 < stories.length) {
        counter += 1;
        myList[counter]["current"] = myList[counter]["current"];
        mediaType =
            myList[counter]["stories"][myList[counter]["current"]]["mediaType"];
        await controller.dispose();
        if (mediaType == "video") {
          controller = VideoPlayerController.networkUrl(Uri.parse(
              myList[counter]["stories"][myList[counter]["current"]]["url"]));
        } else {
          controller = VideoPlayerController.networkUrl(Uri.parse(
              "https://player.vimeo.com/external/484732151.sd.mp4?s=920e951e2eb3ff30c108209d9bf1f4a95c80918f&profile_id=165"));
        }

        emit(UpdateState(counter, stories, controller, mediaType));
        await controller.initialize();

        await controller.play();

        emit(UpdateState(counter, stories, controller, mediaType));
      }
    }
  }

  void onNumberDecrease(
      NumberDecreaseEvent event, Emitter<CounterState> emit) async {
    if (stories[counter]["current"] - 1 >= 0) {
      stories[counter]["current"]--;
      mediaType =
          myList[counter]["stories"][myList[counter]["current"]]["mediaType"];
      await controller.dispose();
      if (mediaType == "video") {
        controller = VideoPlayerController.networkUrl(Uri.parse(
            myList[counter]["stories"][myList[counter]["current"]]["url"]));
      } else {
        controller = VideoPlayerController.networkUrl(Uri.parse(
            "https://player.vimeo.com/external/484732151.sd.mp4?s=920e951e2eb3ff30c108209d9bf1f4a95c80918f&profile_id=165"));
      }
      emit(UpdateState(counter, stories, controller, mediaType));
      await controller.initialize();

      await controller.play();

      emit(UpdateState(counter, stories, controller, mediaType));
    } else {
      if (counter - 1 >= 0) {
        counter -= 1;
        mediaType =
            myList[counter]["stories"][myList[counter]["current"]]["mediaType"];
        await controller.dispose();
        if (mediaType == "video") {
          controller = VideoPlayerController.networkUrl(Uri.parse(
              myList[counter]["stories"][myList[counter]["current"]]["url"]));
        } else {
          controller = VideoPlayerController.networkUrl(Uri.parse(
              "https://player.vimeo.com/external/484732151.sd.mp4?s=920e951e2eb3ff30c108209d9bf1f4a95c80918f&profile_id=165"));
        }

        emit(UpdateState(counter, stories, controller, mediaType));
        await controller.initialize();

        await controller.play();

        emit(UpdateState(counter, stories, controller, mediaType));
      }
    }
  }
}
