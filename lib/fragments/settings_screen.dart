import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/settings_provider.dart';

// All the different settings, series, tags, add new videos, edit data on existing ones?
class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  final TextEditingController smallTimeTC = TextEditingController();
  final TextEditingController bigTimeTC = TextEditingController();

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
    return ScaffoldPage(
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Enable Mini Player  |  "),
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
                  const Text("Data Folder  |  "),
                  Text(context.watch<SettingsProvider>().dataFolder.path),
                  IconButton(
                      icon: const Icon(FluentIcons.open_folder_horizontal),
                      onPressed: () {
                        // WindowsKnownFolder.ComputerFolder
                        DirectoryPicker d = DirectoryPicker()
                          ..title = "Select Data Folder";
                        Directory? newD = d.getDirectory();
                        if (newD != null) {
                          context
                              .read<SettingsProvider>()
                              .setDataFolder(context, newD.path);
                        }
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Video Folder  |  "),
                  Text(context.watch<SettingsProvider>().videoFolder.path),
                  IconButton(
                      icon: const Icon(FluentIcons.open_folder_horizontal),
                      onPressed: () {
                        // WindowsKnownFolder.ComputerFolder
                        DirectoryPicker d = DirectoryPicker()
                          ..title = "Select Video Folder";
                        Directory? newD = d.getDirectory();
                        if (newD != null) {
                          context
                              .read<SettingsProvider>()
                              .setVideoFolder(newD.path);
                        }
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Thumbnail Folder  |  "),
                  Text(context.watch<SettingsProvider>().thumbFolder.path),
                  IconButton(
                      icon: const Icon(FluentIcons.open_folder_horizontal),
                      onPressed: () {
                        // WindowsKnownFolder.ComputerFolder
                        DirectoryPicker d = DirectoryPicker()
                          ..title = "Select Thumbnail Folder";
                        Directory? newD = d.getDirectory();
                        if (newD != null) {
                          context
                              .read<SettingsProvider>()
                              .setThumbFolder(newD.path);
                        }
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Play / Pause Hotkey  |  "),
                  Text(context.watch<SettingsProvider>().playPauseKey.keyLabel),
                  IconButton(
                      icon: const Icon(FluentIcons.keyboard_classic),
                      onPressed: () {
                        showHotkeyDialog(context, "Play / Pause",
                            context.read<SettingsProvider>().setPlayPauseKey);
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Small Skip Back Hotkey  |  "),
                  Text(context
                      .watch<SettingsProvider>()
                      .smallSkipBackKey
                      .keyLabel),
                  IconButton(
                      icon: const Icon(FluentIcons.keyboard_classic),
                      onPressed: () {
                        showHotkeyDialog(
                            context,
                            "Small Skip Back",
                            context
                                .read<SettingsProvider>()
                                .setSmallSkipBackKey);
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Small Skip Ahead Hotkey  |  "),
                  Text(context
                      .watch<SettingsProvider>()
                      .smallSkipAheadKey
                      .keyLabel),
                  IconButton(
                      icon: const Icon(FluentIcons.keyboard_classic),
                      onPressed: () {
                        showHotkeyDialog(
                            context,
                            "Small Skip Ahead",
                            context
                                .read<SettingsProvider>()
                                .setSmallSkipAheadKey);
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Big Skip Back Hotkey  |  "),
                  Text(context
                      .watch<SettingsProvider>()
                      .bigSkipBackKey
                      .keyLabel),
                  IconButton(
                      icon: const Icon(FluentIcons.keyboard_classic),
                      onPressed: () {
                        showHotkeyDialog(context, "Big Skip Back",
                            context.read<SettingsProvider>().setBigSkipBackKey);
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Big Skip Ahead Hotkey  |  "),
                  Text(context
                      .watch<SettingsProvider>()
                      .bigSkipAheadKey
                      .keyLabel),
                  IconButton(
                      icon: const Icon(FluentIcons.keyboard_classic),
                      onPressed: () {
                        showHotkeyDialog(
                            context,
                            "Big Skip Ahead",
                            context
                                .read<SettingsProvider>()
                                .setBigSkipAheadKey);
                      })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text("Small Skip Amount  |  "),
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
                  const Text("Big Skip Amount  |  "),
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
                        }
                      },
                    ),
                  ),
                  const Text(" seconds")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
