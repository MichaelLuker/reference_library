import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:localstore/localstore.dart';
import 'package:youtube/youtube_thumbnail.dart';

class TimestampData {
  List<String> tags = [];
  String videoId = "";
  String topic = "";
  String timestampString = "";
  late Duration timestamp;

  TimestampData(this.tags, this.videoId, this.topic, this.timestampString) {
    List<String> parts = timestampString.split(':');
    int hours = int.parse(parts[0]);
    int mins = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    timestamp = Duration(hours: hours, minutes: mins, seconds: seconds);
  }

  Map<String, dynamic> toMap() {
    return {
      'tags': tags,
      'videoId': videoId,
      'topic': topic,
      'timestampString': timestampString
    };
  }

  factory TimestampData.fromMap(Map<String, dynamic> map) {
    return TimestampData(
        List<String>.from(map['tags'].map((e) => e.toString())),
        map['videoId'],
        map['topic'],
        map['time']);
  }
}

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

class DataProvider with ChangeNotifier {
  List<String> _availableTags = [];
  List<String> _availableSeries = [];
  List<TimestampData> _allTimestamps = [];
  List<VideoData> _allVideos = [];
  static final _localData = Localstore.instance.collection("VideoLibrary");

  DataProvider() {
    initValues();
  }

  Future<void> initValues() async {
    // Read in all the currently saved data
    await _localData.doc("Tags").get().then((value) {
      for (String t in value!["Tags"]) {
        _availableTags.add(t);
      }
    });
    await _localData.doc("Series").get().then((value) {
      for (String t in value!["Series"]) {
        _availableSeries.add(t);
      }
    });
    await _localData.get().then((value) {
      if (value == null || value.isEmpty) {
        return;
      }
      for (String key in value.keys) {
        if (key == "\\VideoLibrary\\Tags" || key == "\\VideoLibrary\\Series") {
          continue;
        }
        _allVideos.add(VideoData.fromMap(value[key]));
      }
    });
    _availableTags.sort();
    _availableSeries.sort();
    //_allVideos.sort();
    notifyListeners();
  }

  List<String> get tags => _availableTags;
  List<String> get series => _availableSeries;
  List<TimestampData> get timestamps => _allTimestamps;
  List<VideoData> get videos => _allVideos;
}
