import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import 'package:reference_library/widgets/playlist_widget.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';
import 'package:reference_library/widgets/tags_widget.dart';

// Page showing the video, video controls, timestamps, playlist
class PlaybackScreen extends StatelessWidget {
  const PlaybackScreen({Key? key}) : super(key: key);

  List<Widget> buildTimestamps(BuildContext context, List<TimestampData> ts) {
    List<Widget> r = [];
    ts.sort((a, b) => a.timestamp.compareTo(b.timestamp));
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
                          Center(
                            child: Wrap(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Timestamps",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 6, 8, 8),
                                  child: IconButton(
                                      onPressed: () {
                                        TextEditingController topicTEC =
                                            TextEditingController();
                                        TextEditingController hoursTEC =
                                            TextEditingController();
                                        TextEditingController minutesTEC =
                                            TextEditingController();
                                        TextEditingController secondsTEC =
                                            TextEditingController();

                                        topicTEC.text = "Timestamp Topic";
                                        List<String> timePieces = [
                                          "00",
                                          "00",
                                          "00"
                                        ];
                                        hoursTEC.text = timePieces[0];
                                        minutesTEC.text = timePieces[1];
                                        secondsTEC.text = timePieces[2];

                                        TagList tags =
                                            TagList(selectedTags: []);

                                        showDialog<TimestampItem>(
                                            context: context,
                                            builder: (context) => ContentDialog(
                                                  title: const Center(
                                                    child: Text(
                                                      "Edit Timestamp",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  content: Wrap(children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          0, 0, 0, 16),
                                                      child: TextBox(
                                                        controller: topicTEC,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Text(
                                                            "  Timestamp:  "),
                                                        SizedBox(
                                                          width: 50,
                                                          child: TextBox(
                                                            maxLength: 2,
                                                            controller:
                                                                hoursTEC,
                                                          ),
                                                        ),
                                                        const Text(":"),
                                                        SizedBox(
                                                          width: 50,
                                                          child: TextBox(
                                                            maxLength: 2,
                                                            controller:
                                                                minutesTEC,
                                                          ),
                                                        ),
                                                        const Text(":"),
                                                        SizedBox(
                                                          width: 50,
                                                          child: TextBox(
                                                            maxLength: 2,
                                                            controller:
                                                                secondsTEC,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 18, 0, 0),
                                                        child: SizedBox(
                                                          width: 300,
                                                          height: 300,
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius: const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          10)),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors
                                                                            .grey[200]),
                                                                    BoxShadow(
                                                                        color: Colors.grey[
                                                                            160],
                                                                        spreadRadius:
                                                                            -6,
                                                                        blurRadius:
                                                                            6)
                                                                  ]),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: tags,
                                                              )),
                                                        ),
                                                      ),
                                                    )
                                                  ]),
                                                  actions: [
                                                    Button(
                                                        onPressed: () {
                                                          int? hours =
                                                              int.tryParse(
                                                                  hoursTEC
                                                                      .text);
                                                          int? minutes =
                                                              int.tryParse(
                                                                  hoursTEC
                                                                      .text);
                                                          int? seconds =
                                                              int.tryParse(
                                                                  hoursTEC
                                                                      .text);
                                                          if (hours != null &&
                                                              minutes != null &&
                                                              seconds != null) {
                                                            context
                                                                .read<
                                                                    DataProvider>()
                                                                .createTimestamp(
                                                                    data
                                                                        .videoId,
                                                                    TimestampData(
                                                                        tags
                                                                            .selectedTags,
                                                                        data
                                                                            .videoId,
                                                                        topicTEC
                                                                            .text,
                                                                        "${hoursTEC.text.padLeft(2, "0")}:${minutesTEC.text.padLeft(2, "0")}:${secondsTEC.text.padLeft(2, "0")}"));
                                                            context
                                                                .read<
                                                                    PlaylistProvider>()
                                                                .updateCurrentVideoData(
                                                                    context);
                                                            Navigator.pop(
                                                                context);
                                                          } else {
                                                            showSnackbar(
                                                                context,
                                                                const Card(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .black,
                                                                    child: Text(
                                                                      "Bad Timestamp",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.warningPrimaryColor),
                                                                    )),
                                                                alignment:
                                                                    Alignment
                                                                        .center);
                                                          }
                                                        },
                                                        child:
                                                            const Text("Save")),
                                                    FilledButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            "Cancel"))
                                                  ],
                                                ));
                                      },
                                      icon: const Icon(
                                          FluentIcons.circle_addition)),
                                )
                              ],
                            ),
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
        child: GestureDetector(
          onSecondaryTap: () {
            List<String> originalTags = List.from(d.tags);
            TextEditingController topicTEC = TextEditingController();
            TextEditingController hoursTEC = TextEditingController();
            TextEditingController minutesTEC = TextEditingController();
            TextEditingController secondsTEC = TextEditingController();

            topicTEC.text = d.topic;
            List<String> timePieces = d.timestampString.split(":");
            hoursTEC.text = timePieces[0];
            minutesTEC.text = timePieces[1];
            secondsTEC.text = timePieces[2];
            log(d.tags.toString());
            TagList tags = TagList(selectedTags: d.tags);

            showDialog<TimestampItem>(
                context: context,
                builder: (context) => ContentDialog(
                      title: const Center(
                        child: Text(
                          "Edit Timestamp",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      content: Wrap(children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                          child: TextBox(
                            controller: topicTEC,
                          ),
                        ),
                        Row(
                          children: [
                            const Text("  Timestamp:  "),
                            SizedBox(
                              width: 50,
                              child: TextBox(
                                maxLength: 2,
                                controller: hoursTEC,
                              ),
                            ),
                            const Text(":"),
                            SizedBox(
                              width: 50,
                              child: TextBox(
                                maxLength: 2,
                                controller: minutesTEC,
                              ),
                            ),
                            const Text(":"),
                            SizedBox(
                              width: 50,
                              child: TextBox(
                                maxLength: 2,
                                controller: secondsTEC,
                              ),
                            )
                          ],
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(color: Colors.grey[200]),
                                        BoxShadow(
                                            color: Colors.grey[160],
                                            spreadRadius: -6,
                                            blurRadius: 6)
                                      ]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: tags,
                                  )),
                            ),
                          ),
                        )
                      ]),
                      actions: [
                        Button(
                            onPressed: () {
                              int? hours = int.tryParse(hoursTEC.text);
                              int? minutes = int.tryParse(hoursTEC.text);
                              int? seconds = int.tryParse(hoursTEC.text);
                              if (hours != null &&
                                  minutes != null &&
                                  seconds != null) {
                                context.read<DataProvider>().updateTimestamp(
                                    d.videoId,
                                    d,
                                    TimestampData(
                                        tags.selectedTags,
                                        d.videoId,
                                        topicTEC.text,
                                        "${hoursTEC.text.padLeft(2, "0")}:${minutesTEC.text.padLeft(2, "0")}:${secondsTEC.text.padLeft(2, "0")}"));
                                context
                                    .read<PlaylistProvider>()
                                    .updateCurrentVideoData(context);
                                // log("List before reset: ${tags.selectedTags.toString()}");
                                // tags.selectedTags = List.from(originalTags);
                                // log("List after reset: ${tags.selectedTags.toString()}");
                                Navigator.pop(context);
                              } else {
                                showSnackbar(
                                    context,
                                    const Card(
                                        backgroundColor: Colors.black,
                                        child: Text(
                                          "Bad Timestamp",
                                          style: TextStyle(
                                              color:
                                                  Colors.warningPrimaryColor),
                                        )),
                                    alignment: Alignment.center);
                              }
                            },
                            child: const Text("Save")),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return ContentDialog(
                                      title: const Text(
                                        "Really delete timestamp?",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      actions: [
                                        Button(
                                          child: const Text("Confirm"),
                                          onPressed: () {
                                            context
                                                .read<DataProvider>()
                                                .deleteTimestamp(d);
                                            context
                                                .read<PlaylistProvider>()
                                                .updateCurrentVideoData(
                                                    context);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FilledButton(
                                            child: const Text("Cancel"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            })
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(FluentIcons.delete)),
                        FilledButton(
                            onPressed: () {
                              log("List before reset: ${tags.selectedTags.toString()}");
                              tags.selectedTags = List.from(originalTags);
                              log("List after reset: ${tags.selectedTags.toString()}");
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"))
                      ],
                    ));
          },
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
          ),
        ));
  }
}
