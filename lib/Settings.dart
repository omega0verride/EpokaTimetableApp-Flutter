import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import 'CustomDrawer.dart';
import 'StartupConfig.dart';

class Settings extends StatefulWidget {
  Config config;

  Settings({Key? key, required this.config}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final GlobalKey<ScaffoldState> _key =
      GlobalKey(); // Create a key for navigation drawer
  int val = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // block navigation
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const CustomDrawer(),
        key: _key,
        appBar: AppBar(
            backgroundColor: const Color.fromRGBO(21, 55, 99, 1),
            title: const Text("Settings")),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _key.currentState!.openDrawer();
          },
          child: const Icon(Icons.menu_open_outlined),
          backgroundColor: const Color(0xff152238),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                "Daily View Mode",
                style: Theme.of(context).textTheme.subtitle2?.copyWith(
                    color: Color.fromRGBO(15, 27, 38, 0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            buildRadioChoice("All In One", 0, widget.config.dailyViewMode,
                changeDailyViewMode),
            buildRadioChoice("One by One", 1, widget.config.dailyViewMode,
                changeDailyViewMode),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                "Startup",
                style: Theme.of(context).textTheme.subtitle2?.copyWith(
                    color: Color.fromRGBO(15, 27, 38, 0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            buildRadioChoice(
                "Today", 0, widget.config.startupRouteIndex, changeStartupTab),
            buildRadioChoice("Weekly Calendar", 1,
                widget.config.startupRouteIndex, changeStartupTab),
          ],
        ),
      ),
    );
  }

  void changeDailyViewMode(int value) {
    setState(() {
      widget.config.dailyViewMode = value;
      widget.config.saveSettings();
    });
  }

  void changeStartupTab(int value) {
    setState(() {
      widget.config.startupRouteIndex = value;
      widget.config.saveSettings();
    });
  }

  GestureDetector buildRadioChoice(text, int value_, groupValue, func) {
    return GestureDetector(
      onTap: () => func(value_),
      child: Row(children: <Widget>[
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
              color: Colors.white70,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      child: Text(
                        text,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            ?.copyWith(color: Colors.blue, fontSize: 15),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Radio(
                      value: value_,
                      groupValue: groupValue,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        dev.log(value.toString());
                        dev.log("groupValue: " + groupValue.toString());
                        setState(() {
                          func(value_);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
