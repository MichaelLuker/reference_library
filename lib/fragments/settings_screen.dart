import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';

// All the different settings, series, tags, add new videos, edit data on existing ones?
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return ScaffoldPage(
    //   header: Center(
    //       child: Container(
    //     color: Colors.blue,
    //     child: const Text(
    //       "Settings Screen Header",
    //       style: TextStyle(color: Colors.white),
    //     ),
    //   )),
    //   content: Center(
    //       child: Container(
    //     color: Colors.red,
    //     child: const Text(
    //       "Settings Screen Content",
    //       style: TextStyle(color: Colors.white),
    //     ),
    //   )),
    // );

    // UI for testing a custom localstore-like library
    return ScaffoldPage(
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: Column(
                children: [
                  const Text("Tags (create / delete)"),
                  TextButton(
                      child: const Text("Create"),
                      onPressed: () {
                        context.read<DataProvider>().addTag("Test New Tag");
                      }),
                  TextButton(
                      child: const Text("Delete"),
                      onPressed: () {
                        context.read<DataProvider>().deleteTag("Test New Tag");
                      }),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text("Series (CRUD)"),
                  TextButton(
                      child: const Text("Create"),
                      onPressed: () {
                        if (context
                            .read<DataProvider>()
                            .videos
                            .containsKey("test-new-video")) {
                          context.read<DataProvider>().createSeries(
                              "Test New Series With Video",
                              videoIds: ["test-new-video"]);
                        } else {
                          context
                              .read<DataProvider>()
                              .createSeries("Test New Series No Videos");
                        }
                      }),
                  //TextButton(child: const Text("Read"), onPressed: () {}),
                  TextButton(
                      child: const Text("Update"),
                      onPressed: () {
                        context.read<DataProvider>().updateSeries(
                            "Test New Series No Videos",
                            "Updated Series Title");
                      }),
                  TextButton(
                      child: const Text("Delete"),
                      onPressed: () {
                        context
                            .read<DataProvider>()
                            .deleteSeries("Test New Series No Videos");
                        context
                            .read<DataProvider>()
                            .deleteSeries("Updated Series Title");
                      }),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text("Video (CRUD)"),
                  TextButton(
                      child: const Text("Create"),
                      onPressed: () {
                        context.read<DataProvider>().createVideo(VideoData(
                                "new-test-video",
                                "New Test Video",
                                "blah",
                                false,
                                "",
                                0,
                                false,
                                "https://blah", [
                              TimestampData([], "new-test-video", "blah topic",
                                  "00:00:01")
                            ], []));
                      }),
                  //TextButton(child: const Text("Read"), onPressed: () {}),
                  TextButton(
                      child: const Text("Update"),
                      onPressed: () {
                        VideoData oldVid = VideoData(
                            "new-test-video",
                            "New Test Video",
                            "D:/Video Library/Math/Precalculus Course.mp4",
                            false,
                            "",
                            0,
                            false,
                            "https://blah", [
                          TimestampData(
                              [], "new-test-video", "blah topic", "00:00:01")
                        ], []);
                        VideoData newVid = oldVid.clone();

                        newVid.title = "Updated Title";
                        newVid.videoId = "updated-title";
                        context
                            .read<DataProvider>()
                            .updateVideo(oldVid, newVid);
                      }),
                  TextButton(
                      child: const Text("Delete"),
                      onPressed: () {
                        context
                            .read<DataProvider>()
                            .deleteVideo("new-test-video");
                        context
                            .read<DataProvider>()
                            .deleteVideo("updated-title");
                      }),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text("Timestamp (CRUD)"),
                  TextButton(
                      child: const Text("Create"),
                      onPressed: () {
                        context.read<DataProvider>().createTimestamp(
                            "2020_machine_learning_roadmap_(95_valid_for_2022)",
                            TimestampData([],
                                "2020_machine_learning_roadmap_(95_valid_for_2022)",
                                "Test Timestamp",
                                "00:00:00"));
                      }),
                  //TextButton(child: const Text("Read"), onPressed: () {}),
                  TextButton(
                      child: const Text("Update"),
                      onPressed: () {
                        TimestampData oldTs = TimestampData([],
                            "2020_machine_learning_roadmap_(95_valid_for_2022)",
                            "Test Timestamp",
                            "00:00:00");
                        TimestampData newTs = oldTs.clone();
                        newTs.topic = "Updated topic";
                        newTs.timestampString = "00:11:11";
                        newTs.timestamp =
                            const Duration(hours: 0, minutes: 11, seconds: 11);
                        context.read<DataProvider>().updateTimestamp(
                            "2020_machine_learning_roadmap_(95_valid_for_2022)",
                            0,
                            newTs);
                      }),

                  TextButton(
                      child: const Text("Delete"),
                      onPressed: () {
                        context.read<DataProvider>().deleteTimestamp(
                            "2020_machine_learning_roadmap_(95_valid_for_2022)",
                            0);
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
