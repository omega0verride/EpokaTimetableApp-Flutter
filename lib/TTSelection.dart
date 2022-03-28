import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import 'CustomDrawer.dart';
import 'auxiliaries/FileHandling.dart';
import 'auxiliaries/StartupConfig.dart';
import 'dataSource.dart';

class TTSelection extends StatefulWidget {
  List timetableOptions;
  DataSource dataSource;
  late bool firstTimeMode;
  bool allowNav = false;
  Config config;

  TTSelection({Key? key, required this.timetableOptions,
      required this.dataSource,
      required this.config})
      : super(key: key) {
    firstTimeMode = config.firstTimeMode;
  }

  @override
  TTSelectionState createState() => TTSelectionState();
}

class TTSelectionState extends State<TTSelection> {
  final GlobalKey<ScaffoldState> _key =
      GlobalKey(); // Create a key for navigation drawer
  late ListView optCards;
  late List<Widget> elements = [optCards];

  var url = 'timetable=';
  var filters = ["Courses", "Lecturers", "Classrooms"];
  var filtersAttributeVal = ["class", "lecturer", "room"];

  void setDefault() {
    dev.log(saveUrl(url).toString());
    readUrl().then((value) {
      dev.log("Saved url: " + value.toString());
    });
    widget.config.update();
    goToHomeScreen();
  }

  void goToHomeScreen() {
//    Navigator.of(context).pop();
    Navigator.pushNamed(context, '/today');
  }

  void selectFinal(String opt, int index) {
    url += opt;
    final _future = widget.dataSource
        .getTimetableData(selection: url); // get data of new selection
    elements = [
      optCards,
      Center(
          child: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  elements = [optCards];
                  Future.microtask(() => setState(() => widget.firstTimeMode
                      ? {setDefault()}
                      : elements.add(AlertDialog(
                          content:
                              const Text("Set this as your default Timetable?"),
                          actions: [
                            TextButton(
                              onPressed: () => setDefault(),
                              child: const Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () => goToHomeScreen(),
                              child: const Text('No'),
                            ),
                          ],
                        )))); // push after widget build !important
                  return const Text("");
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const CircularProgressIndicator();
              }))
    ];
    setState(() => {});
  }

  void selectOption(String opt, int index) {
    dev.log("nav: ---->" + widget.allowNav.toString());
    widget.allowNav = true;
    url += "&" + filtersAttributeVal[index] + "=";
    final _future = widget.dataSource.getSelectionOptions(
        selection: url,
        class_: filtersAttributeVal[
            index]); // has to be declared before the builder in order to avoid multiple unintentional calls
    elements = [
      optCards,
      Center(
          child: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  optCards = buildListView(snapshot.data as List, selectFinal);
                  Future.microtask(() => setState(() => elements = [
                        optCards
                      ])); // push after widget build !important
                  return const Text("");
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const CircularProgressIndicator();
              }))
    ];
    setState(() => {});
  }

  void selectTimetable(String opt, int index) {
    dev.log("nav: ---->" + widget.allowNav.toString());
    widget.allowNav = true;
    url += Uri.encodeQueryComponent(opt);
    dev.log(url);
    optCards = buildListView(filters, selectOption);
    setState(() => elements = [optCards]);
  }

  @override
  void initState() {
    super.initState();
    optCards = buildListView(widget.timetableOptions, selectTimetable);
    // get the list of the first selection (degree) from the data
  }

  Future<bool> showMessage() async {
    String msg;
    if (widget.config.firstTimeMode) {
      msg =
          'This is your first time config. Please choose your default Timetable.';
    } else {
      msg =
          "You can navigate through the menu. Turning back after is not implemented yet.";
    }
    var snackBar = SnackBar(
      content: Text(msg),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return false;
  }

  // not implemented correctly yet
  Future<bool> handleNav() async {
    dev.log("nav: -->" + widget.allowNav.toString());
    if (widget.allowNav == true) {
      return true;
    } else {
      return showMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // block navigation
        onWillPop: showMessage,
        child: Scaffold(
          drawer: widget.firstTimeMode == true ? null : const CustomDrawer(),
          key: _key,
          appBar: AppBar(
              backgroundColor: const Color.fromRGBO(21, 55, 99, 1),
              title: const Text("Timetable Selection")),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _key.currentState!.openDrawer();
            },
            child: const Icon(Icons.menu_open_outlined),
            backgroundColor: const Color(0xff152238),
          ),
          body: Stack(children: elements),
        ));
  }

  ListView buildListView(List data, var action) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      itemCount: data.length,
      itemBuilder: (context, index) {
        String opt = data[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildItem(index, context, opt, action),
          ],
        );
      },
    );
  }

  Widget buildItem(int index, BuildContext context, String opt, var action) {
    return IntrinsicHeight(
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => {action(opt, index)},
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Text(
                              opt,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  ?.copyWith(color: Colors.blue, fontSize: 15),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: const Icon(Icons.navigate_next),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
    );
  }
}
