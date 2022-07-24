import 'package:fluent_ui/fluent_ui.dart';

// All the different settings, series, tags, add new videos, edit data on existing ones?
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return ScaffoldPage(
    //   header: Center(
    //       child: Container(
    //     color: Colors.blue,
    //     child: const Text(
    //       "Settings Screen Header",
    //       style: TextStyle(color: Colors.white),
    //     ),
    //   )),
    //   content: Center(
    //       child: Container(
    //     color: Colors.red,
    //     child: const Text(
    //       "Settings Screen Content",
    //       style: TextStyle(color: Colors.white),
    //     ),
    //   )),
    // );

    // UI for testing a custom localstore-like library
    return ScaffoldPage(
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: Column(
                children: [
                  const Text("Tags (create / delete)"),
                  TextButton(child: const Text("Create"), onPressed: () {}),
                  TextButton(child: const Text("Delete"), onPressed: () {}),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text("Series (CRUD)"),
                  TextButton(child: const Text("Create"), onPressed: () {}),
                  TextButton(child: const Text("Read"), onPressed: () {}),
                  TextButton(child: const Text("Update"), onPressed: () {}),
                  TextButton(child: const Text("Delete"), onPressed: () {}),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text("Video (CRUD)"),
                  TextButton(child: const Text("Create"), onPressed: () {}),
                  TextButton(child: const Text("Read"), onPressed: () {}),
                  TextButton(child: const Text("Update"), onPressed: () {}),
                  TextButton(child: const Text("Delete"), onPressed: () {}),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text("Timestamp (CRUD)"),
                  TextButton(child: const Text("Create"), onPressed: () {}),
                  TextButton(child: const Text("Read"), onPressed: () {}),
                  TextButton(child: const Text("Update"), onPressed: () {}),
                  TextButton(child: const Text("Delete"), onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
