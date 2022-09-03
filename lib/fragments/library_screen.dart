import 'dart:math';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/editing_provider.dart';
import 'package:reference_library/providers/settings_provider.dart';
import 'package:reference_library/widgets/playlist_widget.dart';
import 'package:reference_library/widgets/video_card.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';

import 'package:reference_library/providers/playlist_provider.dart';
import 'package:reference_library/widgets/video_edit.dart';
import 'package:youtube/youtube_thumbnail.dart';

// I think this can be stateless, it'll just rebuild a grid like view of videos based on the data provider
// If a video is clicked then it'll just throw it on the playlist and jump to the playing pane
// ignore: must_be_immutable
class LibraryScreen extends StatelessWidget {
  LibraryScreen({Key? key, required this.videoList}) : super(key: key);

  final ScrollController _sc = ScrollController();
  final int _extraScrollSpeed = 50;

  Map<String, VideoData> videoList;

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

    List<VideoData> sortedVideos = [...videoList.values.toList()];
    sortedVideos.sort((a, b) => a.title.compareTo(b.title));

    return ScaffoldPage(
      content: Stack(
        children: [
          Row(
            children: [
              (context.watch<PlaylistProvider>().playList.isNotEmpty &&
                      context.watch<NavigationProvider>().index == 0)
                  ? SizedBox(width: 250, child: PlayListWidget())
                  : Container(),
              SizedBox(
                width: (context.watch<PlaylistProvider>().playList.isNotEmpty)
                    ? MediaQuery.of(context).size.width - 300
                    : MediaQuery.of(context).size.width - 50,
                child: GridView.count(
                    controller: _sc,
                    crossAxisCount: 5,
                    children: sortedVideos.map((e) => VideoCard(e)).toList()),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () {
                  // New Video Prompt
                  VideoData newData = VideoData(
                      "", "", "", false, "", -1, false, "", [], [], "");
                  context.read<EditingProvider>().setVideoData(newData);
                  context
                      .read<EditingProvider>()
                      .setTimestamps(newData.timestamps);
                  context.read<EditingProvider>().setTags(newData.tags);
                  showDialog<VideoData>(
                      context: context,
                      builder: (context) => VideoEditDialog(
                            title: "New Video Information",
                            d: newData,
                            newVideo: true,
                          )).then((value) {
                    if (value != null) {
                      // Update the container with all the new values it needs
                      newData = value;

                      // Download the thumbnail, lazy copy of the data_provider thumbnail code... :D
                      File thumbnail = File(
                          "${context.read<SettingsProvider>().thumbFolder.path}/${newData.videoId}.jpg");
                      if (!thumbnail.existsSync()) {
                        if (newData.url.contains("youtube")) {
                          String tmbUrl = YoutubeThumbnail(
                                  youtubeId: newData.url.split('watch?v=').last)
                              .hq();
                          NetworkAssetBundle(Uri.parse(tmbUrl))
                              .load(tmbUrl)
                              .then((value) {
                            Uint8List tmbBytes = value.buffer.asUint8List();
                            thumbnail.create().then((value) {
                              value.writeAsBytes(tmbBytes);
                              newData.thumbnailPath = thumbnail.path;

                              // Then write the actual video data file and add it to the list
                              context.read<DataProvider>().createVideo(newData);

                              // Then refresh the view after some time for thumbnail download?
                              // Future.delayed(const Duration(milliseconds: 150))
                              //     .then((value) => context
                              //         .read<NavigationProvider>()
                              //         .refreshPage());
                            });
                          });
                        }
                      }
                    }
                  });
                },
                icon: const Icon(
                  FluentIcons.circle_addition,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
