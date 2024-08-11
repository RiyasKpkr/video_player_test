import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_subtitle/flutter_subtitle.dart' hide Subtitle;
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class OfflineVideoPlayerController extends GetxController {
  final String videoPath;
  final String subtitlePath;

  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;
  late SubtitleController subtitleController;

  final isInitialized = false.obs;

  OfflineVideoPlayerController(this.videoPath, this.subtitlePath);

  @override
  void onInit() {
    super.onInit();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.file(File(videoPath));
    final subtitleFile = File(subtitlePath);
    final subtitleContent = await subtitleFile.readAsString();
    subtitleController = SubtitleController.string(subtitleContent, format: SubtitleFormat.srt);

    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: videoPlayerController.value.aspectRatio,
      autoPlay: true,
      looping: false,
      subtitleBuilder: (context, subtitle) => IgnorePointer(
        child: SubtitleView(
          text: subtitle,
          subtitleStyle: SubtitleStyle(
            fontSize: chewieController!.isFullScreen ? 20 : 16,
          ),
        ),
      ),
    );

    chewieController!.setSubtitle(
      subtitleController.subtitles
          .map((e) => Subtitle(
                index: e.number,
                start: Duration(milliseconds: e.start),
                end: Duration(milliseconds: e.end),
                text: e.text,
              ))
          .toList(),
    );

    isInitialized.value = true;
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.onClose();
  }
}
