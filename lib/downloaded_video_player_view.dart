import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DownloadedVideoPlayerView extends StatelessWidget {
  final File videoFile;

  const DownloadedVideoPlayerView({required this.videoFile, super.key});

  @override
  Widget build(BuildContext context) {
    final videoPlayerController = VideoPlayerController.file(videoFile);

    return Scaffold(
      appBar: AppBar(
        title: Text(videoFile.path.split('/').last),
      ),
      body: FutureBuilder<void>(
        future: videoPlayerController.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                child: VideoPlayer(videoPlayerController),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
