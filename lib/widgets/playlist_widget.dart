import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';

// ignore: must_be_immutable
class PlayListWidget extends StatefulWidget {
  PlayListWidget({Key? key}) : super(key: key);

  @override
  State<PlayListWidget> createState() => _PlayListWidgetState();
  Map<String, Widget> playlistItems = {};
  Map<String, Color> backgroundColors = {};
}

class _PlayListWidgetState extends State<PlayListWidget> {
  List<Widget> buildPlaylist(BuildContext context, List<VideoData> pl) {
    setState(() {
      VideoData current = context.read<PlaylistProvider>().currentVideo!;

      for (VideoData d in pl) {
        if (!widget.backgroundColors.containsKey(d.videoId)) {
          if (d == current) {
            widget.backgroundColors[d.videoId] =
                const Color.fromARGB(255, 40, 109, 228);
          } else {
            widget.backgroundColors[d.videoId] = ThemeData.dark().cardColor;
          }
        }

        widget.playlistItems.remove(d.videoId);
        widget.playlistItems[d.videoId] = MouseRegion(
          key: Key(d.videoId),
          onEnter: (_) {
            setState(() {
              if (d == current) {
                widget.backgroundColors[d.videoId] =
                    const Color.fromARGB(255, 84, 145, 250);
              } else {
                widget.backgroundColors[d.videoId] =
                    ThemeData.dark().shadowColor;
              }
            });
          },
          onExit: (_) {
            setState(() {
              if (d == current) {
                widget.backgroundColors[d.videoId] =
                    const Color.fromARGB(255, 40, 109, 228);
              } else {
                widget.backgroundColors[d.videoId] = ThemeData.dark().cardColor;
              }
            });
          },
          child: GestureDetector(
            onTap: () {
              widget.backgroundColors[context
                  .read<PlaylistProvider>()
                  .currentVideo!
                  .videoId] = ThemeData.dark().cardColor;
              widget.backgroundColors[d.videoId] =
                  const Color.fromARGB(255, 40, 109, 228);
              context.read<PlaylistProvider>().jumpToVideo(context, d);
              context.read<NavigationProvider>().goToPlayback(context: context);
            },
            child: PlaylistItem(
              d,
              widget.backgroundColors[d.videoId]!,
              //  false,
            ),
          ),
        );
      }
    });

    return widget.playlistItems.values.toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<VideoData> pl = context.watch<PlaylistProvider>().playList;
    return Column(
      children: [
        Center(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Playlist",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: IconButton(
                    onPressed: () {
                      context.read<PlaylistProvider>().clearPlaylist();
                      context.read<NavigationProvider>().goToLibrary();
                    },
                    icon: const Icon(FluentIcons.delete)),
              )
            ],
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          controller: ScrollController(),
          child: ReorderableListView(
            shrinkWrap: true,
            onReorder: (oldPos, newPos) {
              if (newPos > oldPos) {
                newPos--;
              }
              context.read<PlaylistProvider>().moveItem(oldPos, newPos);
            },
            children: buildPlaylist(context, pl),
          ),
        ))
      ],
    );
  }
}

class PlaylistItem extends StatelessWidget {
  const PlaylistItem(this.d, this.backgroundColor, {Key? key})
      : super(key: key);
  final VideoData d;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: d.title,
      child: ListTile(
        tileColor: backgroundColor,
        contentPadding: EdgeInsets.zero,
        shape: const Border.symmetric(horizontal: BorderSide()),
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
          child: IconButton(
              onPressed: () {
                context.read<PlaylistProvider>().dequeueVideo(context, d);
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
      ),
    );
  }
}
