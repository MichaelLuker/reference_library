import 'package:fluent_ui/fluent_ui.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import 'package:reference_library/fragments/playlist_widget.dart';
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
                  const Divider(
                    style: DividerThemeData(
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 163, 163, 163)),
                      thickness: 1,
                    ),
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
                            context.read<PlaylistProvider>().prevVideo(context);
                          },
                        )),
                        Expanded(
                            child: IconButton(
                          icon: const Icon(FluentIcons.next),
                          onPressed: () {
                            context.read<PlaylistProvider>().nextVideo(context);
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

class TimestampItem extends StatelessWidget {
  const TimestampItem(this.d, {Key? key}) : super(key: key);
  final TimestampData d;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: d.topic,
        displayHorizontally: true,
        useMousePosition: true,
        style: const TooltipThemeData(
            showDuration: Duration(milliseconds: 500),
            waitDuration: Duration(milliseconds: 500)),
        child: Button(
          style: ButtonStyle(
              padding: ButtonState.all(material.EdgeInsets.zero),
              shape: ButtonState.all(const ContinuousRectangleBorder())),
          child: ListTile(
            shape: const Border.symmetric(horizontal: BorderSide()),
            title: Text(
              "${d.timestampString} | ${d.topic}",
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          onPressed: () {
            context.read<PlaylistProvider>().jumpTo(d.timestamp);
          },
        ));
  }
}
