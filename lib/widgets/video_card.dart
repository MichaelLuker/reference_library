import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/editing_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';
import 'package:reference_library/widgets/video_edit.dart';
import '../providers/data_provider.dart';

// Widget to display a video thumbnail and title (library, playlist, search screens)
class VideoCard extends StatefulWidget {
  const VideoCard(this.data, {Key? key}) : super(key: key);
  final VideoData data;
  @override
  // ignore: no_logic_in_create_state
  State<VideoCard> createState() => _VideoCardState(data);
}

class _VideoCardState extends State<VideoCard> {
  _VideoCardState(this.data);
  VideoData data;
  Color backgroundcolor = ThemeData.dark().cardColor;
  bool thumbnailExists = false;

  @override
  Widget build(BuildContext context) {
    // If the thumbnail is marked as non-existant do another check here
    // if it DOES exist we don't need to be doing the check on every build
    if (!thumbnailExists) {
      setState(() {
        thumbnailExists = File(data.thumbnailPath).existsSync();
      });
    }
    // Mouse region to detect if the cursor is entering or leaving the card to highlight it
    return MouseRegion(
        onEnter: (_) {
          setState(() {
            backgroundcolor = ThemeData.dark().shadowColor;
          });
        },
        onExit: (_) {
          setState(() {
            backgroundcolor = ThemeData.dark().cardColor;
          });
        },
        // Tooltip to show full video titles, some are long and get cut off
        child: Tooltip(
          displayHorizontally: false,
          useMousePosition: false,
          style: const TooltipThemeData(
              preferBelow: true,
              verticalOffset: 25,
              showDuration: Duration(milliseconds: 500),
              waitDuration: Duration(milliseconds: 500)),
          message: data.title,
          // GestureDetector to get left and right click events on the card itself
          child: GestureDetector(
              onSecondaryTap: () {
                // Right click to show video edit screen
                setState(() {
                  context.read<EditingProvider>().setVideoData(data);
                  context
                      .read<EditingProvider>()
                      .setTimestamps(data.timestamps);
                  context.read<EditingProvider>().setTags(data.tags);
                  showDialog<VideoData>(
                      context: context,
                      builder: (context) => VideoEditDialog(
                            title: "Edit Video Information",
                            d: data,
                            newVideo: false,
                          )).then((value) {
                    if (value != null) {
                      data = value;
                      context.read<NavigationProvider>().refreshPage();
                    }
                  });
                });
              },
              onTap: () {
                // Left click the card to play the video immediately
                context.read<PlaylistProvider>().queueVideo(context, data);
                context
                    .read<NavigationProvider>()
                    .goToPlayback(context: context, autoStart: true);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                // fluent Card is the main visual base
                child: Card(
                    backgroundColor: backgroundcolor,
                    child: Column(
                      children: [
                        // Thumbnail at the top
                        thumbnailExists
                            ? Image.file(File(data.thumbnailPath))
                            : const Text("Thumbnail Pending"),
                        // Then the title and add to playlist button below that
                        Flexible(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 9,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                  child: Text(
                                    data.title,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        overflow: TextOverflow.fade),
                                  ),
                                ),
                              ),
                              // Button to add to playlist, clicking this will add
                              //   the video to the playlist but not navigate to
                              //   the playback screen and autoplay, basically lets
                              //   you manually queue up videos
                              Flexible(
                                flex: 2,
                                child: Center(
                                  child: IconButton(
                                    iconButtonMode: IconButtonMode.large,
                                    icon: const Icon(
                                        FluentIcons.add_to_shopping_list,
                                        size: 18),
                                    onPressed: () {
                                      context
                                          .read<PlaylistProvider>()
                                          .queueVideo(context, data);

                                      // Once it's on the playlist there should be some kind of
                                      //   visual indicator that it happened, either a toast or
                                      //   Maybe adding the playlist to the library view??
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )),
              )),
        ));
  }
}
