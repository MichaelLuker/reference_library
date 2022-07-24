import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:reference_library/jcrud/jcrud.dart';
import 'package:youtube/youtube_thumbnail.dart';

// Provides all video meta data to the rest of the app
class DataProvider with ChangeNotifier {
  final List<String> _availableTags = [];
  final List<String> _availableSeries = [];
  final List<TimestampData> _allTimestamps = [];
  final List<VideoData> _allVideos = [];
  static final _localData = jcrud("D:/Video Library/.localstore");

  // When the provider is created run init
  DataProvider() {
    initValues();
  }

  // Go and grab all the saved video data (if there is any)
  void initValues() {
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
        if (key == "Tags" || key == "Series") {
          continue;
        }
        _allVideos.add(VideoData.fromMap(temp[key]));
      }
    }
    // Sort the tags and series alphabetically
    _availableTags.sort();
    _availableSeries.sort();
    notifyListeners();
  }

  // Functions to add, edit, and delete tags, series, videos, and timestamps will go here
  // Maybe even the functions for downloading a video??

  // Getters
  List<String> get tags => _availableTags;
  List<String> get series => _availableSeries;
  List<TimestampData> get timestamps => _allTimestamps;
  List<VideoData> get videos => _allVideos;
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

  // For dumping the object to a json object
  Map<String, dynamic> toMap() {
    return {
      'tags': tags,
      'videoId': videoId,
      'topic': topic,
      'timestampString': timestampString
    };
  }

  // For creating a TimestampData object from a json object
  factory TimestampData.fromMap(Map<String, dynamic> map) {
    return TimestampData(
        List<String>.from(map['tags'].map((e) => e.toString())),
        map['videoId'],
        map['topic'],
        map['time']);
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
      this.tags) {
    // Check to see if a thumbnail exists, if it doesn't then download and save it
    File possibleThumbnail = File("D:/Video Library/.thumbnails/$videoId.jpg");
    if (!possibleThumbnail.existsSync()) {
      String tmbUrl =
          YoutubeThumbnail(youtubeId: url.split('watch?v=').last).hq();
      NetworkAssetBundle(Uri.parse(tmbUrl)).load(tmbUrl).then((value) {
        log(value.toString());
        Uint8List tmbBytes = value.buffer.asUint8List();
        possibleThumbnail
            .create()
            .then((value) => value.writeAsBytes(tmbBytes));
      });
    }
    thumbnailPath = possibleThumbnail.path;
  }

  // Dump to json object
  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'title': title,
      'localPath': localPath,
      'thumbnailPath': thumbnailPath,
      'series': series,
      'seriesTitle': seriesTitle,
      'seriesIndex': seriesIndex,
      'complete': complete,
      'url': url,
      'timestamps': timestamps.map((e) => e.toMap()),
      'tags': tags
    };
  }

  // Create from json object
  factory VideoData.fromMap(Map<String, dynamic> map) {
    List<TimestampData> ts = [];
    if (!map['timestamps'].isEmpty) {
      for (Map<String, dynamic> d in map['timestamps']) {
        d['videoId'] = '';
        ts.add(TimestampData.fromMap(d));
      }
    }
    return VideoData(
        map['title'].toString().toLowerCase().replaceAll(' ', '_'),
        map['title'],
        map['localPath'],
        map['series'],
        map['seriesTitle'],
        map['seriesIndex'],
        map['complete'],
        map['url'],
        ts,
        List<String>.from(map['tags'].map((e) => e.toString())));
  }
}
