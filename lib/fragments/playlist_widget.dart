import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';

class PlayListWidget extends StatelessWidget {
  const PlayListWidget({Key? key}) : super(key: key);

  List<Widget> buildPlaylist(BuildContext context, List<VideoData> pl) {
    List<Widget> r = [];
    for (VideoData d in pl) {
      r.add(
          PlaylistItem(d, d == context.read<PlaylistProvider>().currentVideo));
    }
    return r;
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
                child: Wrap(
                  children: buildPlaylist(context, pl),
                )))
      ],
    );
  }
}

class PlaylistItem extends StatefulWidget {
  const PlaylistItem(this.d, this.playingVideo, {Key? key}) : super(key: key);
  final VideoData d;
  final bool playingVideo;

  @override
  State<PlaylistItem> createState() => _PlaylistItemState();
}

class _PlaylistItemState extends State<PlaylistItem> {
  late Color backgroundcolor;
  @override
  void initState() {
    setState(() {
      backgroundcolor = (widget.playingVideo)
          ? const Color.fromARGB(255, 40, 109, 228)
          : ThemeData.dark().cardColor;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          if (widget.playingVideo) {
            backgroundcolor = const Color.fromARGB(255, 84, 145, 250);
          } else {
            backgroundcolor = ThemeData.dark().shadowColor;
          }
        });
      },
      onExit: (_) {
        setState(() {
          if (widget.playingVideo) {
            backgroundcolor = const Color.fromARGB(255, 40, 109, 228);
          } else {
            backgroundcolor = ThemeData.dark().cardColor;
          }
        });
      },
      child: Tooltip(
        message: widget.d.title,
        child: GestureDetector(
          onTap: () {
            context.read<PlaylistProvider>().jumpToVideo(context, widget.d);
            context.read<NavigationProvider>().goToPlayback(context: context);
          },
          child: ListTile(
            tileColor: backgroundcolor,
            shape: const Border.symmetric(horizontal: BorderSide()),
            title: Text(
              widget.d.title,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
                onPressed: () {
                  context
                      .read<PlaylistProvider>()
                      .dequeueVideo(context, widget.d);
                },
                icon: const Icon(FluentIcons.delete)),
          ),
        ),
      ),
    );
  }
}
