import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/url.txt');
}

Future<File> saveUrl(String url) async {
  final file = await _localFile;
  return file.writeAsString(url);
}

Future<String> readUrl() async {
  try {
    final file = await _localFile;
    final contents = await file.readAsString(encoding: utf8);
    return contents;
  } catch (e) {
    log("Error reading file: " + e.toString());
    return "0";
  }
}
