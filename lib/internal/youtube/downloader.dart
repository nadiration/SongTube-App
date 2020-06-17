// Dart
import 'dart:io';
import 'dart:async';

// Internal
import 'package:songtube/internal/models/enums.dart';
import 'package:songtube/internal/youtube/infoparser.dart';

// Packages
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:ext_storage/ext_storage.dart';

class Downloader {

  // Create Streams to track file download status
  final StreamController<double> progressBar = new StreamController<double>();
  final StreamController<String> dataProgress = new StreamController<String>();

  // Variables
  double fileSize = 0;
  bool downloadFinished = false;

  // Last Audio/Video successfully downloaded
  String lastAudioDownloaded;
  String lastVideoDownloaded;

  Future<int> downloadStream(Video videoDetails, StreamManifest streamManifest, DownloadType type, [int videoIndex]) async { 

    YoutubeExplode yt = YoutubeExplode();

    // Check path to save Video
    String _directory = await ExtStorage.getExternalStorageDirectory() + "/SongTube";
    if (!(await Directory(_directory).exists())) await Directory(_directory).create();
    _directory = _directory + "/tmp";
    if (!(await Directory(_directory).exists())) await Directory(_directory).create();

    // Video Details
    List<VideoStreamInfo> videoStreamList = streamManifest.videoOnly.sortByVideoQuality();

    // Get video to download
    var streamToGet = type == DownloadType.video
      ? videoStreamList[videoIndex]
      : streamManifest.audioOnly.last;

    // Compose the file name removing the unallowed characters in windows.
    String _fileName;
    if (type == DownloadType.video) _fileName = videoDetails.title.toString() + "-video";
    if (type == DownloadType.audio) _fileName = videoDetails.title.toString() + "-audio";
    _fileName = _fileName.replaceAll('Container.', '')
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');
    File _filePath = File("$_directory/$_fileName");

    // Open the file in write.
    var _output = _filePath.openWrite(mode: FileMode.write);

    // Local variables for file status
    var _count = 0;
    var _oldProgress = -1;
    var _len = streamToGet.size.totalBytes;
    fileSize = fileSize + double.parse((streamToGet.size.totalBytes * 0.000001).toStringAsFixed(2));

    // Start stream download, also update internal public
    // StreamController for external access
    await for (var data in yt.videos.streamsClient.get(streamToGet)) {
      if (downloadFinished == true) { _output.close(); yt.close(); return null; }
      _count += data.length;
      dataProgress.add((_count * 0.000001).toStringAsFixed(2));
      print("Downloading: " + _count.toString());
      var progress = ((_count / _len) * 100).round();
      if (progress != _oldProgress) {
        _oldProgress = progress;
        progressBar.add((progress * 0.01).toDouble());
      }
      _output.add(data);
    }
    downloadFinished = true;
    await _output.close();
    yt.close();
    type == DownloadType.video
      ? lastVideoDownloaded = "$_directory/$_fileName"
      : lastAudioDownloaded = "$_directory/$_fileName";
    return 0;
  }

}