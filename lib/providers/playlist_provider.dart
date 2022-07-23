import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:dart_vlc/dart_vlc.dart';

class PlaylistProvider with ChangeNotifier {
  List<VideoData> _playList = [];
  int _playListIndex = 0;
  VideoData? _currentVideo;
  bool _currentlyPlaying = false;
  bool _randomMode = false;
  late Player _player;
  bool _debounce = false;
  BuildContext? _context;

  PlaylistProvider() {
    // _player.open(
    //     Media.file(
    //       File(
    //           "D:/Video Library/AI & ML/2020 Machine Learning Roadmap (95 valid for 2022).mp4"),
    //       startTime: const Duration(hours: 1, minutes: 12, seconds: 42),
    //     ),
    //     autoStart: false);
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

  void finishedVideo() {}

  void _loadVideo({bool autoStart = true}) {
    if (_currentVideo != null) {
      _player.open(Media.file(File(_currentVideo!.localPath)),
          autoStart: autoStart);
    }
    _debounce = false;
  }

  void playPause() {
    _player.playOrPause();
  }

  void pauseVideo() {
    _player.pause();
  }

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

  void nextVideo({bool autoStart = true}) {
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

  void jumpTo(Duration dur) {
    log(dur.toString());
    _player.seek(dur);
  }

  void setRandomMode(bool b, BuildContext context) {
    _context = context;
    _randomMode = b;
    notifyListeners();
  }

  VideoData _randomVideo() {
    int r = math.Random().nextInt(_context!.read<DataProvider>().videos.length);
    return _context!.read<DataProvider>().videos[r];
  }

  Player get player => _player;
  VideoData? get currentVideo => _currentVideo;
  List<VideoData> get playList => _playList;
  bool get randomMode => _randomMode;
}
