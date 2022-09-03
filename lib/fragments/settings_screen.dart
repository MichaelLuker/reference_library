// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/providers/settings_provider.dart';
import 'package:reference_library/widgets/tags_widget.dart';

// All the different settings, series, tags, add new videos, edit data on existing ones?
class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  final TextEditingController smallTimeTC = TextEditingController();
  final TextEditingController bigTimeTC = TextEditingController();
  late TagList selectedTags;

  void showHotkeyDialog(
      BuildContext context, String keyLabel, Function updateKey) {
    showDialog(
        context: context,
        builder: (_) => RawKeyboardListener(
              autofocus: true,
              focusNode: FocusNode(),
              onKey: (event) {
                if (event.logicalKey == LogicalKeyboardKey.escape) {
                  return;
                }
                if (context
                    .read<SettingsProvider>()
                    .checkHotkey(event.logicalKey.keyId)) {
                  updateKey(event.logicalKey.keyId);
                  Navigator.pop(context);
                } else {
                  showSnackbar(
                      context,
                      Text(
                        "Error: Key already in use",
                        style: TextStyle(color: Colors.red),
                      ));
                }
              },
              child: ContentDialog(
                title: Text(
                  "Press any key to change $keyLabel\n\nOr Escape to cancel",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    smallTimeTC.text =
        context.watch<SettingsProvider>().smallSkipTime.inSeconds.toString();
    bigTimeTC.text =
        context.watch<SettingsProvider>().bigSkipTime.inSeconds.toString();
    FocusNode smallSkipFocus = FocusNode();
    FocusNode bigSkipFocus = FocusNode();
    selectedTags = TagList(selectedTags: [], editing: false);
    return ScaffoldPage(
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 155, child: Text("Enable Mini Player")),
                  const Text("  |  "),
                  ToggleSwitch(
                      checked:
                          context.watch<SettingsProvider>().enableMiniPlayer,
                      onChanged: (v) {
                        context.read<SettingsProvider>().setEnableMiniPlayer(v);
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 155, child: Text("Data Folder")),
                  const Text("  |  "),
                  IconButton(
                      icon: const Icon(FluentIcons.open_folder_horizontal),
                      onPressed: () async {
                        String? newD = await FilePicker.platform
                            .getDirectoryPath(
                                dialogTitle: "Select Data Folder");

                        if (newD != null) {
                          context
                              .read<SettingsProvider>()
                              .setDataFolder(context, newD);
                        }
                      }),
                  Text(context.watch<SettingsProvider>().dataFolder.path),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 155, child: Text("Video Folder")),
                  const Text("  |  "),
                  IconButton(
                      icon: const Icon(FluentIcons.open_folder_horizontal),
                      onPressed: () async {
                        String? newD = await FilePicker.platform
                            .getDirectoryPath(
                                dialogTitle: "Select Video Folder");

                        if (newD != null) {
                          context.read<SettingsProvider>().setVideoFolder(newD);
                        }
                      }),
                  Text(context.watch<SettingsProvider>().videoFolder.path),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 155, child: Text("Thumbnail Folder")),
                  const Text("  |  "),
                  IconButton(
                      icon: const Icon(FluentIcons.open_folder_horizontal),
                      onPressed: () async {
                        String? newD = await FilePicker.platform
                            .getDirectoryPath(
                                dialogTitle: "Select Thumbnail Folder");
                        if (newD != null) {
                          context.read<SettingsProvider>().setThumbFolder(newD);
                        }
                      }),
                  Text(context.watch<SettingsProvider>().thumbFolder.path),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(
                      width: 155, child: Text("Play / Pause Hotkey")),
                  const Text("  |  "),
                  IconButton(
                      icon: const Icon(FluentIcons.keyboard_classic),
                      onPressed: () {
                        showHotkeyDialog(context, "Play / Pause",
                            context.read<SettingsProvider>().setPlayPauseKey);
                      }),
                  Text(context.watch<SettingsProvider>().playPauseKey.keyLabel),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(
                      width: 155, child: Text("Small Skip Back Hotkey")),
                  const Text("  |  "),
                  IconButton(
                      icon: const Icon(FluentIcons.keyboard_classic),
                      onPressed: () {
                        showHotkeyDialog(
                            context,
                            "Small Skip Back",
                            context
                                .read<SettingsProvider>()
                                .setSmallSkipBackKey);
                      }),
                  Text(context
                      .watch<SettingsProvider>()
                      .smallSkipBackKey
                      .keyLabel),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(
                      width: 155, child: Text("Small Skip Ahead Hotkey")),
                  const Text("  |  "),
                  IconButton(
                      icon: const Icon(FluentIcons.keyboard_classic),
                      onPressed: () {
                        showHotkeyDialog(
                            context,
                            "Small Skip Ahead",
                            context
                                .read<SettingsProvider>()
                                .setSmallSkipAheadKey);
                      }),
                  Text(context
                      .watch<SettingsProvider>()
                      .smallSkipAheadKey
                      .keyLabel),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(
                      width: 155, child: Text("Big Skip Back Hotkey")),
                  const Text("  |  "),
                  IconButton(
                      icon: const Icon(FluentIcons.keyboard_classic),
                      onPressed: () {
                        showHotkeyDialog(context, "Big Skip Back",
                            context.read<SettingsProvider>().setBigSkipBackKey);
                      }),
                  Text(context
                      .watch<SettingsProvider>()
                      .bigSkipBackKey
                      .keyLabel),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(
                      width: 155, child: Text("Big Skip Ahead Hotkey")),
                  const Text("  |  "),
                  IconButton(
                      icon: const Icon(FluentIcons.keyboard_classic),
                      onPressed: () {
                        showHotkeyDialog(
                            context,
                            "Big Skip Ahead",
                            context
                                .read<SettingsProvider>()
                                .setBigSkipAheadKey);
                      }),
                  Text(context
                      .watch<SettingsProvider>()
                      .bigSkipAheadKey
                      .keyLabel),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 155, child: Text("Small Skip Amount")),
                  const Text("  |  "),
                  SizedBox(
                    width: 50,
                    child: TextBox(
                      focusNode: smallSkipFocus,
                      controller: smallTimeTC,
                      autofocus: false,
                      onEditingComplete: () {
                        int? s = int.tryParse(smallTimeTC.text);
                        if (s == null) {
                          showSnackbar(
                              context,
                              Text("Error: $s is NaN",
                                  style: TextStyle(color: Colors.red)));
                        } else {
                          context
                              .read<SettingsProvider>()
                              .setSmallSkipTime(int.parse(smallTimeTC.text));
                          smallSkipFocus.unfocus();
                          context
                              .read<NavigationProvider>()
                              .mainAppFocus
                              .requestFocus();
                        }
                      },
                    ),
                  ),
                  const Text(" seconds")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 155, child: Text("Big Skip Amount")),
                  const Text("  |  "),
                  SizedBox(
                    width: 50,
                    child: TextBox(
                      focusNode: bigSkipFocus,
                      controller: bigTimeTC,
                      autofocus: false,
                      onEditingComplete: () {
                        int? s = int.tryParse(bigTimeTC.text);
                        if (s == null) {
                          showSnackbar(
                              context,
                              Text("Error: $s is NaN",
                                  style: TextStyle(color: Colors.red)));
                        } else {
                          context
                              .read<SettingsProvider>()
                              .setBigSkipTime(int.parse(bigTimeTC.text));
                          bigSkipFocus.unfocus();
                          context
                              .read<NavigationProvider>()
                              .mainAppFocus
                              .requestFocus();
                        }
                      },
                    ),
                  ),
                  const Text(" seconds")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(color: Colors.grey[200]),
                              BoxShadow(
                                  color: Colors.grey[160],
                                  spreadRadius: -6,
                                  blurRadius: 6)
                            ]),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              controller: ScrollController(),
                              child: selectedTags,
                            ),
                          ),
                        )),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                          onPressed: () {
                            showDialog<String>(
                                context: context,
                                builder: (context) => ContentDialog(
                                      title: const Text(
                                          "Really delete selected tags?"),
                                      actions: [
                                        Button(
                                            onPressed: () {
                                              selectedTags.selectedTags
                                                  .forEach((element) {
                                                context
                                                    .read<DataProvider>()
                                                    .deleteTag(element);
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Confirm")),
                                        FilledButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Cancel"))
                                      ],
                                    ));
                          },
                          icon: const Icon(FluentIcons.delete)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
