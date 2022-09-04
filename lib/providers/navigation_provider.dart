import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';
import 'package:reference_library/providers/search_provider.dart';
import 'package:reference_library/providers/settings_provider.dart';

// Provides some extra navigation hooks to the app for page transitions
class NavigationProvider extends ChangeNotifier {
  int _index = 0;
  bool _showMiniPlayer = false;
  final FocusNode _mainAppFocus = FocusNode();

  // Functions for jumping to specific screens
  void goToLibrary() {
    _index = 0;
    notifyListeners();
  }

  void goToSeries() {
    _index = 1;
    notifyListeners();
  }

  void goToSearch(BuildContext context) {
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
      // Because I'm too lazy to add an option to tell it to play the current video...
      context.read<PlaylistProvider>().nextVideo(context, autoStart: autoStart);
      context.read<PlaylistProvider>().prevVideo(context);
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
      // If a video is playing and Settings say mini play should be disable then pause instead
      if (_showMiniPlayer &&
          !context.read<SettingsProvider>().enableMiniPlayer) {
        context.read<PlaylistProvider>().pauseVideo();
        _showMiniPlayer = false;
      }
    }
    _index = i;

    if (_index == 2) {
      // If we're going to the search page make sure it shows results?
      String temp = context.read<SearchProvider>().currentKeywords;
      context.read<SearchProvider>().updateKeywords(temp, context);
    }

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

  void refreshPage() {
    int oldI = _index;
    _index++;
    if (_index == 4) {
      _index == 0;
    }
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 50)).then((value) {
      _index = oldI;
      notifyListeners();
    });
  }

  // Getters
  int get index => _index;
  bool get showMiniPlayer => _showMiniPlayer;
  FocusNode get mainAppFocus => _mainAppFocus;
  bool get isSearch => _index == 2;
}
