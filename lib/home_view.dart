import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player_test/network_video_player.dart';

import 'downloaded_video.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("video player"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(const NetworkVideoPlayerView());
              },
              child: const Text("network"),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(const DownloadedVideosView());
              },
              child: const Text("downloaded video"),
            ),
          ],
        ),
      ),
    );
  }
}
