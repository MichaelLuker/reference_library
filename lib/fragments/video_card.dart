import 'dart:developer';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/fragments/play_screen.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';
import 'package:youtube/youtube_thumbnail.dart';

import '../providers/data_provider.dart';

// Widget to display a video thumbnail and title (library, playlist, search screens)
class VideoCard extends StatefulWidget {
  VideoCard(this.data, {Key? key}) : super(key: key);
  VideoData data;
  @override
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
        child: Tooltip(
          displayHorizontally: false,
          useMousePosition: false,
          style: const TooltipThemeData(
              preferBelow: true,
              verticalOffset: 25,
              showDuration: Duration(milliseconds: 500),
              waitDuration: Duration(milliseconds: 500)),
          message: data.title,
          child: GestureDetector(
              onTap: () {
                log("Card press");
                context.read<PlaylistProvider>().queueVideo(data);
                context
                    .read<NavigationProvider>()
                    .goToPlayback(context: context, autoStart: true);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    //Card(backgroundColor: backgroundcolor, child: Text(data.title)),
                    Card(
                        backgroundColor: backgroundcolor,
                        child: Column(
                          children: [
                            // Thumbnail at the top
                            thumbnailExists
                                ? Image.file(File(data.thumbnailPath))
                                : Text("Thumbnail Pending"),
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
                                  Flexible(
                                    flex: 2,
                                    child: Center(
                                      child: IconButton(
                                        iconButtonMode: IconButtonMode.large,
                                        icon: const Icon(
                                            FluentIcons.add_to_shopping_list,
                                            size: 18),
                                        onPressed: () {
                                          log("Button Press");
                                          context
                                              .read<PlaylistProvider>()
                                              .queueVideo(data);
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
