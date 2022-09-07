// JCRUD => JSON CRUD => Javascript Object Notation Create Read Update Delete

import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:convert';

// ignore: camel_case_types
class jcrud {
  late final String _base;

  // Constructor, make sure the sent base folder exists
  jcrud(String base) {
    _base = base;
    Directory dataStore = Directory(_base);
    dataStore.create();
  }

  // Creates a new file
  void create(String fileName) async {
    File newFile = File("$_base/$fileName");
    // If the file doesn't exist then create it
    newFile.exists().then((e) {
      if (!e) {
        newFile.create();
      }
    });
  }

  // Reads the file
  Map<String, dynamic> read(String fileName) {
    File newFile = File("$_base/$fileName");
    //log(newFile.path);
    if (newFile.existsSync()) {
      String content = newFile.readAsStringSync();
      return jsonDecode(content);
    } else {
      // If the file doesn't exist return an empty map
      return {};
    }
  }

  // Read all files
  Map<String, dynamic> readAll() {
    Map<String, dynamic> res = {};
    for (FileSystemEntity f in Directory(_base).listSync().toList()) {
      if (f is File) {
        String fileName = basename(f.path);
        if (fileName != ".DS_Store") {
          res[fileName] = read(fileName);
        }
      }
    }
    return res;
  }

  // Writes to the file
  void update(String fileName, Map<String, dynamic> obj) async {
    File newFile = File("$_base/$fileName");
    newFile.exists().then((e) {
      // If the file doesn't exist create it first
      if (!e) {
        newFile.createSync();
      }
      newFile.writeAsString(jsonEncode(obj));
    });
  }

  // Deletes a file
  void deleteMeta(String fileName) async {
    File newFile = File("$_base/$fileName");
    newFile.exists().then((e) {
      if (e) {
        newFile.delete();
      }
    });
  }
}
