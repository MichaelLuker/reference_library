import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/fragments/video_card.dart';
import 'package:reference_library/providers/data_provider.dart';

// I think this can be stateless, it'll just rebuild a grid like view of videos based on the data provider
// If a video is clicked then it'll just throw it on the playlist and jump to the playing pane
class LibraryScreen extends StatelessWidget {
  LibraryScreen({Key? key}) : super(key: key);
  late List<VideoData> _allVideos;
  ScrollController _sc = ScrollController();
  int _extraScrollSpeed = 50;

  List<Widget> buildResults(List<VideoData> videos) {
    List<Widget> r = [];
    for (VideoData v in videos) {
      r.add(VideoCard(v));
    }
    return r;
  }

  @override
  Widget build(BuildContext context) {
    _sc.addListener(() {
      ScrollDirection scrollDirection = _sc.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = _sc.offset +
            (scrollDirection == ScrollDirection.reverse
                ? _extraScrollSpeed
                : -_extraScrollSpeed);
        scrollEnd = min(_sc.position.maxScrollExtent,
            max(_sc.position.minScrollExtent, scrollEnd));
        _sc.jumpTo(scrollEnd);
      }
    });

    _allVideos = context.watch<DataProvider>().videos;
    return ScaffoldPage(
      content: GridView.count(
          controller: _sc,
          crossAxisCount: 5,
          children: buildResults(_allVideos)),
    );
  }
}
