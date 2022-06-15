import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'dart:developer' as dev;

import 'CustomDrawer.dart';
import 'StartupConfig.dart';
import 'auxiliaries/CourseSchedule.dart';
import 'auxiliaries/CustomTime.dart';


class WeekView extends StatefulWidget {
  List weeks;
  late List week;
  int index;
  late String dayName;
  late List dayData;
  var today = DateFormat('EEEE').format(DateTime.now());
  late String title;
  List<CourseSchedule> hours = [];
  Config config;

  WeekView(
      {required this.config,
      required this.weeks,
      required this.index,
      Key? key})
      : super(key: key) {
    // weeks.length represents n.o weeks, have not tested cases when the tt displays 2 weeks like during exams
    if (index > weeks.length - 1) {
      index = 0;
    }
    if (index < 0) {
      index = weeks.length - 1;
    }
    title = "Week " + (index + 1).toString();
    week = weeks[index];
    dev.log(index.toString());
    dev.log(weeks.toString());
  }

  @override
  WeekViewState createState() => WeekViewState();
}

class WeekViewState extends State<WeekView> {
  final GlobalKey<ScaffoldState> _key =
      GlobalKey(); // Create a key for navigation drawer

  void prevWeek() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WeekView(
                config: widget.config,
                weeks: widget.weeks,
                index: widget.index - 1),
      ),
    );
  }

  void nextWeek() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WeekView(
                config: widget.config,
                weeks: widget.weeks,
                index: widget.index + 1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    for (List day in widget.week) {
      widget.dayName = day[0];
      widget.hours = day[1];
      break;
    }
//    dev.log(widget.week.toString());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        drawer: const CustomDrawer(),
        key: _key,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff152238),
            iconTheme: Theme
                .of(context)
                .iconTheme,
            flexibleSpace: GestureDetector(onPanUpdate: (details) {
              if (details.delta.dx > 0) {
                prevWeek();
              }
              // Swiping in left direction.
              if (details.delta.dx < 0) {
                nextWeek();
              }
            }),
            title: Row(
              children: [
                Container(
                  height: 60.0,
                  width: 40.0,
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left_outlined),
                    iconSize: 40,
                    color: Colors.white,
                    onPressed: () {
                      prevWeek();
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Center(
                  child: Text(
                    widget.title,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Container(
                  height: 60.0,
                  width: 40.0,
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_right_outlined),
                    iconSize: 40,
                    color: Colors.white,
                    onPressed: () {
                      nextWeek();
                    },
                  ),
                ),
              ],
            )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _key.currentState!.openDrawer();
          },
          child: const Icon(Icons.menu_open_outlined),
          backgroundColor: Color(0xff152238),
        ),
        body: buildListView(),
//        GestureDetector(
//          // add swipe gestures to body
//          onPanUpdate: (details) {
//            if (details.delta.dx > 0) {
//              prevWeek();
//            }
//            // Swiping in left direction.
//            if (details.delta.dx < 0) {
//              nextWeek();
//            }
//          },
//          child: buildListView(),
//        ),
      ),
    );
  }

  Row buildTimeHeader(BuildContext context) {
    List<Widget> timeLabels = [];
    timeLabels.add(Container(
        alignment: Alignment.center,
        width: 100,
        height: 60,
        child: Text("Time",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))));
    CustomTime currentTime = CustomTime(h: 8, m: 45);
    for (int i = 0; i < 12; i++) {
      timeLabels.add(Container(
          alignment: Alignment.center,
          width: 148,
          child: Text(
              currentTime.toString() +
                  "-" +
                  currentTime.addMinutes(45).toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))));
      currentTime.addMinutes(15);
    }
    return Row(
      children: timeLabels,
    );
  }

  Zoom buildListView() {
    var v = Container(
      child: Column(children: [
        buildTimeHeader(context),
        for (int i = 0; i < widget.week.length; i++)
          IntrinsicHeight(
              child: Row(
//                  crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      width: 100,
                      child: Text(widget.week[i][0],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold))),
                  for (int j = 0; j < widget.week[i][1].length; j++)
                    buildItemInfo(widget.week[i][1][j], context),
                ],
              ))
      ]),
    );
    return Zoom(
        maxZoomWidth: 2000,
        maxZoomHeight: 1100,
        backgroundColor: Colors.black,
        child: v);
  }

  Card buildItemInfo(CourseSchedule h, BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: 140.0 * h.nCnt + 8 * (h.nCnt - 1),
//        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: h.bgColors),
        ),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                h.course,
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle2
                    ?.copyWith(
                    color: h.color, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Expanded(flex: 1, child: Container()),
            Row(children: [
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(
                    h.classCode,
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle2
                        ?.copyWith(color: h.color, fontSize: 13),
                  ),
                ),
              ),
              Container(
                  alignment: Alignment.bottomLeft,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: h.lecturers.isNotEmpty
                      ? (h.lecturers.length == 1
                      ? Text(h.lecturers[0],
                      style: Theme
                          .of(context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(color: h.color, fontSize: 13))
                      : IconButton(
                      onPressed: () =>
                      {buildLecturersCard(h.lecturers)},
                      icon: const Icon(Icons.person,
                          color: Colors.black38)))
                      : Container()),
            ])
          ],
        ),
      ),
    );
  }

  void buildLecturersCard(List<String> elements) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(10),
            content: Container(
              width: 60,
              height: elements.length * 20 + 10,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 4),
                itemCount: elements.length,
                itemBuilder: (context, index_) {
                  return Column(
                    children: <Widget>[
                      Center(
                        child: Text(
                          elements[index_],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            contentPadding: EdgeInsets.only(top: 10, bottom: 10),
          );
        });
  }
}
