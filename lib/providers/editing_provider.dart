import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:reference_library/providers/data_provider.dart';

class EditingProvider with ChangeNotifier {
  VideoData? _videoData;
  List<TimestampData>? _timestamps;
  List<String>? _tags;

  void setVideoData(VideoData d) {
    _videoData = d;
    notifyListeners();
  }

  void setTimestamps(List<TimestampData> t) {
    _timestamps = [...t];
    notifyListeners();
  }

  void setTags(List<String> t) {
    _tags = [...t];
    notifyListeners();
  }

  void updateTimestamp(TimestampData oldT, TimestampData newT) {
    if (_timestamps != null) {
      int i = _timestamps!.indexOf(oldT);
      if (i != -1) {
        _timestamps![i] = newT;
      }
    }
    notifyListeners();
  }

  void removeTimestamp(TimestampData t) {
    if (_timestamps != null) {
      _timestamps!.remove(t);
    }
    notifyListeners();
  }

  void addTimestamp(TimestampData t) {
    if (_timestamps != null) {
      _timestamps!.add(t);
    } else {
      _timestamps = [t];
    }

    notifyListeners();
  }

  void addTag(String t) {
    if (_tags != null) {
      if (!_tags!.contains(t)) {
        _tags!.add(t);
        log("Adding selected tag $t");
        notifyListeners();
      }
    }
  }

  // Getters
  VideoData? get videoData => _videoData;
  List<TimestampData>? get timestamps => _timestamps;
  List<String>? get tags => _tags;
}
