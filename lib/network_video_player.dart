import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/network_video_controller.dart';

class NetworkVideoPlayerView extends StatelessWidget {
  const NetworkVideoPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.put(NetworkVideoController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Network Video Player"),
        actions: [
          Obx(() {
            if (ctr.isDownloading.value) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  value: ctr.downloadProgress.value,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              );
            } else {
              return IconButton(
                onPressed: () => ctr.downloadVideo(),
                icon: const Icon(Icons.download),
              );
            }
          }),
        ],
      ),
      body: Obx(
        () => ctr.isInitialized.value
            ? Center(
                child: AspectRatio(
                  aspectRatio: ctr.chewieController.videoPlayerController.value.aspectRatio,
                  child: Chewie(controller: ctr.chewieController),
                ),
              )
            : const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
      ),
    );
  }
}
