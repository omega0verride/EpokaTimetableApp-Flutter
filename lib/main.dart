import 'dart:io';

import 'package:epokaTimetable/TTSelection.dart';
import 'package:flutter/material.dart';

import 'DailyTT.dart';
import 'Loading.dart';
import 'Settings.dart';
import 'StartupConfig.dart';
import 'WeeklyTT.dart';
import 'auxiliaries/CustomHttpOverrides.dart';
import 'dataSource.dart';

void main() {
  HttpOverrides.global = CustomHttpOverrides(); // override ssl cert req
  var _dataSource = DataSource();

  Config config = Config(); // config is initialized but the file is not read
  // the file is read in the LoadingScreen setup
  // flutter does not allow access to files before runApp;
  int index = config.days[config.today];

  runApp(
    MaterialApp(
      title: 'Epoka Timetable',
      initialRoute: '/loading',
      routes: {
//        '/': (context) =>  UIMain(),
        '/loading': (context) =>
            LoadingScreen(dataSource: _dataSource, config: config),
        '/today': (context) => DayView(
            config: config, weeks: _dataSource.data['weeks'], index: index),
        '/select': (context) => TTSelection(
            timetableOptions: _dataSource.data['timetableOptions'],
            dataSource: _dataSource,
            config: config),
        '/settings': (context) => Settings(config: config),
        '/weekly': (context) => WeekView(
            config: config, weeks: _dataSource.data['weeks'], index: index),
      },
    ),
  );
}
