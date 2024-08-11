import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player_test/controller/download_controller.dart';

import 'controller/offline_video_controller.dart';

class DownloadedVideosView extends StatelessWidget {
  const DownloadedVideosView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.put(DownloadedVideosController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloaded Videos"),
      ),
      body: Obx(
        () => ctr.downloadedVideos.isEmpty
            ? const Center(child: Text("No downloaded videos"))
            : ListView.builder(
                itemCount: ctr.downloadedVideos.length,
                itemBuilder: (context, index) {
                  final video = ctr.downloadedVideos[index];
                  return ListTile(
                    title: Text("Video ${index + 1}"),
                    // subtitle: Text(video['videoPath']!.split('/').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => ctr.deleteVideo(video['id']!),
                    ),
                    onTap: () {
                      Get.to(() => OfflineVideoPlayerView(
                            videoPath: video['videoPath']!,
                            subtitlePath: video['subtitlePath']!,
                          ));
                    },
                  );
                },
              ),
      ),
    );
  }
}

class OfflineVideoPlayerView extends StatelessWidget {
  final String videoPath;
  final String subtitlePath;

  const OfflineVideoPlayerView({
    super.key,
    required this.videoPath,
    required this.subtitlePath,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OfflineVideoPlayerController(videoPath, subtitlePath));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Video Player"),
      ),
      body: Center(
        child: Obx(() => controller.isInitialized.value ? Chewie(controller: controller.chewieController!) : const CircularProgressIndicator()),
      ),
    );
  }
}
