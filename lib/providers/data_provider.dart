import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/jcrud/jcrud.dart';
import 'package:reference_library/providers/settings_provider.dart';
import 'package:youtube/youtube_thumbnail.dart';

// Provides all video meta data to the rest of the app
class DataProvider with ChangeNotifier {
  final List<String> _availableTags = [];
  final List<String> _availableSeries = [];
  final List<TimestampData> _allTimestamps = [];
  final Map<String, VideoData> _allVideos = {};
  static late jcrud _localData;
  // Name of the settings file that will live in temp directory
  final String _settingsFileName = "VRL_Settings";

  // When the provider is created run init
  DataProvider() {
    initValues();
  }

  // Go and grab all the saved video data (if there is any)
  void initValues({bool fullInit = true}) async {
    String dataFolder = "";
    String thumbFolder = "";
    if (fullInit) {
      // Use temp directory to save app settings
      Directory value = await getTemporaryDirectory();
      log("Settings file: ${value.path}/$_settingsFileName");
      jcrud localSettings = jcrud(value.path);
      Map<String, dynamic> savedSettings =
          localSettings.read(_settingsFileName);

      if (savedSettings.isEmpty) {
        dataFolder = "${value.path}/.localstore";
        thumbFolder = "${value.path}/.localstore/thumbnails";
      } else {
        dataFolder = savedSettings["dataFolder"];
        thumbFolder = savedSettings["thumbFolder"];
      }
      // Read from the set data folder
      _localData = jcrud(dataFolder);
    }

    // Get the list of created tags
    Map<String, dynamic> temp = _localData.read("Tags");
    if (temp.isNotEmpty) {
      for (String t in temp["Tags"]) {
        _availableTags.add(t);
      }
    }
    // And the list of series names
    temp = _localData.read("Series");
    if (temp.isNotEmpty) {
      for (String t in temp["Series"]) {
        _availableSeries.add(t);
      }
    }
    // Then all the individual video data
    temp = _localData.readAll();
    if (temp.isNotEmpty) {
      for (String key in temp.keys) {
        // Skip over the Tags and Series files
        if (key == "Tags" || key == "Series" || key == ".DS_Store") {
          continue;
        }
        _allVideos[key] = VideoData.fromMap(temp[key], thumbFolder);
      }
    }
    // Sort the tags and series alphabetically
    _availableTags.sort();
    _availableSeries.sort();
    notifyListeners();
  }

  // Change in settings
  void changeDataFolder(BuildContext context) {
    _localData = jcrud(context.read<SettingsProvider>().dataFolder.path);
    // Read in values from the new folder
    initValues(fullInit: false);
  }

  // Tag create and delete
  void addTag(String t) {
    if (!_availableTags.contains(t)) {
      _availableTags.add(t);
      _localData.update("Tags", {"Tags": _availableTags});
      notifyListeners();
    }
  }

  void deleteTag(String t) {
    if (_availableTags.contains(t)) {
      _availableTags.remove(t);
      _localData.update("Tags", {"Tags": _availableTags});
      notifyListeners();
    }
  }

  // Series CRUD
  void createSeries(String seriesName, {List<String> videoIds = const []}) {
    // Add the new series to the list
    if (!_availableSeries.contains(seriesName)) {
      _availableSeries.add(seriesName);
    }

    // If a list of video ids was sent update their data too
    if (videoIds.isNotEmpty) {
      int i = 0;
      for (String v in videoIds) {
        // Set the series values for the video
        _allVideos[v]!.series = true;
        _allVideos[v]!.seriesTitle = seriesName;
        _allVideos[v]!.seriesIndex = i;
        i++;
        // Write the file for the updated video
        _localData.update(v, _allVideos[v]!.toMap());
      }
    }

    // Update the series data file
    _localData.update("Series", {"Series": _availableSeries});
    notifyListeners();
  }

  // I don't know if this one is actually needed since it all gets read at startup?
  //void readSeries() {}

  // Updates a series, I guess it's only renaming?
  void updateSeries(String oldName, String newName) {
    // First double check that the old name and new name aren't the same, oldName is in the list, and newName is not in the list
    if (oldName == newName ||
        _availableSeries.contains(newName) ||
        !_availableSeries.contains(oldName)) {
      return;
    }

    // Swap out the old and new names in the in memory list
    _availableSeries.remove(oldName);
    if (!_availableSeries.contains(newName)) {}
    _availableSeries.add(newName);

    // Update any videos that had the old series title with the new one
    for (VideoData v in _allVideos.values) {
      if (v.seriesTitle == oldName) {
        _allVideos[v.videoId]!.seriesTitle = newName;
        _localData.update(v.videoId, v.toMap());
      }
    }

    // Update the series data file
    _localData.update("Series", {"Series": _availableSeries});
    notifyListeners();
  }

  void deleteSeries(String seriesName) {
    // Remove from the in-mem list
    _availableSeries.remove(seriesName);

    // For any videos that were in the series reset them
    for (VideoData v in _allVideos.values) {
      if (v.seriesTitle == seriesName) {
        _allVideos[v.videoId]!.series = false;
        _allVideos[v.videoId]!.seriesIndex = 0;
        _allVideos[v.videoId]!.seriesTitle = "";
        _localData.update(v.videoId, v.toMap());
      }
    }

    // Update the series data file
    _localData.update("Series", {"Series": _availableSeries});
    notifyListeners();
  }

  // Video CRUD
  // Creats a new video file
  void createVideo(VideoData v) {
    if (!_allVideos.containsKey(v.videoId)) {
      _allVideos[v.videoId] = v;
      _localData.update(v.videoId, v.toMap());
      notifyListeners();
    }
  }

  // I don't know if this one is needed either...
  //void readVideo() {}

  // Updates an old video data entry to a new one
  void updateVideo(VideoData oldVid, VideoData newVid) {
    log(newVid.toString());
    if (oldVid != newVid) {
      if (_allVideos.containsKey(oldVid.videoId)) {
        _allVideos.remove(oldVid.videoId);
        _allVideos[newVid.videoId] = newVid;
        notifyListeners();
        _localData.deleteMeta(oldVid.videoId);
        _localData.update(newVid.videoId, newVid.toMap());
      }
    }
  }

  // Delete a video
  void deleteVideo(String videoId) {
    if (_allVideos.containsKey(videoId)) {
      // Then the meta file
      _localData.deleteMeta(videoId);
      // Then remove it from the list of videos
      _allVideos.remove(videoId);
      // Then update listeners for page refresh
      notifyListeners();
    }
  }

  // Timestamp CRUD
  // Adds timestamp to a video if it's not already on the list
  void createTimestamp(String videoId, TimestampData t) {
    if (_allVideos.containsKey(videoId)) {
      if (!_allVideos[videoId]!.timestamps.contains(t)) {
        _allVideos[videoId]?.timestamps.add(t);
        _localData.update(videoId, _allVideos[videoId]!.toMap());
        notifyListeners();
      }
    }
  }

  // Don't know if I need this
  // void readTimestamp() {}

  // Similar idea to updating a video where you swap out the old ts and put in the new one
  void updateTimestamp(
      String videoId, TimestampData oldTS, TimestampData newTS) {
    int index = _allVideos[videoId]!.timestamps.indexOf(oldTS);

    if (_allVideos[videoId]!.timestamps.length >= index + 1) {
      _allVideos[videoId]?.timestamps[index] = newTS;

      _localData.update(videoId, _allVideos[videoId]!.toMap());
      notifyListeners();
    }
  }

  // Deletes the timestamp
  void deleteTimestamp(TimestampData t) {
    int index = _allVideos[t.videoId]!.timestamps.indexOf(t);
    if (_allVideos[t.videoId]!.timestamps.length >= index + 1) {
      _allVideos[t.videoId]?.timestamps.removeAt(index);
      _localData.update(t.videoId, _allVideos[t.videoId]!.toMap());
      notifyListeners();
    }
  }

  // Getters
  List<String> get tags => _availableTags;
  List<String> get series => _availableSeries;
  List<TimestampData> get timestamps => _allTimestamps;
  Map<String, VideoData> get videos => _allVideos;
}

// Class for laying out data about video timestamps
class TimestampData {
  List<String> tags = [];
  String videoId = "";
  String topic = "";
  String timestampString = "";
  late Duration timestamp;

  // On init parse the timestamp string into a duration object for use in
  //   playback seeks
  TimestampData(this.tags, this.videoId, this.topic, this.timestampString) {
    List<String> parts = timestampString.split(':');
    int hours = int.parse(parts[0]);
    int mins = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    timestamp = Duration(hours: hours, minutes: mins, seconds: seconds);
  }

  // Clone a timestamp object
  TimestampData clone() {
    return TimestampData(tags, videoId, topic, timestampString);
  }

  // For dumping the object to a json object
  Map<String, dynamic> toMap() {
    return {
      'tags': tags,
      'videoId': videoId,
      'topic': topic,
      'time': timestampString
    };
  }

  // For creating a TimestampData object from a json object
  factory TimestampData.fromMap(String videoId, Map<String, dynamic> map) {
    return TimestampData(
        List<String>.from(map['tags'].map((e) => e.toString())),
        videoId,
        map['topic'],
        map['time']);
  }

  @override
  String toString() {
    return "Time: $timestampString | Topic: $topic | Tags: ${tags.toString()} | VID: $videoId\n";
  }
}

// Class for laying out video data
class VideoData {
  String videoId = "";
  String title = "";
  String localPath = "";
  String thumbnailPath = "";
  bool series = false;
  String seriesTitle = "";
  int seriesIndex = 0;
  bool complete = false;
  String url = "";
  List<TimestampData> timestamps = [];
  List<String> tags = [];
  String thumbDir = "";

  // Constructor
  VideoData(
      this.videoId,
      this.title,
      this.localPath,
      this.series,
      this.seriesTitle,
      this.seriesIndex,
      this.complete,
      this.url,
      this.timestamps,
      this.tags,
      this.thumbDir,
      {this.thumbnailPath = ""}) {
    // Check to see if a thumbnail exists, if it doesn't then download and save it

    if (thumbnailPath == "") {
      File possibleThumbnail = File("$thumbDir/$videoId.jpg");
      if (!possibleThumbnail.existsSync()) {
        if (url.contains("youtube")) {
          String tmbUrl =
              YoutubeThumbnail(youtubeId: url.split('watch?v=').last).hq();
          NetworkAssetBundle(Uri.parse(tmbUrl)).load(tmbUrl).then((value) {
            Uint8List tmbBytes = value.buffer.asUint8List();
            possibleThumbnail
                .create()
                .then((value) => value.writeAsBytes(tmbBytes));
          });
        }
      }
      thumbnailPath = possibleThumbnail.path;
    }
  }

  // Clone a video object
  VideoData clone() {
    return VideoData(videoId, title, localPath, series, seriesTitle,
        seriesIndex, complete, url, timestamps, tags, thumbDir);
  }

  // Dump to json object
  Map<String, dynamic> toMap() {
    Map<String, dynamic> r = {
      'videoId': videoId,
      'title': title,
      'localPath': localPath,
      'thumbnailPath': thumbnailPath,
      'series': series,
      'seriesTitle': seriesTitle,
      'seriesIndex': seriesIndex,
      'complete': complete,
      'url': url,
      'timestamps': timestamps.map((e) => e.toMap()).toList(),
      'tags': tags
    };
    return r;
  }

  // Create from json object
  factory VideoData.fromMap(Map<String, dynamic> map, String thumbDir) {
    List<TimestampData> ts = [];
    if (!map['timestamps'].isEmpty) {
      for (Map<String, dynamic> d in map['timestamps']) {
        //d['videoId'] = '';
        ts.add(TimestampData.fromMap(
            map['title']
                .toString()
                .toLowerCase()
                .replaceAll(' ', '_')
                .replaceAll(RegExp("[^A-Za-z0-9_]"), ""),
            d));
      }
    }
    return VideoData(
        map['title']
            .toString()
            .toLowerCase()
            .replaceAll(' ', '_')
            .replaceAll(RegExp("[^A-Za-z0-9_]"), ""),
        map['title'],
        map['localPath'],
        map['series'],
        map['seriesTitle'],
        map['seriesIndex'],
        map['complete'],
        map['url'],
        ts,
        List<String>.from(map['tags'].map((e) => e.toString())),
        thumbDir);
  }

  @override
  String toString() {
    String r = "";
    r += "Title: $title\n";
    r += "URL: $url\n";
    r += "Path: $localPath\n";
    r += "Thumbnail: $thumbnailPath\n";
    r += "Tags: ${tags.toString()}\n";
    return r;
  }
}
