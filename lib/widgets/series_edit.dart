import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/editing_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/widgets/playlist_widget.dart';

class SeriesEditDialog extends StatelessWidget {
  SeriesEditDialog(
      {Key? key,
      required this.title,
      required this.newSeries,
      required this.origName,
      required this.origVideos})
      : super(key: key);

  String title;
  bool newSeries;
  String origName;
  List<VideoData> origVideos;
  TextEditingController titleTEC = TextEditingController();
  late List<VideoData> seriesVideos;

  List<Widget> buildVideoList(BuildContext context) {
    List<Widget> r = [];
    for (VideoData d in seriesVideos) {
      r.add(ListTile(
        key: Key(d.videoId),
        tileColor: ThemeData.dark().cardColor,
        contentPadding: EdgeInsets.zero,
        shape: const Border.symmetric(horizontal: BorderSide()),
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
          child: IconButton(
              onPressed: () {
                context.read<EditingProvider>().removeSeriesVideo(d);
              },
              icon: const Icon(
                FluentIcons.clear,
                size: 8,
              )),
        ),
        title: Text(
          d.title,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const SizedBox(
          width: 30,
        ),
      ));
    }
    return r;
  }

  @override
  Widget build(BuildContext context) {
    titleTEC.text = context.watch<EditingProvider>().seriesData!["title"];
    seriesVideos = context.watch<EditingProvider>().seriesData!["videos"];
    return ContentDialog(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width) * 0.45,
      title: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: TextBox(
                outsidePrefix: const Text("Title:      "),
                controller: titleTEC,
                onChanged: (value) {
                  context.read<EditingProvider>().seriesData!["title"] = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(color: Colors.grey[200]),
                        BoxShadow(
                            color: Colors.grey[160],
                            spreadRadius: -6,
                            blurRadius: 6)
                      ]),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .85 / 2,
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        controller: ScrollController(),
                        child: Column(
                          children: [
                            ReorderableListView(
                              shrinkWrap: true,
                              onReorder: (oldPos, newPos) {
                                if (newPos > oldPos) {
                                  newPos--;
                                }
                                context
                                    .read<EditingProvider>()
                                    .moveSeriesVideo(oldPos, newPos);
                              },
                              children: buildVideoList(context),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                              child: IconButton(
                                onPressed: () {
                                  // Show dialog of videos that are not part of a series
                                  showDialog<VideoData>(
                                      context: context,
                                      builder: (context) => ContentDialog(
                                            constraints: BoxConstraints(
                                                    maxHeight:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width) *
                                                0.45,
                                            title: const Text("Select Video"),
                                            content: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color:
                                                              Colors.grey[200]),
                                                      BoxShadow(
                                                          color:
                                                              Colors.grey[160],
                                                          spreadRadius: -6,
                                                          blurRadius: 6)
                                                    ]),
                                                child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .85 /
                                                            2,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.35,
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child:
                                                            SingleChildScrollView(
                                                                controller:
                                                                    ScrollController(),
                                                                child: Column(
                                                                    children: [
                                                                      ListView(
                                                                        shrinkWrap:
                                                                            true,
                                                                        children: context
                                                                            .read<DataProvider>()
                                                                            .videos
                                                                            .values
                                                                            .map((e) {
                                                                          if (!e.series &&
                                                                              !seriesVideos.contains(e)) {
                                                                            return AddSeriesVideoTile(
                                                                              d: e,
                                                                            );
                                                                          }
                                                                          return Visibility(
                                                                              visible: false,
                                                                              child: Container());
                                                                        }).toList(),
                                                                      )
                                                                    ]))))),
                                            actions: [
                                              FilledButton(
                                                  child: const Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  })
                                            ],
                                          )).then((value) {
                                    if (value != null) {
                                      log("Going to add ${value.title} to the series");
                                      context
                                          .read<EditingProvider>()
                                          .addSeriesVideo(value);
                                    }
                                  });
                                },
                                icon: const Icon(FluentIcons.circle_addition),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
      actions: [
        // Save updated timestamp button
        Button(
            onPressed: () {
              // Go and update all the associated video files with the series info, and the series? if the title changed
              if (titleTEC.text != origName) {
                for (VideoData d in seriesVideos) {
                  d.seriesTitle = titleTEC.text;
                }
              }

              // Make sure the series title is updated, if it changed update all of the associated videos
              if (newSeries) {
                context.read<DataProvider>().createSeries(titleTEC.text);
              } else {
                context
                    .read<DataProvider>()
                    .updateSeries(origName, titleTEC.text);
              }

              // For each video, make sure that it's marked as part of a series, the title, and then its position in the list
              int i = 1;
              for (VideoData d in seriesVideos) {
                VideoData old = d.clone();
                d.series = true;
                d.seriesTitle = titleTEC.text;
                d.seriesIndex = i;
                i++;
                context.read<DataProvider>().updateVideo(old, d);
              }

              // For any videos that were removed, go scrub series info from them
              for (VideoData d in origVideos) {
                if (seriesVideos.contains(d)) {
                  continue;
                } else {
                  VideoData old = d.clone();
                  d.series = false;
                  d.seriesTitle = "";
                  d.seriesIndex = -1;
                  context.read<DataProvider>().updateVideo(old, d);
                }
              }
              Future.delayed(const Duration(milliseconds: 150))
                  .then((value) => context.read<DataProvider>().reloadData());
              Navigator.pop(context, true);
            },
            child: const Text("Save")),
        // Delete series button
        Visibility(
          visible: !newSeries,
          child: IconButton(
              onPressed: () {
                showDialog<bool>(
                    context: context,
                    builder: (_) {
                      return ContentDialog(
                        title: const Text(
                          "Really delete series?",
                          style: TextStyle(fontSize: 16),
                        ),
                        actions: [
                          Button(
                            child: const Text("Confirm"),
                            onPressed: () {
                              // For all the videos in the list set them as not part of the series
                              for (VideoData d in seriesVideos) {
                                VideoData old = d.clone();
                                d.series = false;
                                d.seriesTitle = "";
                                d.seriesIndex = -1;
                                context
                                    .read<DataProvider>()
                                    .updateVideo(old, d);
                              }
                              Future.delayed(const Duration(milliseconds: 150))
                                  .then((value) => context
                                      .read<DataProvider>()
                                      .reloadData());
                              context
                                  .read<DataProvider>()
                                  .deleteSeries(titleTEC.text);
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
                    // Update all associated videos
                    Future.delayed(const Duration(milliseconds: 50))
                        .then((value) {
                      Navigator.pop(context, false);
                      context.read<NavigationProvider>().refreshPage();
                    });
                  }
                });
              },
              icon: const Icon(FluentIcons.delete)),
        ),
        // Cancel Button
        FilledButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancel"))
      ],
    );
  }
}

class AddSeriesVideoTile extends StatefulWidget {
  const AddSeriesVideoTile({Key? key, required this.d}) : super(key: key);
  final VideoData d;
  @override
  State<AddSeriesVideoTile> createState() => _AddSeriesVideoTileState();
}

class _AddSeriesVideoTileState extends State<AddSeriesVideoTile> {
  Color backgroundColor = ThemeData.dark().cardColor;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          backgroundColor = ThemeData.dark().shadowColor;
        });
      },
      onExit: (_) {
        setState(() {
          backgroundColor = ThemeData.dark().cardColor;
        });
      },
      child: GestureDetector(
          onTap: () {
            // If the video is clicked, pop the dialog and return its data to the series edit dialog to add
            Navigator.pop(context, widget.d);
          },
          child: Tooltip(
            message: widget.d.title,
            child: ListTile(
              tileColor: backgroundColor,
              contentPadding: EdgeInsets.zero,
              shape: const Border.symmetric(horizontal: BorderSide()),
              title: Text(
                widget.d.title,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const SizedBox(
                width: 30,
              ),
            ),
          )),
    );
  }
}
