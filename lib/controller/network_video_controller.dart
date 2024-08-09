// import 'dart:convert';

import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_subtitle/flutter_subtitle.dart' hide Subtitle;
import 'package:get/get.dart';

import 'package:http/http.dart' as https;

import 'package:video_player/video_player.dart';

//subtitle vtt file
// https://cc.zorores.com/20/2e/202eaab6dff289a5976399077449654e/eng-2.vtt

class NetworkVideoController extends GetxController {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  late SubtitleController _subtitleController;
  final isInitialized = false.obs;

  @override
  void onInit() {
    initializePlayer();
    super.onInit();
  }

  Future<void> initializePlayer() async {
    final body = utf8.decode((await https.get(
      Uri.parse('https://gotranscript.com/samples/captions-example.srt'),
    ))
        .bodyBytes);

    _subtitleController =
        SubtitleController.string(body, format: SubtitleFormat.srt);

    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        // "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
        "https://gotranscript.com/samples/GoTrascript_captions_samples.mp4",
      ),
    );

    try {
      await videoPlayerController.initialize();
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 3 / 2,
        autoPlay: true,
        hideControlsTimer: const Duration(seconds: 1),
        allowPlaybackSpeedChanging: true,
        cupertinoProgressColors: chewieProgressColors(),
        materialProgressColors: chewieProgressColors(),
        subtitleBuilder: (context, subtitle) {
          return IgnorePointer(
            child: SubtitleView(
              text: subtitle,
              subtitleStyle: SubtitleStyle(
                fontSize: chewieController.isFullScreen ? 20 : 16,
              ),
            ),
          );
        },
      );

      chewieController.setSubtitle(
        _subtitleController.subtitles
            .map(
              (e) => Subtitle(
                  index: e.number,
                  start: Duration(milliseconds: e.start),
                  end: Duration(milliseconds: e.end),
                  text: e.text),
            )
            .toList(),
      );

      isInitialized.value = true;
    } catch (error) {
      debugPrint("Error initializing video player: $error");
    }
    update();
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.onClose();
  }
}

ChewieProgressColors chewieProgressColors() {
  return ChewieProgressColors(
    playedColor: Colors.red,
    handleColor: Colors.red,
    backgroundColor: Colors.grey,
    bufferedColor: Colors.white,
  );
}
