import 'dart:io';

import 'package:epokaTimetable/TTSelection.dart';
import 'package:flutter/material.dart';

import 'DailyTT.dart';
import 'Loading.dart';
import 'WeeklyTT.dart';
import 'auxiliaries/CustomHttpOverrides.dart';
import 'auxiliaries/StartupConfig.dart';
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
        '/weekly': (context) => WeekView(
            config: config, weeks: _dataSource.data['weeks'], index: index),
        '/0': (context) => DayView(
            config: config, weeks: _dataSource.data['weeks'], index: index),
        '/1': (context) => DayView(
            config: config, weeks: _dataSource.data['weeks'], index: index),
        '/2': (context) => DayView(
            config: config, weeks: _dataSource.data['weeks'], index: index),
        '/3': (context) => DayView(
            config: config, weeks: _dataSource.data['weeks'], index: index),
        '/4': (context) => DayView(
            config: config, weeks: _dataSource.data['weeks'], index: index),
        '/5': (context) => DayView(
            config: config, weeks: _dataSource.data['weeks'], index: index),
      },
    ),
  );
}
