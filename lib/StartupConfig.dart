import 'dart:developer' as dev;

import 'package:intl/intl.dart';

import 'auxiliaries/FileHandling.dart';

class Config {
  // map of days to get index
  Map days = {
    'Monday': 0,
    'Tuesday': 1,
    'Wednesday': 2,
    'Thursday': 3,
    'Friday': 4,
    'Saturday': 5,
    'Sunday': 0
  };
  var today =
      DateFormat('EEEE').format(DateTime.now()); // get today's day of week

  int dailyViewMode = 1; // 0 all in one, 1 one by one

  List<String> startupRoutes = ['/today', '/weekly'];
  int startupRouteIndex = 0;

  // check if the user has chosen a default timetable
  // the default timetable url is saved on AppData see auxiliaries/FileHandling
  String url = "";
  String nextRoute =
      '/select'; // by default force the user to choose the tt unless he has already chosen a default
  bool firstTimeMode =
      false; // if we are not able to read the file where the users tt selection is saved (or if he has not set a default) this bool becomes true

  Future<bool> update() async {
    // getting the url is more important than reading the settings file so I added some try catch blocks just in case
    try {
      var settings = await readJsonSettings();
      try {
        startupRouteIndex = settings['startupRouteIndex'];
        dev.log(
            "settings->Successfully set startupRouteIndex to $startupRouteIndex");
      } catch (e) {
        dev.log("Error getting value from json file startupRouteIndex. " +
            e.toString());
      }
      try {
        dailyViewMode = settings['dailyViewMode'];
        dev.log("settings->Successfully set dailyViewMode to $dailyViewMode");
      } catch (e) {
        dev.log("Error getting value from json file dailyViewMode. " +
            e.toString());
      }
    } catch (e) {
      dev.log("Unhandled Exception: " + e.toString());
    }

    return readUrl().then((value) {
      dev.log("Saved url: " + value.toString());
      if (value == "0") {
        dev.log("No saved data! Ask user for its Default TT.");
        firstTimeMode = true;
        return true;
      } else {
        url = value;
        nextRoute = startupRoutes[startupRouteIndex];
//        nextRoute = '/settings';
        firstTimeMode = false;
        return false;
      }
    });
  }

  Map generateJson() {
    return {
      'startupRouteIndex': startupRouteIndex,
      'dailyViewMode': dailyViewMode
    };
  }

  void saveSettings() {
    writeJsonSettings(generateJson());
  }
}
