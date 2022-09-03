import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/editing_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';
import 'package:reference_library/widgets/series_edit.dart';
import '../providers/data_provider.dart';

// Widget to display a video thumbnail and title (library, playlist, search screens)
class SeriesCard extends StatefulWidget {
  const SeriesCard(this.seriesTitle, {Key? key}) : super(key: key);
  final String seriesTitle;
  @override
  // ignore: no_logic_in_create_state
  State<SeriesCard> createState() => _SeriesCardState(seriesTitle);
}

class _SeriesCardState extends State<SeriesCard> {
  _SeriesCardState(this.seriesTitle);
  String seriesTitle;
  Color backgroundcolor = ThemeData.dark().cardColor;
  bool thumbnailExists = false;
  String thumbnailPath = "";
  bool init = false;
  List<VideoData> seriesVideos = [];

  @override
  Widget build(BuildContext context) {
    // Initialize by getting the video data for all videos associated with the series
    if (!init) {
      Map<String, VideoData> allVideos = context.read<DataProvider>().videos;
      for (String vidID in allVideos.keys) {
        if (allVideos[vidID]!.series &&
            allVideos[vidID]!.seriesTitle == seriesTitle) {
          seriesVideos.add(allVideos[vidID]!);
        }
      }
      // Make sure it's sorted based on index
      seriesVideos.sort(((a, b) => a.seriesIndex.compareTo(b.seriesIndex)));
      // Grab the thumbnail of the first video to use
      if (!thumbnailExists && seriesVideos.isNotEmpty) {
        setState(() {
          thumbnailExists = File(seriesVideos.first.thumbnailPath).existsSync();
          thumbnailPath = seriesVideos.first.thumbnailPath;
        });
      }
      setState(() {
        init = true;
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
          message: seriesTitle,
          // GestureDetector to get left and right click events on the card itself
          child: GestureDetector(
              onSecondaryTap: () {
                // Right click to show series edit screen
                setState(() {
                  context.read<EditingProvider>().resetSeriesData();
                  context.read<EditingProvider>().setSeriesData({
                    "title": seriesTitle,
                    "videos": [...seriesVideos]
                  });
                  showDialog<bool>(
                      context: context,
                      builder: (context) => SeriesEditDialog(
                            origName: seriesTitle,
                            origVideos: seriesVideos,
                            title: "Edit Series Information",
                            newSeries: false,
                          )).then((value) {
                    if (value != null && value) {
                      context.read<NavigationProvider>().goToLibrary();
                      context.read<NavigationProvider>().refreshPage();
                      context.read<NavigationProvider>().goToSeries();
                      context.read<NavigationProvider>().refreshPage();
                    }
                  });

                  //         .then((value) {
                  //   if (value != null) {
                  //     data = value;
                  //     context.read<NavigationProvider>().refreshPage();
                  //   }
                  // });
                });
              },
              onTap: () {
                // Left click the card to queue series and play immediately
                for (VideoData v in seriesVideos) {
                  context.read<PlaylistProvider>().queueVideo(context, v);
                }
                // Make sure random mode is off since it's a series
                context.read<PlaylistProvider>().setRandomMode(false, context);
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
                            ? Image.file(File(thumbnailPath))
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
                                    seriesTitle,
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
                                      for (VideoData v in seriesVideos) {
                                        context
                                            .read<PlaylistProvider>()
                                            .queueVideo(context, v);
                                      }
                                      // Make sure random mode is off since it's a series
                                      context
                                          .read<PlaylistProvider>()
                                          .setRandomMode(false, context);
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
