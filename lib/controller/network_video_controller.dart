import 'dart:convert';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_subtitle/flutter_subtitle.dart' hide Subtitle;
import 'package:get/get.dart';

import 'package:http/http.dart' as https;
import 'package:path_provider/path_provider.dart';

import 'package:video_player/video_player.dart';

//subtitle vtt file
// https://cc.zorores.com/20/2e/202eaab6dff289a5976399077449654e/eng-2.vtt

class NetworkVideoController extends GetxController {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  late SubtitleController _subtitleController;
  final isInitialized = false.obs;
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;
  final storage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  final String videoUrl = "https://gotranscript.com/samples/GoTrascript_captions_samples.mp4";
  final String subtitleUrl = 'https://gotranscript.com/samples/captions-example.srt';

  @override
  void onInit() {
    initializePlayer();
    super.onInit();
  }

  Future<void> initializePlayer() async {
    await initializeOnlinePlayer();
  }

  String _generateId(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  Future<void> initializeOnlinePlayer() async {
    final body = utf8.decode((await https.get(Uri.parse(subtitleUrl))).bodyBytes);
    _subtitleController = SubtitleController.string(body, format: SubtitleFormat.srt);

    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    await _initializeChewieController();
  }

  Future<void> _initializeChewieController() async {
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
              (e) => Subtitle(index: e.number, start: Duration(milliseconds: e.start), end: Duration(milliseconds: e.end), text: e.text),
            )
            .toList(),
      );

      isInitialized.value = true;
    } catch (error) {
      debugPrint("Error initializing video player: $error");
    }
    update();
  }

  Future<void> downloadVideo() async {
    if (isDownloading.value) return;

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final videoId = _generateId(videoUrl);
      final videoFile = File('${directory.path}/video_$videoId.mp4');
      final subtitleFile = File('${directory.path}/subtitle_$videoId.srt');

      await _downloadFileWithProgress(videoUrl, videoFile);
      await _downloadFileWithProgress(subtitleUrl, subtitleFile);

      await storage.write(key: 'videoPath_$videoId', value: videoFile.path);
      await storage.write(key: 'subtitlePath_$videoId', value: subtitleFile.path);

      Get.snackbar(
        'Success',
        'Video and subtitles downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download video or subtitles: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  Future<void> _downloadFileWithProgress(String url, File file) async {
    try {
      await _dio.download(
        url,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );
    } catch (e) {
      throw Exception('Error downloading file: $e');
    }
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
