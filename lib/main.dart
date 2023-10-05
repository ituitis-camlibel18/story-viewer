import 'dart:ui';

import 'package:cube_transition_plus/cube_transition_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:linear_timer/linear_timer.dart';
import 'bloc/counter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dataset.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      create: (context) => CounterBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late LinearTimerController linearTimerController =
      LinearTimerController(this);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    linearTimerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: BlocBuilder<CounterBloc, CounterState>(
        builder: (context, state) {
          if (state is CounterInitial) {
            var controller = VideoPlayerController.networkUrl(
                Uri.parse(myList[0]["stories"][myList[0]["current"]]["url"]))
              ..initialize().then((_) {});

            context.read<CounterBloc>().add(NumberSetEvent(0));
            var mediaType =
                myList[0]["stories"][myList[0]["current"]]["mediaType"];

            return _counter(context, 0, myList, controller,
                linearTimerController, mediaType);
          }
          if (state is UpdateState) {
            return _counter(context, state.counter, myList, state.controller,
                linearTimerController, state.mediaType);
          }
          return Container();
        },
      ),
    );
  }
}

//vieo player component
Widget videoPlayer(url) {
  var controller = VideoPlayerController.networkUrl(Uri.parse(url));

  controller.play();
  return VideoPlayer(
    controller,
  );
}

Widget _counter(
  BuildContext context,
  int counter,
  List<Map> stories,
  VideoPlayerController controller,
  LinearTimerController linearTimerController,
  String mediaType,
) {
  var pageController = PageController(viewportFraction: 1.0, keepPage: false);
  return CubePageView.builder(
    controller: pageController,
    onPageChanged: (value) async => {
      //increment counter
      print(
          "---------------------------------------hello--------------------------------------------------------"),
      print(
          "----------------------------------Counter:$counter--------------------------"),
      if (counter == 0)
        {
          await controller.initialize().then((_) {
            controller.play();
            controller.setLooping(true);
          }),
        },
      context.read<CounterBloc>().add(NumberSetEvent(value)),
    },
    itemCount: stories.length,
    itemBuilder: (context, index, notifier) {
      final transform = Matrix4.identity();
      counter = index;

      final t = (index - notifier).abs();
      final scale = lerpDouble(1.5, 0, t);
      transform.scale(scale, scale);
      //set duration of the video
      if (controller.value.isInitialized) {
        controller.addListener(() {
          controller.play();
          if (controller.value.position == controller.value.duration) {
            context.read<CounterBloc>().add(NumberIncreaseEvent());
          }
        });
      }
      return CubeWidget(
          index: index,
          pageNotifier: notifier,
          child: controller.value.isInitialized && !controller.value.hasError
              ? Stack(
                  children: [
                    GestureDetector(
                        onLongPressStart: (details) {
                          // This block of code will be executed when a long press is detected
                          controller.pause();
                        },
                        onLongPressEnd: (details) {
                          // This block of code will be executed when the long press is released
                          // You can add the logic you want to execute upon the release of the long press here
                          controller.play();
                        },
                        onTapUp: (details) {
                          //refresh page

                          print(
                              "---------------------------counter:$counter-------------------------------------");

                          if (details.globalPosition.dx >
                              3 * MediaQuery.of(context).size.width / 4) {
                            //decrease index too

                            context
                                .read<CounterBloc>()
                                .add(NumberIncreaseEvent());
                          } else if (details.globalPosition.dx <
                              MediaQuery.of(context).size.width / 4) {
                            context
                                .read<CounterBloc>()
                                .add(NumberDecreaseEvent());
                          }
                        },
                        child: Stack(children: [
                          mediaType == "video"
                              ? VideoPlayer(controller)
                              : Image.network(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  stories[counter]["stories"]
                                          [myList[counter]["current"]]["url"]
                                      .toString(),
                                  frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) {
                                  return child;
                                }, loadingBuilder:
                                      (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.white,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.black),
                                        ),
                                      ),
                                    );
                                  }
                                }),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: stories[counter]["stories"]
                                  .asMap()
                                  .entries
                                  .map<Widget>((entry) {
                                int index = entry.key;
                                var e = entry.value;
                                if (index == stories[counter]["current"]) {
                                  return Expanded(
                                      child: VideoProgressIndicator(
                                          controller
                                            ..setPlaybackSpeed(
                                                mediaType == "video"
                                                    ? 1.0
                                                    : 3.0),
                                          allowScrubbing: false,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 40, horizontal: 15),
                                          colors: const VideoProgressColors(
                                            backgroundColor: Colors.grey,
                                            bufferedColor: Colors.grey,
                                            playedColor: Colors.white,
                                          )));
                                } else if (index <
                                    stories[counter]["current"]) {
                                  return Expanded(
                                      child: VideoProgressIndicator(
                                          VideoPlayerController.networkUrl(
                                              Uri.parse("")),
                                          allowScrubbing: false,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 40, horizontal: 15),
                                          colors: const VideoProgressColors(
                                            backgroundColor: Colors.white,
                                            bufferedColor: Colors.white,
                                            playedColor: Colors.white,
                                          )));
                                } else {
                                  return Expanded(
                                      child: VideoProgressIndicator(
                                          VideoPlayerController.networkUrl(
                                              Uri.parse("")),
                                          allowScrubbing: false,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 40, horizontal: 15),
                                          colors: const VideoProgressColors(
                                            backgroundColor: Colors.grey,
                                            bufferedColor: Colors.grey,
                                            playedColor: Colors.transparent,
                                          )));
                                }
                              }).toList())
                        ])),
//Map of progress bars in the  stories[counter]["stories"]
                  ],
                )
              : Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                ));
    },
  );
}
