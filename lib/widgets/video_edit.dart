import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/fragments/play_screen.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/editing_provider.dart';
import 'package:reference_library/providers/settings_provider.dart';
import 'package:reference_library/widgets/tags_widget.dart';
import 'package:reference_library/widgets/video_series_edit_widget.dart';

// ignore: must_be_immutable
class VideoEditDialog extends StatelessWidget {
  VideoEditDialog(
      {Key? key, required this.title, required this.d, required this.newVideo})
      : super(key: key);
  String title;
  VideoData d;
  TextEditingController titleTEC = TextEditingController();
  TextEditingController urlTEC = TextEditingController();
  TextEditingController thumbnailPathTEC = TextEditingController();
  TextEditingController localPathTEC = TextEditingController();
  bool isSeries = false;
  bool newVideo;

  Future<void> updatePathTEC(BuildContext context, TextEditingController tec,
      String initial, String title, FileType type) async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      dialogTitle: title,
      //initialDirectory: context.read<SettingsProvider>().videoFolder.path,
      initialDirectory: initial,
      type: type,
    );
    if (res != null && res.files.isNotEmpty) {
      tec.text = res.files[0].path!;
    }
  }

  void updateSeriesData(bool v) {
    isSeries = v;
  }

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
    titleTEC.text = context.read<EditingProvider>().videoData!.title;
    urlTEC.text = context.read<EditingProvider>().videoData!.url;
    localPathTEC.text =
        "${context.read<SettingsProvider>().videoFolder.path}/${context.read<EditingProvider>().videoData!.localPath}";
    thumbnailPathTEC.text =
        context.read<EditingProvider>().videoData!.thumbnailPath;
    isSeries = d.series;
    VideoSeriesData vsd =
        VideoSeriesData(d.series, d.seriesTitle, d.seriesIndex);
    VideoSeriesEditWidget videoSeriesEditWidget = VideoSeriesEditWidget(
      seriesData: vsd,
    );

    VideoData v = context.watch<EditingProvider>().videoData!;
    return ContentDialog(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width) * 0.85,
      title: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Wrap(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: TextBox(
              outsidePrefix: const Text("Title:      "),
              controller: titleTEC,
              onChanged: (value) {
                context.read<EditingProvider>().videoData!.title = value;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: TextBox(
              outsidePrefix: const Text("URL:      "),
              controller: urlTEC,
              onChanged: (value) {
                context.read<EditingProvider>().videoData!.url = value;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: TextBox(
              outsidePrefix: const Text("Path:      "),
              onTap: () {
                updatePathTEC(
                    context,
                    localPathTEC,
                    context.read<SettingsProvider>().videoFolder.path,
                    "Select Video File",
                    FileType.video);
              },
              prefix: IconButton(
                  icon: const Icon(FluentIcons.open_folder_horizontal),
                  onPressed: () {
                    updatePathTEC(
                        context,
                        localPathTEC,
                        context.read<SettingsProvider>().videoFolder.path,
                        "Select Video File",
                        FileType.video);
                  }),
              readOnly: true,
              controller: localPathTEC,
            ),
          ),
          // Thumbnail
          Visibility(
            visible: !newVideo,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: TextBox(
                outsidePrefix: const Text("Thumb:  "),
                onTap: () async {
                  await updatePathTEC(
                      context,
                      thumbnailPathTEC,
                      context.read<SettingsProvider>().thumbFolder.path,
                      "Select Thumbnail",
                      FileType.image);
                  VideoData c = d.clone();
                  c.thumbnailPath = thumbnailPathTEC.text;
                  context.read<EditingProvider>().setVideoData(c);
                },
                prefix: IconButton(
                    icon: const Icon(FluentIcons.open_folder_horizontal),
                    onPressed: () async {
                      await updatePathTEC(
                          context,
                          thumbnailPathTEC,
                          context.read<SettingsProvider>().thumbFolder.path,
                          "Select Thumbnail",
                          FileType.image);
                      VideoData c = d.clone();
                      c.thumbnailPath = thumbnailPathTEC.text;
                      context.read<EditingProvider>().setVideoData(c);
                    }),
                readOnly: true,
                controller: thumbnailPathTEC,
              ),
            ),
          ),
          // Thumbnail Preview
          Visibility(
              visible: !newVideo,
              child: Center(
                child: SizedBox(
                    width: 200, child: Image.file(File(v.thumbnailPath))),
              )),
          // Any possible series settings
          videoSeriesEditWidget,
          // Video tags

          // Tags and Timestamps
          Row(
            children: [
              // Timestamps
              Column(
                children: [
                  Row(
                    children: [
                      const Text("Timestamps:"),
                      IconButton(
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
                            List<String> timePieces = ["00", "00", "00"];
                            hoursTEC.text = timePieces[0];
                            minutesTEC.text = timePieces[1];
                            secondsTEC.text = timePieces[2];

                            // ignore: prefer_const_literals_to_create_immutables
                            TagList tags = TagList(
                              selectedTags: [],
                              editing: false,
                            );

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
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 16),
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
                                                // Make it so only numbers are allowed
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp("[0-9]"))
                                                ],
                                                controller: hoursTEC,
                                              ),
                                            ),
                                            const Text(":"),
                                            SizedBox(
                                              width: 50,
                                              child: TextBox(
                                                maxLength: 2,
                                                // Make it so only numbers are allowed
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp("[0-9]"))
                                                ],
                                                controller: minutesTEC,
                                              ),
                                            ),
                                            const Text(":"),
                                            SizedBox(
                                              width: 50,
                                              child: TextBox(
                                                maxLength: 2,
                                                // Make it so only numbers are allowed
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp("[0-9]"))
                                                ],
                                                controller: secondsTEC,
                                              ),
                                            )
                                          ],
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 18, 0, 0),
                                            child: SizedBox(
                                              width: 300,
                                              height: 300,
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  10)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors
                                                                .grey[200]),
                                                        BoxShadow(
                                                            color: Colors
                                                                .grey[160],
                                                            spreadRadius: -6,
                                                            blurRadius: 6)
                                                      ]),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
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
                                                  int.tryParse(hoursTEC.text);
                                              int? minutes =
                                                  int.tryParse(hoursTEC.text);
                                              int? seconds =
                                                  int.tryParse(hoursTEC.text);
                                              if (hours != null &&
                                                  minutes != null &&
                                                  seconds != null) {
                                                TimestampData newTS = TimestampData(
                                                    tags.selectedTags,
                                                    titleTEC.text
                                                        .toLowerCase()
                                                        .replaceAll(' ', '_'),
                                                    topicTEC.text,
                                                    "${hoursTEC.text.padLeft(2, "0")}:${minutesTEC.text.padLeft(2, "0")}:${secondsTEC.text.padLeft(2, "0")}");
                                                context
                                                    .read<EditingProvider>()
                                                    .addTimestamp(newTS);
                                                context
                                                    .read<DataProvider>()
                                                    .createTimestamp(
                                                        titleTEC.text
                                                            .toLowerCase()
                                                            .replaceAll(
                                                                ' ', '_'),
                                                        newTS);

                                                ;

                                                Navigator.pop(context);
                                              } else {
                                                showSnackbar(
                                                    context,
                                                    const Card(
                                                        backgroundColor:
                                                            Colors.black,
                                                        child: Text(
                                                          "Bad Timestamp",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .warningPrimaryColor),
                                                        )),
                                                    alignment:
                                                        Alignment.center);
                                              }
                                            },
                                            child: const Text("Save")),
                                        FilledButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Cancel"))
                                      ],
                                    ));
                          },
                          icon: const Icon(FluentIcons.circle_addition)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(color: Colors.grey[200]),
                              BoxShadow(
                                  color: Colors.grey[160],
                                  spreadRadius: -6,
                                  blurRadius: 6)
                            ]),
                        child: SizedBox(
                          width:
                              MediaQuery.of(context).size.width * .85 / 2 - 37,
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView(
                                controller: ScrollController(),
                                children: buildTimestamps(
                                    context,
                                    context
                                        .watch<EditingProvider>()
                                        .timestamps!),
                              )),
                        )),
                  ),
                ],
              ),

              // Tags
              Column(
                children: [
                  Row(
                    children: [
                      const Text("Tags:"),
                      IconButton(
                        icon: const Icon(FluentIcons.circle_plus),
                        onPressed: () {
                          // Show dialog to add a new tags to the list
                          TextEditingController newTagTEC =
                              TextEditingController();
                          showDialog<String>(
                              context: context,
                              builder: (context) => ContentDialog(
                                    title: const Text("Add Tag"),
                                    content: TextBox(
                                      controller: newTagTEC,
                                    ),
                                    actions: [
                                      Button(
                                          onPressed: () {
                                            context
                                                .read<EditingProvider>()
                                                .addTag(newTagTEC.text);
                                            context
                                                .read<DataProvider>()
                                                .addTag(newTagTEC.text);

                                            Navigator.pop(context);
                                          },
                                          child: const Text("Save")),
                                      FilledButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Cancel"))
                                    ],
                                  ));
                        },
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(color: Colors.grey[200]),
                              BoxShadow(
                                  color: Colors.grey[160],
                                  spreadRadius: -6,
                                  blurRadius: 6)
                            ]),
                        child: SizedBox(
                          width:
                              MediaQuery.of(context).size.width * .85 / 2 - 37,
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              controller: ScrollController(),
                              child: TagList(
                                  editing: true,
                                  selectedTags:
                                      context.watch<EditingProvider>().tags!),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
      actions: [
        // Save updated timestamp button
        Button(
            onPressed: () {
              // If the videoID has been changed, update all the timestamps too
              if (d.title != titleTEC.text) {
                context.read<EditingProvider>().timestamps!.forEach((element) =>
                    element.videoId = titleTEC.text
                        .toLowerCase()
                        .replaceAll(' ', '_')
                        .replaceAll(RegExp("[^A-Za-z0-9_]"), "")
                        .replaceAll(RegExp("[^A-Za-z0-9_]"), ""));
              }

              String trimmedVideoPath = localPathTEC.text.replaceAll(
                  RegExp(
                      context.read<SettingsProvider>().videoFolder.path + "/"),
                  "");

              VideoData newData = VideoData(
                  titleTEC.text
                      .toLowerCase()
                      .replaceAll(' ', '_')
                      .replaceAll(RegExp("[^A-Za-z0-9_]"), ""),
                  titleTEC.text,
                  trimmedVideoPath,
                  videoSeriesEditWidget.seriesData.isSeries,
                  videoSeriesEditWidget.seriesData.seriesName,
                  videoSeriesEditWidget.seriesData.seriesPosition,
                  false,
                  urlTEC.text,
                  context.read<EditingProvider>().timestamps!,
                  context.read<EditingProvider>().tags!,
                  context.read<SettingsProvider>().thumbFolder.path,
                  thumbnailPath: thumbnailPathTEC.text);

              context.read<DataProvider>().updateVideo(d, newData);

              Future.delayed(const Duration(milliseconds: 50)).then((value) {
                Navigator.pop(context, newData);
              });
            },
            child: const Text("Save")),
        // Delete timestamp button
        Visibility(
          visible: !newVideo,
          child: IconButton(
              onPressed: () {
                showDialog<bool>(
                    context: context,
                    builder: (_) {
                      return ContentDialog(
                        title: const Text(
                          "Really delete video?",
                          style: TextStyle(fontSize: 16),
                        ),
                        actions: [
                          Button(
                            child: const Text("Confirm"),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                          ),
                          FilledButton(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.pop(context, false);
                              })
                        ],
                      );
                    }).then((value) {
                  if (value != null && value) {
                    // Delete associated files
                    context.read<DataProvider>().deleteVideo(d.videoId);

                    // Return a blank videodata file so it sees there was a change and needs to refresh
                    VideoData newData = VideoData(
                        "", "", "", false, "", -1, false, "", [], [], "");
                    Future.delayed(const Duration(milliseconds: 50))
                        .then((value) {
                      Navigator.pop(context, newData);
                    });
                  }
                });
              },
              icon: const Icon(FluentIcons.delete)),
        ),
        // Cancel Button
        FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"))
      ],
    );
  }
}
