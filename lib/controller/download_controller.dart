import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class DownloadedVideosController extends GetxController {
  final storage = const FlutterSecureStorage();
  final downloadedVideos = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDownloadedVideos();
  }

  Future<void> loadDownloadedVideos() async {
    final allItems = await storage.readAll();
    final videoPaths = allItems.entries.where((entry) => entry.key.startsWith('videoPath_')).map((entry) {
      final videoId = entry.key.substring('videoPath_'.length);
      final subtitlePath = allItems['subtitlePath_$videoId'];
      return {
        'id': videoId,
        'videoPath': entry.value,
        'subtitlePath': subtitlePath ?? '',
      };
    }).toList();

    downloadedVideos.assignAll(videoPaths);
  }

  Future<void> deleteVideo(String videoId) async {
    await storage.delete(key: 'videoPath_$videoId');
    await storage.delete(key: 'subtitlePath_$videoId');

    final videoToDelete = downloadedVideos.firstWhere((video) => video['id'] == videoId);
    File(videoToDelete['videoPath']!).deleteSync();
    File(videoToDelete['subtitlePath']!).deleteSync();

    downloadedVideos.removeWhere((video) => video['id'] == videoId);
  }
}
