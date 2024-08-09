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
      ),
      body: Obx(
        () => ctr.isInitialized.value
            ? Center(
                child: AspectRatio(
                  aspectRatio: ctr
                      .chewieController.videoPlayerController.value.aspectRatio,
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
