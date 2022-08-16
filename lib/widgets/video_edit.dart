import 'dart:developer';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';
import 'package:reference_library/widgets/tags_widget.dart';

class VideoEditDialog extends StatelessWidget {
  VideoEditDialog({Key? key, required this.d}) : super(key: key);
  VideoData d;
  TextEditingController topicTEC = TextEditingController();
  TextEditingController hoursTEC = TextEditingController();
  TextEditingController minutesTEC = TextEditingController();
  TextEditingController secondsTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width) * 0.65,
      title: const Center(
        child: Text(
          "Edit Video Information",
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
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: Container(),
                    ),
                  ),
                )),
          ),
        )
      ]),
      actions: [
        // Save updated timestamp button
        Button(
            onPressed: () {
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
                        "Really delete timestamp?",
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
