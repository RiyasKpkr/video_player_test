// Future<void> downloadFile(String url, String filename, Function(double) onProgress) async {
//   Dio dio = Dio();
//   final dir = await getApplicationDocumentsDirectory(); // This returns a Directory
//   final path = '${dir.path}/$filename'; // Convert Directory to String by accessing 'path'

//   try {
//     await dio.download(
//       url,
//       path,
//       onReceiveProgress: (received, total) {
//         if (total != -1) {
//           final progress = received / total;
//           onProgress(progress);
//         }
//       },
//     );
//   } catch (e) {
//     print("Download failed: $e");
//   }
// }
