import 'dart:async';
import 'dart:developer' as dev;

import 'package:epokaTimetable/auxiliaries/StartupConfig.dart';
import 'package:epokaTimetable/dataSource.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  Config config;
  DataSource dataSource;

  LoadingScreen({required this.dataSource, required this.config, Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: config.update(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String nextRoute = config.nextRoute;
          dev.log("----------->" + nextRoute);
          dev.log("----------->" + config.url);
          return Scaffold(
              appBar: AppBar(
                title: const Text("Fetching Data"),
              ),
              body: Center(
                  child: FutureBuilder<Map>(
                future: dataSource.getTimetableData(selection: config.url),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Future.microtask(() => Navigator.pushNamed(context,
                        nextRoute)); // push after widget build !important
                    return const Text("");
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  // By default, show a loading spinner
                  return const CircularProgressIndicator();
                },
              )));
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
