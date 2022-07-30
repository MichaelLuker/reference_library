import 'dart:developer';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';

// Page showing the video, video controls, timestamps, playlist
class PlaybackScreen extends StatelessWidget {
  const PlaybackScreen({Key? key}) : super(key: key);

  List<Widget> buildTimestamps(BuildContext context, List<TimestampData> ts) {
    List<Widget> r = [];
    for (TimestampData d in ts) {
      r.add(TimestampItem(d));
    }
    return r;
  }

  @override
  Widget build(BuildContext context) {
    VideoData? data = context.watch<PlaylistProvider>().currentVideo;
    if (data == null) {
      return const Center(child: Text("No videos selected yet..."));
    }
    List<VideoData> playList = context.watch<PlaylistProvider>().playList;
    return ScaffoldPage(
      header: Row(children: [
        Expanded(child: Center(child: Text(data.title))),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Container(),
        )
      ]),
      content: material.Card(
        child: Center(
            child: material.Row(
          //child: NativeVideo(player: player),
          children: [
            Expanded(
                flex: 8,
                child: Video(
                    //showFullscreenButton: true, need to have a control to unfullscreen this
                    player: context.watch<PlaylistProvider>().player)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Column(
                children: [
                  ToggleSwitch(
                    content: const Text("Random Mode"),
                    checked: context.watch<PlaylistProvider>().randomMode,
                    onChanged: (bool value) {
                      context
                          .read<PlaylistProvider>()
                          .setRandomMode(value, context);
                    },
                  ),
                  Expanded(
                      flex: 11,
                      child: SizedBox(
                          child: Column(
                        children: [
                          const Text(
                            "Timestamps",
                            style: TextStyle(fontSize: 18),
                          ),
                          Expanded(
                              child: SingleChildScrollView(
                                  controller: ScrollController(),
                                  child: Wrap(
                                    children: buildTimestamps(
                                        context, data.timestamps),
                                  )))
                        ],
                      ))),
                  Expanded(flex: 11, child: SizedBox(child: PlayListWidget())),
                  SizedBox(
                    height: 28,
                    child: Row(
                      children: [
                        Expanded(
                            child: IconButton(
                          icon: const Icon(FluentIcons.previous),
                          onPressed: () {
                            context.read<PlaylistProvider>().prevVideo();
                          },
                        )),
                        Expanded(
                            child: IconButton(
                          icon: const Icon(FluentIcons.next),
                          onPressed: () {
                            context.read<PlaylistProvider>().nextVideo();
                          },
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        )),
      ),
    );
  }
}

class PlayListWidget extends StatelessWidget {
  List<Widget> buildPlaylist(BuildContext context, List<VideoData> pl) {
    List<Widget> r = [];
    for (VideoData d in pl) {
      r.add(
          PlaylistItem(d, d == context.read<PlaylistProvider>().currentVideo));
    }
    return r;
  }

  @override
  Widget build(BuildContext context) {
    List<VideoData> pl = context.watch<PlaylistProvider>().playList;
    return Column(
      children: [
        const Text(
          "Playlist",
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
            child: SingleChildScrollView(
                controller: ScrollController(),
                child: Wrap(
                  children: buildPlaylist(context, pl),
                )))
      ],
    );
  }
}

class TimestampItem extends StatefulWidget {
  const TimestampItem(this.d, {Key? key}) : super(key: key);
  final TimestampData d;

  @override
  // ignore: no_logic_in_create_state
  State<TimestampItem> createState() => _TimestampItemState(d);
}

class _TimestampItemState extends State<TimestampItem> {
  _TimestampItemState(this.d);
  final TimestampData d;
  bool selected = false;
  Color backgroundcolor = ThemeData.dark().cardColor;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: d.topic,
      displayHorizontally: true,
      useMousePosition: true,
      style: const TooltipThemeData(
          showDuration: Duration(milliseconds: 500),
          waitDuration: Duration(milliseconds: 500)),
      child: MouseRegion(
        onEnter: (_) {
          if (!selected) {
            setState(() {
              backgroundcolor = ThemeData.dark().shadowColor;
            });
          }
        },
        onExit: (_) {
          if (!selected) {
            setState(() {
              backgroundcolor = ThemeData.dark().cardColor;
            });
          }
        },
        child: GestureDetector(
          onTap: () {
            context.read<PlaylistProvider>().jumpTo(d.timestamp);
            setState(() {
              selected = true;
              int alpha = 150;
              for (int s = 1; s <= 15; s++) {
                Future.delayed(Duration(milliseconds: 100 * s)).then((_) {
                  setState(() {
                    if ((s * 10) == 150) {
                      selected = false;
                      backgroundcolor = ThemeData.dark().cardColor;
                      return;
                    }
                    backgroundcolor = Color.fromARGB(255, 40, 109, 228)
                        .withAlpha(alpha - (s * 10));
                  });
                });
              }
            });
          },
          child: ListTile(
            tileColor: backgroundcolor,
            shape: const Border.symmetric(horizontal: BorderSide()),
            title: Text(
              "${widget.d.timestampString} | ${widget.d.topic}",
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
                onPressed: () {}, icon: const Icon(FluentIcons.collapse_menu)),
          ),
        ),
      ),
    );
  }
}

class PlaylistItem extends StatelessWidget {
  const PlaylistItem(this.d, this.playingVideo, {Key? key}) : super(key: key);
  final VideoData d;
  final bool playingVideo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: playingVideo
          ? Color.fromARGB(255, 40, 109, 228)
          : material.ThemeData.dark().cardColor,
      shape: const Border.symmetric(horizontal: BorderSide()),
      title: Text(
        d.title,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
          onPressed: () {
            context.read<PlaylistProvider>().dequeueVideo(d);
          },
          icon: const Icon(FluentIcons.delete)),
    );
  }
}
