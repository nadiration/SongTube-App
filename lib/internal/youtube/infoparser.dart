// Packages
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeInfo {

  // Get link ID
  static String getLinkID(String url) => VideoId.parseVideoId(url);

  // Get video information
  static Future<Video> getVideoInfo(String url) async {

    // Video Details
    YoutubeExplode yt = YoutubeExplode();
    Video videoDetails;

    // Try get video details by url
    try {
      videoDetails = await yt.videos.get(url);
    } on Exception catch (_) {
      print("Couldn't get url");
      return null;
    }

    // Return metadata and mediaStream
    return videoDetails;
  }

  // Get Stream manifest
  static Future<StreamManifest> getStreamManifest(String url) async {

    // Stream Manifest
    YoutubeExplode yt = YoutubeExplode();
    StreamManifest streamManifest;

    // Try get video manifest by url
    try {
      streamManifest = await yt.videos.streamsClient.getManifest(url);
    } on Exception catch (_) {
      print("Couldn't get url");
      return null;
    }

    // Return metadata and mediaStream
    return streamManifest;
  }

  static Future<String> getChannelLink(String url) async {

    // Youtube Explode
    YoutubeExplode yt = YoutubeExplode();

    // Get channel ID
    Channel channelId = await yt.channels.getByVideo(getLinkID(url));
    yt.close();
    return "https://youtube.com/channel/" + channelId.id.value;
  }

}