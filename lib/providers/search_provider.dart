// ignore_for_file: prefer_final_fields

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';
import 'package:reference_library/widgets/video_card.dart';

class SearchProvider with ChangeNotifier {
  List<String> _currentTags = [];
  String _currentKeywords = "";
  List<VideoData> _videoResults = [];
  List<TimestampData> _timestampResults = [];
  List<Widget> _searchResults = [];
  List<String> _suggestions = [];
  List<String> _ignored = [
    "a",
    "and",
    "the",
    "what",
    "is",
    "how",
    "but",
    " ",
    "",
    "\t",
    "\n",
    "chapter",
    "really",
    "doing",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "in",
    "do",
    "mean",
    "to",
    "vs",
    "on",
    "more",
    "some",
    "are"
  ];

  SearchProvider() {
    clearSearch();
  }

  // Reset all the current values
  void clearSearch() {
    _currentTags.clear();
    _videoResults.clear();
    _timestampResults.clear();
    _searchResults.clear();
    _currentKeywords = "";
    notifyListeners();
  }

  void addTag(String t, BuildContext context) {
    // If it's not in the current tags, add & rebuild
    if (!_currentTags.contains(t)) {
      _currentTags.add(t);
      _regenerateSearch(context);
    }
  }

  void removeTag(String t, BuildContext context) {
    // If it's in the current tags, remove & rebuild
    if (_currentTags.contains(t)) {
      _currentTags.remove(t);
      _regenerateSearch(context);
    }
  }

  // Update the tag filter then rebuild results
  void updateTags(List<String> t, BuildContext context) {
    _currentTags = t;
    _regenerateSearch(context);
  }

  // Update the keyword string then rebuild results
  void updateKeywords(String s, BuildContext context) {
    _currentKeywords = s;
    _regenerateSearch(context);
  }

  // Gets then rebuilts the list of search results
  void _regenerateSearch(BuildContext context) {
    // Clear out any existing results
    _videoResults.clear();
    _timestampResults.clear();
    _searchResults.clear();
    _suggestions.clear();

    // Get the list of matching timestamps and videos
    _getTimestampResults(context);
    _getVideoResults(context);

    // Update the list of potential keyword suggestions
    _updateSuggestions(context);

    // Build the list of results
    _buildWidgets(context);
    notifyListeners();
  }

  // Update suggestions based on videos in results, top 10
  void _updateSuggestions(BuildContext context) {
    List<Suggestion> tempSuggestions = [];
    List<String> keys = [];

    for (VideoData d in _videoResults) {
      List<String> normalizedTitle = d.title.toLowerCase().split(" ");
      for (String part in normalizedTitle) {
        // Ignore the part of the title that may be a common word
        if (_ignored.contains(part)) {
          continue;
        }
        if (!keys.contains(part)) {
          keys.add(part);
          tempSuggestions.add(Suggestion(part));
          continue;
        }
        for (Suggestion s in tempSuggestions) {
          if (s.word == part) {
            s.count++;
          }
        }
      }
    }

    // Do the same thing for the timestamp topics
    for (TimestampData d in _timestampResults) {
      List<String> normalizedTitle = d.topic.toLowerCase().split(" ");
      for (String part in normalizedTitle) {
        // Ignore the part of the title that may be a common word
        if (_ignored.contains(part)) {
          continue;
        }
        if (!keys.contains(part)) {
          keys.add(part);
          tempSuggestions.add(Suggestion(part));
          continue;
        }
        for (Suggestion s in tempSuggestions) {
          if (s.word == part) {
            s.count++;
          }
        }
      }
    }

    // Sort by highest count keywords
    tempSuggestions.sort((a, b) => b.count.compareTo(a.count));
    // Get an end spot, if the list is longer than 9 cap it there, otherwise end wherever suggestions end
    int end = tempSuggestions.length > 9 ? 9 : tempSuggestions.length;
    _suggestions = [
      ...tempSuggestions.getRange(0, end).toList().map((e) => e.word)
    ];
    _suggestions.sort();
  }

  // Gets the list of videos that match tag and keyword values
  void _getVideoResults(BuildContext context) {
    // If the filters and words are empty, show all videos
    if (_currentTags.isEmpty &&
        (_currentKeywords.isEmpty || _currentKeywords == "")) {
      _videoResults = [...context.read<DataProvider>().videos.values.toList()];
      return;
    }

    // Otherwise check the videos to see if they are a match for the criteria
    for (VideoData d in context.read<DataProvider>().videos.values.toList()) {
      // Check to make sure the video matches the tag filters
      int matchingTagCount = 0;
      for (String t in _currentTags) {
        if (d.tags.contains(t)) {
          matchingTagCount++;
        }
      }
      // If it doesn't match all the tags then go to the next video
      if (matchingTagCount < _currentTags.length) {
        continue;
      }

      // Now check to see if it matches a keyword, this will match any keyword
      List<String> normalizedTitle = d.title.toLowerCase().split(" ");
      for (String keyword in _currentKeywords.split(" ")) {
        // Be generous and match parts of keywords
        for (String titleKeyword in normalizedTitle) {
          if (titleKeyword.contains(keyword.toLowerCase())) {
            // Make sure the video isn't in the list already
            if (!_videoResults.contains(d)) {
              _videoResults.add(d);
            }
          }
        }
      }
    }
  }

  // Gets the list of timestamps that match tag and keyword values
  void _getTimestampResults(BuildContext context) {
    // If the filters are empty ignore timestamps
    if (_currentTags.isEmpty &&
        (_currentKeywords.isEmpty || _currentKeywords == "")) {
      return;
    }

    // Build a list of matching timestamps
    for (VideoData d in context.read<DataProvider>().videos.values.toList()) {
      for (TimestampData ts in d.timestamps) {
        // Check to make sure the video matches the tag filters
        int matchingTagCount = 0;
        for (String tag in _currentTags) {
          if (ts.tags.contains(tag)) {
            matchingTagCount++;
          }
        }
        // If it doesn't match all the tags then go to the next video
        if (matchingTagCount < _currentTags.length) {
          continue;
        }

        // Now check to see if it matches a keyword, this will match any keyword
        List<String> normalizedTitle = ts.topic.toLowerCase().split(" ");
        for (String keyword in _currentKeywords.split(" ")) {
          // Be generous and match parts of keywords
          for (String titleKeyword in normalizedTitle) {
            if (titleKeyword.contains(keyword.toLowerCase())) {
              // Make sure the video isn't in the list already
              if (!_timestampResults.contains(ts)) {
                _timestampResults.add(ts);
              }
            }
          }
        }
      }
    }
  }

  // Builds a list of widgets that go to the search results grid view
  // VideoCard widgets for the videos and a different custom widget for the timestamps
  void _buildWidgets(BuildContext context) {
    // Then start with the timestamp results
    for (TimestampData d in _timestampResults) {
      _searchResults.add(TimestampCard(
          d.clone(), context.read<DataProvider>().videos[d.videoId]!));
    }
    // Then the video results
    for (VideoData d in _videoResults) {
      _searchResults.add(VideoCard(d));
    }
  }

  List<String> get currentTags => _currentTags;
  String get currentKeywords => _currentKeywords;
  List<Widget> get searchResults => _searchResults;
  List<String> get suggestions => _suggestions;
}

class Suggestion {
  String word = "";
  int count = 0;
  Suggestion(this.word);
}

class TimestampCard extends StatefulWidget {
  const TimestampCard(this.tsData, this.vData, {Key? key}) : super(key: key);
  final TimestampData tsData;
  final VideoData vData;
  @override
  State<TimestampCard> createState() => _TimestampCardState();
}

class _TimestampCardState extends State<TimestampCard> {
  Color backgroundcolor = ThemeData.dark().cardColor;
  bool init = false;
  late VideoData vData;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) {
          setState(() {
            backgroundcolor = ThemeData.dark().shadowColor;
          });
        },
        onExit: (_) {
          setState(() {
            backgroundcolor = ThemeData.dark().cardColor;
          });
        },
        child: Tooltip(
          displayHorizontally: false,
          useMousePosition: false,
          style: const TooltipThemeData(
              preferBelow: true,
              verticalOffset: 25,
              showDuration: Duration(milliseconds: 500),
              waitDuration: Duration(milliseconds: 500)),
          message: widget.tsData.topic,
          child: GestureDetector(
            onTap: () {
              // Left click the card to play the video at the timestamp
              // If anything is currently playing stop it
              context.read<PlaylistProvider>().pauseVideo();

              // Add the video to the playlist
              context
                  .read<PlaylistProvider>()
                  .queueVideo(context, widget.vData);

              // Set that video as the currently playing one
              context
                  .read<PlaylistProvider>()
                  .jumpToVideo(context, widget.vData);

              // Short delay then do the rest?
              Future.delayed(const Duration(milliseconds: 150)).then((value) {
                // Jump to the timestamp
                context
                    .read<PlaylistProvider>()
                    .jumpTo(widget.tsData.timestamp);

                // Go to the playback page and play it
                context
                    .read<NavigationProvider>()
                    .goToPlayback(context: context, autoStart: true);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              // fluent Card is the main visual base
              child: Card(
                  backgroundColor: backgroundcolor,
                  child: Stack(children: [
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(FluentIcons.clock),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Topic: ${widget.tsData.topic}\n",
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Video: ${widget.vData.title}\n"),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text("Time: ${widget.tsData.timestampString}"),
                    ),
                  ])),
            ),
          ),
        ));
  }
}
