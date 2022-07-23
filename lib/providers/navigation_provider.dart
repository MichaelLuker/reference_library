import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';

// Provides some extra navigation hooks to the app for page transitions
class NavigationProvider extends ChangeNotifier {
  int _index = 0;
  bool _showMiniPlayer = false;

  // Functions for jumping to specific screens
  void goToLibrary() {
    _index = 0;
    notifyListeners();
  }

  void goToSeries() {
    _index = 1;
    notifyListeners();
  }

  void goToSearch() {
    _index = 2;
    notifyListeners();
  }

  // If the app is going to the playback screen make sure to get rid of the mini player
  void goToPlayback({required BuildContext context, bool autoStart = false}) {
    _index = 3;
    _showMiniPlayer = false;
    notifyListeners();
    // If a video is not playing then go to the next video? I'm a little confused
    //   why I added this? But I'll leave it alone for now
    if (!context.read<PlaylistProvider>().player.playback.isPlaying) {
      context.read<PlaylistProvider>().nextVideo(autoStart: autoStart);
    }
  }

  void goToSettings() {
    _index = 4;
    notifyListeners();
  }

  // Does kind of the same thing as the goToPlayback function, but works on any
  //   screen transition I guess
  void setIndex(int i, {required BuildContext context}) {
    // If we're leaving the playback check to see if a video was playing that should minify
    if (_index == 3) {
      _showMiniPlayer =
          context.read<PlaylistProvider>().player.playback.isPlaying;
    }
    _index = i;
    if (_index == 3) {
      // If we're going TO the playback screen we don't want the mini player
      _showMiniPlayer = false;
    }
    notifyListeners();
  }

  // Closes the mini player
  void closeMiniPlayer({required BuildContext context}) {
    _showMiniPlayer = false;
    context.read<PlaylistProvider>().pauseVideo();
    notifyListeners();
  }

  // Getters
  int get index => _index;
  bool get showMiniPlayer => _showMiniPlayer;
}
