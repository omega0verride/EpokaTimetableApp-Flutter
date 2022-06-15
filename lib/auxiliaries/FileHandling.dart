import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> getLocalFile(String fileName) async {
  final path = await _localPath;
  return File('$path/$fileName');
}

Future<File> saveToFile(String filename, String str) async {
  final file = await getLocalFile(filename);
  return file.writeAsString(str);
}

Future<String> readFile(String fileName) async {
  try {
    final file = await getLocalFile(fileName);
    final contents = await file.readAsString(encoding: utf8);
    return contents;
  } catch (e) {
    dev.log("Error reading file $fileName: " + e.toString());
    return "0";
  }
}

Future<File> saveUrl(String url) async {
  return await saveToFile('url.txt', url);
}

Future<String> readUrl() async {
  return await readFile('url.txt');
}

Future<File> writeJsonSettings(Map data) async {
  dev.log("settings->Saved settings: $data");
  return await saveToFile('settings.json', jsonEncode(data));
}

Future<Map<String, dynamic>> readJsonSettings() async {
  String data_ = (await readFile('settings.json')).toString();
  if (data_ == "0") {
    return {};
  }
  try {
    dev.log("settings->Succesfully read the settings file: $data_");
    return jsonDecode(data_);
  } catch (e) {
    dev.log("Error decoding json $data_: " + e.toString());
    return {};
  }
}