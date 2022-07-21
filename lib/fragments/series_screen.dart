// Screen to show the different 'series' or related videos, like the FPGA or Basic Electronics series of videos
// essentially youtube playlists... :) I suppose here is where the complete info could be useful..
//  click in to a series and then the video cards of complete videos will be green or something
// maybe have a gridview of the series, then use the drill in page transition to get to get to the video list for that series?
// https://github.com/bdlukaa/fluent_ui#page-transitions ?? Drill In

// Here's an example from main of using the navigationbody and transitionBuilder to customize the transition between navigation panes for the main app
// content: NavigationBody(
//     animationDuration: const Duration(milliseconds: 450),
//     transitionBuilder: (Widget c, Animation<double> a) =>
//         EntrancePageTransition(
//           animation: a,
//           vertical: false,
//           reverse: true,
//           startFrom: 0.15,
//           child: c,
//         ),

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

// All the different settings, series, tags, add new videos, edit data on existing ones?
class SeriesScreen extends StatelessWidget {
  const SeriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Center(
          child: Container(
        color: Colors.blue,
        child: const Text(
          "Series Screen Header",
          style: TextStyle(color: Colors.white),
        ),
      )),
      content: Center(
          child: Container(
        color: Colors.red,
        child: const Text(
          "Series Screen Content",
          style: TextStyle(color: Colors.white),
        ),
      )),
    );
  }
}
