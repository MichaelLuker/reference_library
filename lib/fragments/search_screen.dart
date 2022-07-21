import 'dart:developer' as dev;
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/fragments/video_card.dart';
import 'package:reference_library/providers/data_provider.dart';

// Search page, showing all available tags to search on, shows timestamps first then full videos
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Need a secondary scroll controller for the left pane tag view
  ScrollController _tagScroller = ScrollController();
  ScrollController _sc = ScrollController();
  int _extraScrollSpeed = 50;
  // List of tags from the data provider
  late List<String> _tags;
  late List<VideoData> _videos;
  // Stores the state of if a tag is selected or not for visual updating
  Map<String, bool> _chipSelect = {};
  // List of the actually selected tags that will be used for filtering
  List<String> _selectedTags = [];

  // Builds the list of all tag chips
  List<Widget> buildChips(List<String> tags) {
    // If there's no values saved yet set them all to unselected
    bool init = false;
    if (_chipSelect.isEmpty) {
      init = true;
    }
    List<Widget> r = [];
    // For each tag create a chip with its text and selected state, and the function to call on a press
    for (String t in tags) {
      bool? savedVal = false;
      if (_chipSelect.containsKey(t)) {
        savedVal = _chipSelect[t];
      }
      bool selected;
      if (init) {
        selected = false;
      } else {
        selected = savedVal!;
      }
      r.add(Padding(
        padding: const EdgeInsets.all(4.0),
        child: CustomChip(t, selected, chipSelectCallback),
      ));
    }
    return r;
  }

  // Function called when a chip is selected, it updates the visual state and filter list
  void chipSelectCallback(String text, bool selected) {
    setState(() {
      bool updatedVal = selected ? false : true;
      _chipSelect[text] = updatedVal;
      if (updatedVal) {
        _selectedTags.add(text);
      } else {
        _selectedTags.remove(text);
      }
      dev.log(_selectedTags.toString());
    });
  }

  List<Widget> buildResults(List<VideoData> videos) {
    List<Widget> r = [];
    for (VideoData v in videos) {
      r.add(VideoCard(v));
    }
    return r;
  }

  @override
  void initState() {
    _sc.addListener(() {
      ScrollDirection scrollDirection = _sc.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = _sc.offset +
            (scrollDirection == ScrollDirection.reverse
                ? _extraScrollSpeed
                : -_extraScrollSpeed);
        scrollEnd = min(_sc.position.maxScrollExtent,
            max(_sc.position.minScrollExtent, scrollEnd));
        _sc.jumpTo(scrollEnd);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the tag list
    _tags = context.watch<DataProvider>().tags;
    _videos = context.watch<DataProvider>().videos;
    return ScaffoldPage(
      header: Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: Text("Tag Filters")),
              )),
          const Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoSuggestBox(
                placeholder: "Keyword Search",
                items: [],
                trailingIcon: Icon(FluentIcons.search_and_apps),
              ),
            ),
          ),
        ],
      ),
      content: Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(
                    flex: 9,
                    child: SingleChildScrollView(
                      controller: _tagScroller,
                      child: Wrap(
                        children: buildChips(_tags),
                      ),
                    ),
                  ),
                ],
              )),
          Expanded(
            flex: 8,
            child: GridView.count(
              controller: _sc,
              crossAxisCount: 5,
              children: buildResults(_videos),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom chip to handle displaying a selected chip
class CustomChip extends StatelessWidget {
  CustomChip(this.text, this.selected, this.callback, {Key? key})
      : super(key: key);
  String text;
  bool selected;
  Function callback;
  @override
  Widget build(BuildContext context) {
    return selected
        ? Chip.selected(
            text: Text(
              text,
            ),
            onPressed: () {
              callback(text, selected);
            },
          )
        : Chip(
            text: Text(
              text,
            ),
            onPressed: () {
              callback(text, selected);
            },
          );
  }
}
