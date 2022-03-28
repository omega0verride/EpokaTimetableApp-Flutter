import 'dart:developer' as dev;

import 'package:intl/intl.dart';

import 'FileHandling.dart';

class Config {
  // check if the user has chosen a default timetable
  // the default timetable url is saved on AppData see auxiliaries/FileHandling
  String url = "";
  String nextRoute = '/select';
  bool firstTimeMode = false;
  Map days = {
    'Monday': 0,
    'Tuesday': 1,
    'Wednesday': 2,
    'Thursday': 3,
    'Friday': 4,
    'Saturday': 5,
    'Sunday': 0
  };
  var today = DateFormat('EEEE').format(DateTime.now());

  Config() {
    dev.log(today);
    dev.log('/' + days[today].toString());
  }

  Future<bool> update() async {
    return readUrl().then((value) {
      dev.log("Saved url: " + value.toString());
      if (value == "0") {
        dev.log("No saved data! Ask user for its Default TT.");
        firstTimeMode = true;
        return true;
      } else {
        url = value;
//        nextRoute = '/weekly';
        nextRoute = '/today';
        firstTimeMode = false;
        return false;
      }
    });
  }
}
