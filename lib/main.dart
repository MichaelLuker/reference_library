import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import 'package:reference_library/fragments/library_screen.dart';
import 'package:reference_library/fragments/play_screen.dart';
import 'package:reference_library/fragments/search_screen.dart';
import 'package:reference_library/fragments/series_screen.dart';
import 'package:reference_library/fragments/settings_screen.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:dart_vlc/dart_vlc.dart';

void main() async {
  // Make sure bindings are done
  WidgetsFlutterBinding.ensureInitialized();

  // Set window defaults
  await flutter_acrylic.Window.initialize();
  await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    //await windowManager.setSize(const Size(1400, 800));
    await windowManager.maximize();
    await windowManager.setMinimumSize(const Size(1024, 720));
    //await windowManager.center();
    await windowManager.show();
    await windowManager.setPreventClose(false);
    await windowManager.setSkipTaskbar(false);
  });

  DartVLC.initialize();

  // Start up the app
  runApp(const ReferenceLibrary());
}

// Widget containing the main app
class ReferenceLibrary extends StatelessWidget {
  const ReferenceLibrary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Once my providers are actually set up...
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DataProvider()),
          ChangeNotifierProvider(create: (_) => PlaylistProvider()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          // ChangeNotifierProvider(create: (_) => Settings()),
          // ChangeNotifierProvider(create: (_) => Data()),
          // ChangeNotifierProvider(create: (_) => Playlist()),
        ],
        child: FluentApp(
          title: "Video Reference Library",
          debugShowCheckedModeBanner: false,
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const App(),
        ));

    // return FluentApp(
    //   title: "Reference Library",
    //   debugShowCheckedModeBanner: false,
    //   darkTheme: ThemeData.dark(),
    //   themeMode: ThemeMode.dark,
    //   home: const App(),
    // );
  }
}

// Stateful part of the main app
class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WindowListener {
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.mediaPlayPause)) {
          log("Play/Pause Pressed");
          context.read<PlaylistProvider>().playPause();
        }
        // Rewind 10 seconds
        else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
        }
        // Fast Forward 10 seconds
        else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
        }
        // Rewind 30 seconds
        else if (event.isKeyPressed(LogicalKeyboardKey.keyJ)) {
        }
        // Fast Forward 30 seconds
        else if (event.isKeyPressed(LogicalKeyboardKey.keyL)) {}
      },
      child: NavigationView(
          // Top bar with the app name and
          appBar: NavigationAppBar(
            // Hides a button that looks like a back button
            automaticallyImplyLeading: false,
            title: () {
              // Allows the navigation app bar to act like the main windows title bar that's hidden
              return const DragToMoveArea(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text("Video Reference Library"),
                ),
              );
            }(),
            // Minimize, Maximize, and Close buttons
            actions: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 138,
                  height: 50,
                  child: WindowCaption(
                    brightness: ThemeData.dark().brightness,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          // Left size navigation bar
          pane: NavigationPane(
            // Hides the button that expands all the pane items to show titles, if they were set
            // but I want the slim hidden view all the time
            menuButton: Container(),

            /// Currently selected pane
            selected: context.watch<NavigationProvider>().index,

            // List of navigation items and their icons
            items: [
              PaneItem(icon: const Icon(FluentIcons.library)),
              PaneItem(icon: const Icon(FluentIcons.playlist_music)),
              PaneItem(icon: const Icon(FluentIcons.search)),
              PaneItem(icon: const Icon(FluentIcons.play))
            ],

            // Update the index when a different item is selected
            onChanged: (i) => setState(() => context
                .read<NavigationProvider>()
                .setIndex(i, context: context)),

            // Keeps the compact style even with different window sizes
            displayMode: PaneDisplayMode.compact,

            // Put the settings at the bottom of the nav with a separator
            footerItems: [
              PaneItemSeparator(),
              PaneItem(
                icon: const Icon(FluentIcons.settings),
              ),
            ],
          ),
          // Where the actual screen contents goes
          content: Stack(
            children: [
              NavigationBody(
                  animationDuration: const Duration(milliseconds: 450),
                  transitionBuilder: (Widget c, Animation<double> a) =>
                      EntrancePageTransition(
                        animation: a,
                        vertical: false,
                        reverse: true,
                        startFrom: 0.15,
                        child: c,
                      ),
                  index: context.watch<NavigationProvider>().index,
                  children: [
                    LibraryScreen(),
                    const SeriesScreen(),
                    const SearchScreen(),
                    const PlaybackScreen(),
                    const SettingsScreen()
                  ]),
              context.read<NavigationProvider>().showMiniPlayer
                  ? GestureDetector(
                      onDoubleTap: () {
                        context
                            .read<NavigationProvider>()
                            .goToPlayback(context: context);
                      },
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 426,
                          height: 240,
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                    width: 426,
                                    height: 240,
                                    child: material.Card(
                                        child: Video(
                                            player: context
                                                .watch<PlaylistProvider>()
                                                .player))),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(FluentIcons.chrome_close),
                                    onPressed: () {
                                      context
                                          .read<NavigationProvider>()
                                          .closeMiniPlayer(context: context);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          )),
    );
  }
}
