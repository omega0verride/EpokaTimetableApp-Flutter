// main.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kindacode.com',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // This will be displayed on the screen
  String? _content;
  var t;

  // Find the Documents path
  Future<String> _getDirPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  // This function is triggered when the "Read" button is pressed
  Future<String> _readData() async {
    final dirPath = await _getDirPath();
    final myFile = File('$dirPath/url.txt');
    final data = await myFile.readAsString(encoding: utf8);
    setState(() {
      _content = data;
    });
    return data;
  }

  // TextField controller
  final _textController = TextEditingController();

  // This function is triggered when the "Write" buttion is pressed
  Future<void> _writeData() async {
    final _dirPath = await _getDirPath();

    final _myFile = File('$_dirPath/data.txt');
    // If data.txt doesn't exist, it will be created automatically

    await _myFile.writeAsString(_textController.text);
    _textController.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _readData().then((value) {
      log(value.toString());
      t = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.toString()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Enter your name'),
            ),
            ElevatedButton(
              child: const Text('Save to file'),
              onPressed: _writeData,
            ),
            const SizedBox(
              height: 150,
            ),
            Text(_content ?? 'Press the button to load your name',
                style: const TextStyle(fontSize: 24, color: Colors.pink)),
            ElevatedButton(
              child: const Text('Read my name from the file'),
              onPressed: _readData,
            )
          ],
        ),
      ),
    );
  }
}
