import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/screens/homeScreen/components/videoTile.dart';

class HomePageWatchLater extends StatelessWidget {
  final int index;
  HomePageWatchLater(this.index);
  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: VideoTile(
        searchItem: prefs.watchLaterVideos[index],
      ),
    );
  }
}