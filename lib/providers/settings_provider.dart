// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reference_library/jcrud/jcrud.dart';

class SettingsProvider with ChangeNotifier {
  // Name of the settings file that will live in temp directory
  final String _settingsFileName = "VRL_Settings";

  // Setting for enabling or disabling the miniPlayer
  late bool _enableMiniPlayer = true;

  // Folder for where videos are
  late Directory _videoFolder;

  // Folder for where video meta data is
  late Directory _dataFolder;

  // Folder for where thumbnails are
  late Directory _thumbFolder;

  // Hotkeys
  LogicalKeyboardKey _playPause = LogicalKeyboardKey.mediaPlayPause;
  LogicalKeyboardKey _smallSkipAhead = LogicalKeyboardKey.arrowRight;
  LogicalKeyboardKey _smallSkipBack = LogicalKeyboardKey.arrowLeft;
  LogicalKeyboardKey _bigSkipAhead = LogicalKeyboardKey.keyL;
  LogicalKeyboardKey _bigSkipBack = LogicalKeyboardKey.keyJ;

  late Duration _smallSkipTime;
  late Duration _bigSkipTime;

  // Constructor
  SettingsProvider() {
    initValues();
  }

  Future<void> initValues() async {
    // Use temp directory to save app settings
    Directory value = await getTemporaryDirectory();

    log(value.path);
    // Using jcrud to read / save settings
    jcrud settingsFile = jcrud(value.path);

    // Try reading the file
    Map<String, dynamic> savedSettings = settingsFile.read(_settingsFileName);

    // If it's an empty response then the file should be created and defaults set
    if (savedSettings.isEmpty) {
      // Create the file
      settingsFile.create(_settingsFileName);
      // Set default options
      _enableMiniPlayer = true;
      _videoFolder = Directory("${value.path}/videos");
      _dataFolder = Directory("${value.path}/.localstore");
      _thumbFolder = Directory("${value.path}/.thumbnails");
      _videoFolder.create();
      _dataFolder.create();
      _thumbFolder.create();
      _playPause = LogicalKeyboardKey.mediaPlayPause;
      _smallSkipAhead = LogicalKeyboardKey.arrowRight;
      _smallSkipBack = LogicalKeyboardKey.arrowLeft;
      _bigSkipAhead = LogicalKeyboardKey.keyL;
      _bigSkipBack = LogicalKeyboardKey.keyJ;
      _smallSkipTime = Duration(seconds: 10);
      _bigSkipTime = Duration(seconds: 30);
      // Save them to the file
      savedSettings["enableMiniPlayer"] = _enableMiniPlayer;
      savedSettings["videoFolder"] = _videoFolder.path;
      savedSettings["dataFolder"] = _dataFolder.path;
      savedSettings["thumbFolder"] = _thumbFolder.path;
      savedSettings["playPause"] = _playPause.keyId;
      savedSettings["smallSkipAhead"] = _smallSkipAhead.keyId;
      savedSettings["smallSkipBack"] = _smallSkipBack.keyId;
      savedSettings["bigSkipAhead"] = _bigSkipAhead.keyId;
      savedSettings["bigSkipBack"] = _bigSkipBack.keyId;
      savedSettings["smallSkipTime"] = _smallSkipTime.inSeconds;
      savedSettings["bigSkipTime"] = _bigSkipTime.inSeconds;
      settingsFile.update(_settingsFileName, savedSettings);
    }

    // If it wasn't an empty map then read the saved settings into the variables
    else {
      _enableMiniPlayer = savedSettings["enableMiniPlayer"];
      _videoFolder = Directory(savedSettings["videoFolder"]);
      _dataFolder = Directory(savedSettings["dataFolder"]);
      _thumbFolder = Directory(savedSettings["thumbFolder"]);
      _playPause = LogicalKeyboardKey(savedSettings["playPause"]);
      _smallSkipAhead = LogicalKeyboardKey(savedSettings["smallSkipAhead"]);
      _smallSkipBack = LogicalKeyboardKey(savedSettings["smallSkipBack"]);
      _bigSkipAhead = LogicalKeyboardKey(savedSettings["bigSkipAhead"]);
      _bigSkipBack = LogicalKeyboardKey(savedSettings["bigSkipBack"]);
      _smallSkipTime = Duration(seconds: savedSettings["smallSkipTime"]);
      _bigSkipTime = Duration(seconds: savedSettings["bigSkipTime"]);
    }

    notifyListeners();
  }

  // Setters
  void setEnableMiniPlayer(bool b) {
    _enableMiniPlayer = b;
    notifyListeners();
  }

  void setVideoFolder(String p) {
    Directory d = Directory(p);
    if (d.existsSync()) {
      _videoFolder = d;
      notifyListeners();
    }
  }

  void setDataFolder(String p) {
    Directory d = Directory(p);
    if (d.existsSync()) {
      _dataFolder = d;
      notifyListeners();
    }
  }

  void setThumbFolder(String p) {
    Directory d = Directory(p);
    if (d.existsSync()) {
      _thumbFolder = d;
      notifyListeners();
    }
  }

  void setPlayPauseKey(int i) {
    _playPause = LogicalKeyboardKey(i);
    notifyListeners();
  }

  void setSmallSkipAheadKey(int i) {
    _smallSkipAhead = LogicalKeyboardKey(i);
    notifyListeners();
  }

  void setSmallSkipBackKey(int i) {
    _smallSkipBack = LogicalKeyboardKey(i);
    notifyListeners();
  }

  void setBigSkipAheadKey(int i) {
    _bigSkipAhead = LogicalKeyboardKey(i);
    notifyListeners();
  }

  void setBigSkipBackKey(int i) {
    _bigSkipBack = LogicalKeyboardKey(i);
    notifyListeners();
  }

  void setSmallSkipTime(int s) {
    _smallSkipTime = Duration(seconds: s);
    notifyListeners();
  }

  void setBigSkipTime(int s) {
    _bigSkipTime = Duration(seconds: s);
    notifyListeners();
  }

  // Getters
  bool get enableMiniPlayer => _enableMiniPlayer;
  Directory get videoFolder => _videoFolder;
  Directory get dataFolder => _dataFolder;
  Directory get thumbFolder => _thumbFolder;
  LogicalKeyboardKey get playPauseKey => _playPause;
  LogicalKeyboardKey get smallSkipAheadKey => _smallSkipAhead;
  LogicalKeyboardKey get smallSkipBackKey => _smallSkipBack;
  LogicalKeyboardKey get bigSkipAheadKey => _bigSkipAhead;
  LogicalKeyboardKey get bigSkipBackKey => _bigSkipBack;
  Duration get smallSkipTime => _smallSkipTime;
  Duration get bigSkipTime => _bigSkipTime;
}
