import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/fragments/play_screen.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';
import 'package:reference_library/providers/settings_provider.dart';
import 'package:reference_library/widgets/tags_widget.dart';
import 'package:reference_library/widgets/video_series_edit_widget.dart';

class VideoEditDialog extends StatelessWidget {
  VideoEditDialog({Key? key, required this.title, required this.d})
      : super(key: key);
  String title;
  VideoData d;
  TextEditingController titleTEC = TextEditingController();
  TextEditingController urlTEC = TextEditingController();
  TextEditingController thumbnailPathTEC = TextEditingController();
  TextEditingController localPathTEC = TextEditingController();
  bool isSeries = false;
  List<TimestampData> videoTimestamps = [];
  List<String> selectedTags = [];

  void updatePathTEC(BuildContext context, TextEditingController tec,
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
    titleTEC.text = d.title;
    urlTEC.text = d.url;
    localPathTEC.text =
        "${context.read<SettingsProvider>().videoFolder.path}/${d.localPath}";
    thumbnailPathTEC.text = d.thumbnailPath;
    isSeries = d.series;
    VideoSeriesData vsd =
        VideoSeriesData(d.series, d.seriesTitle, d.seriesIndex);
    VideoSeriesEditWidget videoSeriesEditWidget = VideoSeriesEditWidget(
      seriesData: vsd,
    );
    selectedTags = [...d.tags];
    videoTimestamps = [...d.timestamps];

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
              outsidePrefix: const Text("Title:  "),
              controller: titleTEC,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: TextBox(
              outsidePrefix: const Text("URL:  "),
              controller: urlTEC,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: TextBox(
              outsidePrefix: const Text("Path:  "),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: TextBox(
              outsidePrefix: const Text("Thumb:  "),
              onTap: () {
                updatePathTEC(
                    context,
                    thumbnailPathTEC,
                    context.read<SettingsProvider>().thumbFolder.path,
                    "Select Thumbnail",
                    FileType.image);
              },
              prefix: IconButton(
                  icon: const Icon(FluentIcons.open_folder_horizontal),
                  onPressed: () {
                    updatePathTEC(
                        context,
                        thumbnailPathTEC,
                        context.read<SettingsProvider>().thumbFolder.path,
                        "Select Thumbnail",
                        FileType.image);
                  }),
              readOnly: true,
              controller: thumbnailPathTEC,
            ),
          ),
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
                        icon: const Icon(FluentIcons.circle_plus),
                        onPressed: () {
                          // Show dialog to add a new timestamp to the video
                          log("New Timestamp Button");
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
                              child: ListView(
                                controller: ScrollController(),
                                children:
                                    buildTimestamps(context, videoTimestamps),
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
                          log("New Tags Button");
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
                              child: TagList(selectedTags: selectedTags),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),

          // Center(
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
          //     child: Container(
          //         decoration: BoxDecoration(
          //             borderRadius: const BorderRadius.all(Radius.circular(10)),
          //             boxShadow: [
          //               BoxShadow(color: Colors.grey[200]),
          //               BoxShadow(
          //                   color: Colors.grey[160],
          //                   spreadRadius: -6,
          //                   blurRadius: 6)
          //             ]),
          //         child: SizedBox(
          //           height: MediaQuery.of(context).size.height * 0.55,
          //           child: Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: SingleChildScrollView(
          //               controller: ScrollController(),
          //               child: Container(),
          //             ),
          //           ),
          //         )),
          //   ),
          // )
        ]),
      ),
      actions: [
        // Save updated timestamp button
        Button(
            onPressed: () {
              // log("Going to save video data as follow:");
              // log("Title: ${titleTEC.text}");
              // log("URL: ${urlTEC.text}");
              // log("Path: ${localPathTEC.text}");
              // log("Thumbnail: ${thumbnailPathTEC.text}");
              // log("SeriesData: ${videoSeriesEditWidget.seriesData.toString()}");
              // log("Timestamps: \n${d.timestamps.toString()}");
              // log("SelectedTags: ${selectedTags.toString()}");

              String trimmedVideoPath = localPathTEC.text.replaceAll(
                  RegExp(context.read<SettingsProvider>().videoFolder.path),
                  "");

              VideoData newData = VideoData(
                  titleTEC.text.toLowerCase().replaceAll(' ', '_'),
                  titleTEC.text,
                  trimmedVideoPath,
                  videoSeriesEditWidget.seriesData.isSeries,
                  videoSeriesEditWidget.seriesData.seriesName,
                  videoSeriesEditWidget.seriesData.seriesPosition,
                  false,
                  urlTEC.text,
                  videoTimestamps,
                  selectedTags,
                  context.read<SettingsProvider>().thumbFolder.path,
                  thumbnailPath: thumbnailPathTEC.text);

              context.read<DataProvider>().updateVideo(d, newData);

              Future.delayed(const Duration(milliseconds: 50)).then((value) {
                Navigator.pop(context, newData);
              });
              // int? hours = int.tryParse(hoursTEC.text);
              // int? minutes = int.tryParse(hoursTEC.text);
              // int? seconds = int.tryParse(hoursTEC.text);
              // if (hours != null && minutes != null && seconds != null) {
              //   context.read<DataProvider>().updateTimestamp(
              //       d.videoId,
              //       d,
              //       TimestampData(tags.selectedTags, d.videoId, topicTEC.text,
              //           "${hoursTEC.text.padLeft(2, "0")}:${minutesTEC.text.padLeft(2, "0")}:${secondsTEC.text.padLeft(2, "0")}"));
              //   context
              //       .read<PlaylistProvider>()
              //       .updateCurrentVideoData(context);
              //   Navigator.pop(context);
              // } else {
              //   showSnackbar(
              //       context,
              //       const Card(
              //           backgroundColor: Colors.black,
              //           child: Text(
              //             "Bad Timestamp",
              //             style: TextStyle(color: Colors.warningPrimaryColor),
              //           )),
              //       alignment: Alignment.center);
              // }
            },
            child: const Text("Save")),
        // Delete timestamp button
        IconButton(
            onPressed: () {
              showDialog(
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
                            // context.read<DataProvider>().deleteTimestamp(d);
                            // context
                            //     .read<PlaylistProvider>()
                            //     .updateCurrentVideoData(context);
                            // Navigator.pop(context);
                            // Navigator.pop(context);
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
