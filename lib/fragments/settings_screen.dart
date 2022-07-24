import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';

// All the different settings, series, tags, add new videos, edit data on existing ones?
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // UI for testing a custom localstore-like library
    return ScaffoldPage(
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [Center(child: Text("Settings Page"))],
        ),
      ),
    );
  }
}
