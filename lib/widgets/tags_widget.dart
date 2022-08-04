import 'dart:developer' as dev;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';

class TagList extends StatefulWidget {
  TagList({
    Key? key,
    required this.selectedTags,
  }) : super(key: key);

  List<String> selectedTags;

  @override
  State<TagList> createState() => TagListState();
  // void updateSelectedTags(List<String> n) {
  //   selectedTags = n;
  //   TagListState.updateStateSelectedTags(n);
  // }
}

class TagListState extends State<TagList> {
  List<String> _tags = [];
  // Stores the state of if a tag is selected or not for visual updating
  final Map<String, bool> _chipSelect = {};

  // void updateStateSelectedTags(List<String> n) {
  //   for (String t in _tags) {
  //     bool selected;
  //     if (widget.selectedTags.contains(t)) {
  //       selected = true;
  //     } else {
  //       selected = false;
  //     }
  //     setState(() {
  //       _chipSelect[t] = selected;
  //     });
  //   }
  // }

  // Function called when a chip is selected, it updates the visual state and filter list
  void chipSelectCallback(String text, bool selected) {
    setState(() {
      bool updatedVal = selected ? false : true;
      _chipSelect[text] = updatedVal;
      if (updatedVal) {
        widget.selectedTags.add(text);
      } else {
        widget.selectedTags.removeWhere((element) => element == text);
      }
      dev.log("Selected Tags: ${widget.selectedTags.toString()}");
    });
  }

  // Builds the list of all tag chips
  List<Widget> buildChips(List<String> tags) {
    // If there's no values saved yet set them all to unselected
    bool init = false;
    if (_chipSelect.isEmpty) {
      setState(() {
        init = true;
      });
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
        if (widget.selectedTags.contains(t)) {
          selected = true;
        } else {
          selected = false;
        }
        setState(() {
          _chipSelect[t] = selected;
        });
      } else {
        selected = savedVal!;
      }
      r.add(Padding(
        padding: const EdgeInsets.all(4.0),
        child: TagChip(t, selected, chipSelectCallback),
      ));
    }
    dev.log("Chip States: ${_chipSelect.toString()}");
    return r;
  }

  @override
  Widget build(BuildContext context) {
    _tags = context.watch<DataProvider>().tags;
    return Wrap(
      children: buildChips(_tags),
    );
  }
}

// Custom chip to handle displaying a selected chip
class TagChip extends StatelessWidget {
  const TagChip(this.text, this.selected, this.callback, {Key? key})
      : super(key: key);
  final String text;
  final bool selected;
  final Function callback;
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
