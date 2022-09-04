import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import 'package:reference_library/fragments/library_screen.dart';
import 'package:reference_library/fragments/play_screen.dart';
import 'package:reference_library/fragments/search_screen.dart';
import 'package:reference_library/fragments/series_screen.dart';
import 'package:reference_library/fragments/settings_screen.dart';
import 'package:reference_library/providers/data_provider.dart';
import 'package:reference_library/providers/editing_provider.dart';
import 'package:reference_library/providers/navigation_provider.dart';
import 'package:reference_library/providers/playlist_provider.dart';
import 'package:reference_library/providers/search_provider.dart';
import 'package:reference_library/providers/settings_provider.dart';
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
    //await windowManager.setSize(const Size(1024, 720));
    await windowManager.maximize();
    await windowManager.setMinimumSize(const Size(1024, 720));
    //await windowManager.center();
    await windowManager.show();
    await windowManager.setPreventClose(false);
    await windowManager.setSkipTaskbar(false);
  });

  // Make sure the video player library is initialized
  DartVLC.initialize();

  // Start up the app
  runApp(const ReferenceLibrary());
}

// Widget containing the main app
// ignore: must_be_immutable
class ReferenceLibrary extends StatelessWidget {
  const ReferenceLibrary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Then setup the rest of the app
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => DataProvider()),
          ChangeNotifierProvider(create: (_) => PlaylistProvider()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => EditingProvider()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
        ],
        // Fluent main app
        child: FluentApp(
          title: "Video Reference Library",
          debugShowCheckedModeBanner: false,
          // Force dark mode
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          // App content
          home: const App(),
        ));
  }
}

// Stateful part of the main app
class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

// Build the main app / navigation. Wrap everything up in a listener for hotkeys?
class _AppState extends State<App> with WindowListener {
  @override
  Widget build(BuildContext context) {
    LogicalKeyboardKey playPause =
        context.watch<SettingsProvider>().playPauseKey;
    LogicalKeyboardKey smallSkipAhead =
        context.watch<SettingsProvider>().smallSkipAheadKey;
    LogicalKeyboardKey smallSkipBack =
        context.watch<SettingsProvider>().smallSkipBackKey;
    LogicalKeyboardKey bigSkipAhead =
        context.watch<SettingsProvider>().bigSkipAheadKey;
    LogicalKeyboardKey bigSkipBack =
        context.watch<SettingsProvider>().bigSkipBackKey;
    context.read<PlaylistProvider>().registerNextVideoEvent(context);
    return RawKeyboardListener(
      focusNode: context.watch<NavigationProvider>().mainAppFocus,
      autofocus: true,
      onKey: (event) {
        // Hotkey to pause or resume video
        if (event.isKeyPressed(playPause)) {
          context.read<PlaylistProvider>().playPause();
        }
        // Rewind 10 seconds
        else if (event.isKeyPressed(smallSkipBack)) {
          if (context.read<PlaylistProvider>().player.playback.isPlaying) {
            context.read<PlaylistProvider>().jumpTo(
                context.read<PlaylistProvider>().player.position.position! -
                    context.read<SettingsProvider>().smallSkipTime);
          }
        }
        // Fast Forward 10 seconds
        else if (event.isKeyPressed(smallSkipAhead)) {
          if (context.read<PlaylistProvider>().player.playback.isPlaying) {
            context.read<PlaylistProvider>().jumpTo(
                context.read<PlaylistProvider>().player.position.position! +
                    context.read<SettingsProvider>().smallSkipTime);
          }
        }
        // Rewind 30 seconds
        else if (event.isKeyPressed(bigSkipBack)) {
          if (context.read<PlaylistProvider>().player.playback.isPlaying) {
            context.read<PlaylistProvider>().jumpTo(
                context.read<PlaylistProvider>().player.position.position! -
                    context.read<SettingsProvider>().bigSkipTime);
          }
        }
        // Fast Forward 30 seconds
        else if (event.isKeyPressed(bigSkipAhead)) {
          if (context.read<PlaylistProvider>().player.playback.isPlaying) {
            context.read<PlaylistProvider>().jumpTo(
                context.read<PlaylistProvider>().player.position.position! +
                    context.read<SettingsProvider>().bigSkipTime);
          }
        }
      },
      child: NavigationView(
          // Top bar with the app name and windows buttons (min, max, quit)
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
          // Left side navigation bar
          pane: NavigationPane(
            // Hides the button that expands all the pane items to show titles, if they were set
            // but I want the slim hidden view all the time
            menuButton: Container(),

            // Keeps the compact style even with different window sizes
            displayMode: PaneDisplayMode.compact,

            /// Currently selected pane
            selected: context.watch<NavigationProvider>().index,

            // List of navigation icons
            items: [
              PaneItem(icon: const Icon(FluentIcons.library)),
              PaneItem(icon: const Icon(FluentIcons.playlist_music)),
              PaneItem(icon: const Icon(FluentIcons.search)),
              PaneItem(icon: const Icon(FluentIcons.play))
            ],

            // Update the index when a different item is selected
            // onChanged: (i) => setState(() => context
            //     .read<NavigationProvider>()
            //     .setIndex(i, context: context)),

            onChanged: (i) {
              setState(() => context
                  .read<NavigationProvider>()
                  .setIndex(i, context: context));
            },

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
                  // Page transition animations
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
                  // List of all the different panes, has to match with the icon
                  //   list above in the navigaion bar
                  children: [
                    LibraryScreen(
                        videoList: context.watch<DataProvider>().videos),
                    SeriesScreen(),
                    SearchScreen(),
                    const PlaybackScreen(),
                    SettingsScreen()
                  ]),
              // Check to see if the mini player should be hovering over everything
              (context.watch<NavigationProvider>().showMiniPlayer &&
                      context.watch<SettingsProvider>().enableMiniPlayer)
                  ? GestureDetector(
                      // Double tap mini player to go back to the main player
                      onDoubleTap: () {
                        context
                            .read<NavigationProvider>()
                            .goToPlayback(context: context);
                      },
                      // Keep mini player in bottom right corner
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
                  // Empty container if the mini player shouldn't be shown
                  //   It doesn't like me trying to set null instead.
                  : Container(),
            ],
          )),
    );
  }
}
