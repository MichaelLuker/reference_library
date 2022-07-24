import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:dart_vlc/dart_vlc.dart';

// Provides all the video player functions and state to the app
class PlaylistProvider with ChangeNotifier {
  final List<VideoData> _playList = [];
  int _playListIndex = 0;
  VideoData? _currentVideo;
  bool _randomMode = false;
  late Player _player;
  bool _debounce = false;
  BuildContext? _context;

  PlaylistProvider() {
    // Set an ID for the player, and set up a listener on the playback stream to detect
    //   when a video finishes playing
    _player = Player(id: 0);
    _player.playbackStream.listen((event) {
      if (event.isCompleted && !_debounce) {
        _debounce = true;
        // Debounce delay, so nextVideo isn't called 4 or 5 times on video end
        Future.delayed(const Duration(milliseconds: 250)).then((_) {
          _debounce = false;
        });
        nextVideo();
      }
    });
  }

  // Removes a video from the queue. If the currently playing video is removed then
  //   go to the next video, if that was the only video in the list stop all play back
  void dequeueVideo(VideoData d) {
    if (_currentVideo == d) {
      if (_playList.length == 1) {
        _player.stop();
        _playList.remove(d);
        _currentVideo = null;
        notifyListeners();
        return;
      } else {
        nextVideo();
      }
    }
    if (_playList.contains(d)) {
      _playList.remove(d);
      notifyListeners();
    }
  }

  // Adds a video to the playlist queue, if there's no current video set (ie. the
  //    playlist was empty) set the current video to this first video in the list
  void queueVideo(VideoData d) {
    if (!_playList.contains(d)) {
      _playList.add(d);
    }

    if (_currentVideo == null) {
      log("No current video, setting ${d.title}");
      _currentVideo = d;
      _playListIndex = 0;
      _loadVideo(autoStart: false);
    }
  }

  // Tells the player to actually load the current video, and auto play it if
  //   that's selected. Also resets the debounce variable.
  void _loadVideo({bool autoStart = true}) {
    if (_currentVideo != null) {
      _player.open(Media.file(File(_currentVideo!.localPath)),
          autoStart: autoStart);
    }
    _debounce = false;
  }

  // Play / Pause controls in the provider for use in other parts of the app
  void playPause() {
    _player.playOrPause();
  }

  void pauseVideo() {
    _player.pause();
  }

  // Plays the video that is previous to the current spot of the playlist
  void prevVideo() {
    if (_playListIndex == 0) {
      if (_playList.isNotEmpty) {
        _playListIndex = _playList.length - 1;
      }
    } else {
      _playListIndex--;
    }
    _currentVideo = _playList[_playListIndex];
    _loadVideo();
    notifyListeners();
  }

  // Updates things to play the next video on the playlist
  void nextVideo({bool autoStart = true}) {
    // If randome mode is on randomly pick a video from the library and if it's
    //   not on the playlist add it, then play it
    if (_randomMode) {
      _currentVideo = _randomVideo();
      if (!_playList.contains(_currentVideo)) {
        _playList.add(_currentVideo!);
        _playListIndex++;
      } else {
        _playListIndex = _playList.indexOf(_currentVideo!);
      }

      _loadVideo(autoStart: autoStart);
      notifyListeners();
      return;
    }

    // If it's normal playback mode, either get the next video or loop back to
    //   the beginning of the playlist
    if (_playList.isEmpty) {
      return;
    }
    if (_playListIndex == _playList.length - 1) {
      _playListIndex = 0;
    } else {
      _playListIndex++;
    }
    _currentVideo = _playList[_playListIndex];
    _loadVideo(autoStart: autoStart);
    notifyListeners();
  }

  // Seeks video to the sent timestampe in the form of a duration from 00:00:00
  void jumpTo(Duration dur) {
    log(dur.toString());
    _player.seek(dur);
  }

  // Functions for controlling random play back
  void setRandomMode(bool b, BuildContext context) {
    _context = context;
    _randomMode = b;
    notifyListeners();
  }

  VideoData _randomVideo() {
    List<String> keys = _context!.read<DataProvider>().videos.keys.toList();
    int r = math.Random().nextInt(keys.length);
    String randomKey = keys[r];
    VideoData randomVideo = _context!.read<DataProvider>().videos[randomKey]!;
    return randomVideo;
  }

  // Getters for different variables
  Player get player => _player;
  VideoData? get currentVideo => _currentVideo;
  List<VideoData> get playList => _playList;
  bool get randomMode => _randomMode;
}
