// ignore_for_file: must_be_immutable, prefer_const_literals_to_create_immutables

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/search_provider.dart';
import 'package:reference_library/widgets/tags_widget.dart';
import 'package:reference_library/widgets/video_card.dart';
import 'package:reference_library/providers/data_provider.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);

  // Need a secondary scroll controller for the left pane tag view
  final ScrollController _tagScroller = ScrollController();
  final ScrollController _sc = ScrollController();
  late List<Widget> _results;
  late List<String> _suggestions;

  late final TagList _tagListWidget = TagList(
    selectedTags: [],
    editing: false,
  );

  List<Widget> buildResults(Map<String, VideoData> videos) {
    List<Widget> r = [];
    for (VideoData v in videos.values) {
      r.add(VideoCard(v));
    }
    return r;
  }

  // @override
  // void initState() {
  //   _sc.addListener(() {
  //     ScrollDirection scrollDirection = _sc.position.userScrollDirection;
  //     if (scrollDirection != ScrollDirection.idle) {
  //       double scrollEnd = _sc.offset +
  //           (scrollDirection == ScrollDirection.reverse
  //               ? _extraScrollSpeed
  //               : -_extraScrollSpeed);
  //       scrollEnd = min(_sc.position.maxScrollExtent,
  //           max(_sc.position.minScrollExtent, scrollEnd));
  //       _sc.jumpTo(scrollEnd);
  //     }
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // Watch the tag list
    _results = [...context.watch<SearchProvider>().searchResults];
    _suggestions = [...context.watch<SearchProvider>().suggestions];
    return ScaffoldPage(
      header: Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: Text("Tag Filters")),
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoSuggestBox(
                clearButtonEnabled: false,
                placeholder: "Keyword Search",
                onChanged: (t, r) {
                  context.read<SearchProvider>().updateKeywords(t, context);
                },
                items: _suggestions,
                trailingIcon: const Icon(FluentIcons.search_and_apps),
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
                        controller: _tagScroller, child: _tagListWidget),
                  ),
                ],
              )),
          Expanded(
            flex: 8,
            child: GridView.count(
              controller: _sc,
              crossAxisCount: 5,
              children: _results,
            ),
          ),
        ],
      ),
    );
  }
}
