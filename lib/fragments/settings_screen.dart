import 'package:fluent_ui/fluent_ui.dart';

// All the different settings, series, tags, add new videos, edit data on existing ones?
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Center(
          child: Container(
        color: Colors.blue,
        child: const Text(
          "Settings Screen Header",
          style: TextStyle(color: Colors.white),
        ),
      )),
      content: Center(
          child: Container(
        color: Colors.red,
        child: const Text(
          "Settings Screen Content",
          style: TextStyle(color: Colors.white),
        ),
      )),
    );
  }
}
