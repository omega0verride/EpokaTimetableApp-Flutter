import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'CustomDrawer.dart';
import 'auxiliaries/CourseSchedule.dart';
import 'auxiliaries/CustomTime.dart';
import 'auxiliaries/StartupConfig.dart';

class DayView extends StatefulWidget {
  List weeks;
  int index;
  late String day;
  var today = DateFormat('EEEE').format(DateTime.now());
  late String title;
  var hours = [];
  Config config;

  DayView(
      {required this.config,
      required this.weeks,
      required this.index,
      Key? key})
      : super(key: key) {
    List week = weeks[0]; // currently get the data only for the first week

    if (index > week.length - 1) {
      index = 0;
    }
    if (index < 0) {
      index = week.length - 1;
    }

    day = week[index][0];
    hours = week[index][1];
    if (today == day) {
      title = day + " (Today)";
    } else if (today == "Sunday" && day == "Monday") {
      title = day + (" (Tomorrow)");
    } else {
      title = day;
    }
    dev.log(index.toString());
  }

  @override
  DayViewState createState() => DayViewState();
}

class DayViewState extends State<DayView> {
  final GlobalKey<ScaffoldState> _key =
      GlobalKey(); // Create a key for navigation drawer

  void prevDay() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayView(
            config: widget.config,
            weeks: widget.weeks,
            index: widget.index - 1),
      ),
    );
  }

  void nextDay() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayView(
            config: widget.config,
            weeks: widget.weeks,
            index: widget.index + 1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
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
            iconTheme: Theme.of(context).iconTheme,
            flexibleSpace: GestureDetector(onPanUpdate: (details) {
              if (details.delta.dx > 0) {
                prevDay();
              }
              // Swiping in left direction.
              if (details.delta.dx < 0) {
                nextDay();
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
                      prevDay();
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
                      nextDay();
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
        body: GestureDetector(
          // add swipe gestures to body
          onPanUpdate: (details) {
            if (details.delta.dx > 0) {
              prevDay();
            }
            // Swiping in left direction.
            if (details.delta.dx < 0) {
              nextDay();
            }
          },
          child: buildListView(),
        ),
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      itemCount: widget.hours.length,
      itemBuilder: (context, index) {
        CourseSchedule h = widget.hours[index];
        bool showHeader = true;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
//            showHeader
//                ? Container(
//              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//              child: Text(
//                h.course,
//                style: Theme.of(context).textTheme.subtitle2?.copyWith(
//                  color: Theme.of(context).primaryColor,
//                  fontWeight: FontWeight.bold,
//                ),
//              ),
//            )
//                : Offstage(),
            buildItem(index, context, h.startTime, h.endTime, h),
          ],
        );
      },
    );
  }

  Widget buildItem(int index, BuildContext context, CustomTime startTime,
      CustomTime endTime, CourseSchedule h) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(width: 10),
          buildLine(index, context, h.nCnt),
          buildTime(index, context, h),
          Expanded(
            flex: 1,
            child: buildItemInfo(h, context),
          ),
        ],
      ),
    );
  }

  Card buildItemInfo(CourseSchedule h, BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: h.bgColors),
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 40.0 * h.nCnt,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                h.course,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.subtitle2?.copyWith(
                    color: h.color, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Row(children: [
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(
                    h.classCode,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        ?.copyWith(color: h.color, fontSize: 13),
                  ),
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(right: 4),
                  child: h.lecturers.isNotEmpty
                      ? (h.lecturers.length == 1
                          ? Text(h.lecturers[0],
                              style: Theme.of(context)
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

  Column buildLine(int index, BuildContext context, int cnt) {
    List<Widget> list = <Widget>[];
    for (int i = 0; i < cnt; i++) {
      list.add(Container(
        width: 6,
        height: 10,
        child: Column(
          children: [
            DecoratedBox(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle)),
          ],
        ),
      ));
      list.add(Expanded(
        flex: 1,
        child: Container(
          width: 2,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ));
    }
    return Column(mainAxisSize: MainAxisSize.max, children: list);
  }

  Column buildTime(int index, BuildContext context, CourseSchedule h) {
    List<Widget> list = <Widget>[];
    for (CourseSchedule s in h.hours) {
      list.add(Expanded(
        flex: 1,
        child: Container(),
      ));
      list.add(Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        child: Text(
          s.startTime.toString(),
          style: Theme.of(context).textTheme.subtitle2?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ));
      list.add(const SizedBox(
        height: 5,
      ));
      list.add(Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        child: Text(
          s.endTime.toString(),
          style: Theme.of(context).textTheme.subtitle2?.copyWith(
                // color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ));
      list.add(Expanded(
        flex: 1,
        child: Container(),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: list,
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
