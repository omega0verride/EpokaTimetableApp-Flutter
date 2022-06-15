import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'auxiliaries/CourseSchedule.dart';
import 'auxiliaries/CustomTime.dart';

class DataSource {
  late Map<String, String> _headers;

  final url = "https://epoka.edu.al/timetable";

  final uas = [
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10; rv:33.0) Gecko/20100101 Firefox/33.0",
    "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36",
    "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36"
  ];

  Map data = {};

  DataSource() {
    var rand = Random();
    var ua = uas[rand.nextInt(uas.length)];
    _headers = {
      'user-agent': ua,
      'referer': "https://epoka.edu.al/timetable",
      'content-type': "application/x-www-form-urlencoded"
    };
  }

  // make get request to get json data
  Future<Map> getTimetableData({required selection}) async {
    return post(Uri.parse(url), body: selection, headers: _headers)
        .then((Response response) {
      var _data = response.body;
      var rawData = scrapeData(data: _data.toString());
      data['timetableOptions'] = rawData['timetableOptions'];
      data['weeks'] = [];

      // dev.log(rawData["timetableOptions"].toString());
      for (int i = 0; i < rawData['weeks'].length; i++) {
        data['weeks'].add(createWeeklyOrganizedData(week: rawData['weeks'][i]));
      }
      return data;
    });
  }

  List<List> createWeeklyOrganizedData({required week}) {
    List<List> days = [];
    List daySchedule;
    for (var day_ in week) {
      String dayName = day_[0];
      daySchedule = day_[1];
      CustomTime currentTime = CustomTime(h: 8, m: 45);
      List<CourseSchedule> hours = [];
      for (int i = 0; i < daySchedule.length; i++) {
        CourseSchedule schedule;
        int type = daySchedule[i]['type'];
        if (type == 0) {
          schedule = CourseSchedule(
              nCnt: 1,
              type: 0,
              lecturers: [],
              course: "Empty Hour",
              classCode: '',
              color: const Color.fromRGBO(255, 255, 255, 1),
              bgColors: const [
                Color.fromRGBO(255, 255, 255, 1),
                Color.fromRGBO(255, 255, 255, 1)
              ],
              startTime: CustomTime.clone(time: currentTime),
              endTime: CustomTime.clone(time: currentTime).addMinutes(45));
          schedule.hours.add(schedule);
          currentTime.addMinutes(45 + 15);
        } else {
          var col = daySchedule[i]['color'];
          var color;
          var bgColors;

          if (col.length == 0) {
            color = const Color.fromRGBO(0, 127, 0, 1);
            bgColors = const [
              Color.fromRGBO(23, 91, 155, 0.20),
              Color.fromRGBO(228, 110, 13, 0.20)
            ];
          } else {
            try {
              color = Color.fromRGBO(col[0], col[1], col[2], 1);
              bgColors = [
                Color.fromRGBO(col[0], col[1], col[2], col[3].toDouble()),
                Color.fromRGBO(col[0], col[1], col[2], col[3].toDouble())
              ];
            } catch (e) {
              dev.log(e.toString());
              color = const Color.fromRGBO(20, 127, 0, 1);
              bgColors = const [Colors.green, Colors.teal];
            }
          }
          schedule = CourseSchedule(
              nCnt: daySchedule[i]['nCnt'],
              type: 1,
              lecturers: daySchedule[i]['lecturers'],
              course: daySchedule[i]['course'],
              classCode: daySchedule[i]['classCode'],
              color: color,
              bgColors: bgColors,
              startTime: CustomTime.clone(time: currentTime),
              endTime: CustomTime.clone(time: currentTime).addMinutes(
                  45 * (daySchedule[i]['nCnt'] as int) +
                      15 * (daySchedule[i]['nCnt'] - 1 as int)));

          for (int j = 0; j < daySchedule[i]['nCnt']; j++) {
            CourseSchedule tmp = CourseSchedule(
                nCnt: 1,
                type: 1,
                lecturers: daySchedule[i]['lecturers'],
                course: daySchedule[i]['course'],
                classCode: daySchedule[i]['classCode'],
                color: color,
                bgColors: bgColors,
                startTime: CustomTime.clone(time: currentTime),
                endTime: CustomTime.clone(time: currentTime).addMinutes(45),
                );
            tmp.hours.add(tmp);
            schedule.hours.add(tmp);
            currentTime.addMinutes(45 + 15);
          }
        }
        hours.add(schedule);
      }
      days.add([dayName, hours]);
    }
//    dev.log(days.toString());
    return days;
  }

  // note that the website does not have an API so we are just scraping data from it
  // this is not reliable
  Map scrapeData({required data}) {
    var soup = BeautifulSoup(data);

    // find available timetables to select
    var timetableOptions = [];
    var timetableOptions_ =
        soup.findAll('select', class_: 'timetable')[0].findAll('option');
//    dev.log(timetableOptions_.toString());
    for (Bs4Element option in timetableOptions_) {
      timetableOptions.add(option['value'].toString());
    }

    //get table and scrape the lectures from it
    // var table = soup.find('table');
    // var tHead_ = table!.find('thead');
    // var tBody_ = table.find('tbody');

    var tHead_ = soup.find('thead');
    var tBody_ = soup.find('tbody');

    var intervals_ = tHead_!.find('tr');

    var days_ = tBody_!.findAll('tr');


    var weeks_ = []; // I am not sure if during exams (when 2 weeks are showed)

    if (days_.length>6){
      days_.removeAt(0); // first row is week name
      days_.removeAt(6); // first row is week name
      weeks_.add(days_.sublist(0, 6));
      weeks_.add(days_.sublist(6, 12));
    }
    else{
      weeks_.add(days_.sublist(0, 6));
    }


    // dev.log("<start>");
    // dev.log(weeks_[0].toString());
    // dev.log("<end>");

    days_=weeks_[0];
    // they are showed as 2 tables or more rows are added to the table

    var weeks=[];
    for (var week in weeks_){
      var days = [];
      // dev.log(week.toString());
      for (Bs4Element day in week) {
        var hours_ = day.findAll('td');
//       dev.log("hours: "+hours_.toString().replaceAll("\n", "").replaceAll(" ", ""));
        var hours = [];
        for (var h in hours_) {
          Map hourData;
          if (h['style'] == '') {
            // empty hours have no style
            hourData = {
              'nCnt': 1,
              'type': 0,
              'lecturers': [],
              'course': null,
              'classCode': null,
              'color': null
            };
          } else {
            // dev.log(h.toString());
            var lecturersDivs = h.findAll('div', class_: "lect-card");
            var lecturers_ = [];
            for (var lct in lecturersDivs) {
              // some courses have 2 lecturers split by a
              lecturers_.addAll(lct.findAll(
                  'li')); // if there are more than 1 they are added as <li>
              if (lecturers_.isEmpty) {
                lecturers_.add(lct);
              } // otherwise it is a simple div
            }
            List<String> lecturers = [];
            for (var l in lecturers_) {
              // get text from those tags and trim it
              lecturers.add(l.getText().trimRight().trimLeft());
            }

            var elements = h.findAll('div');
            var color = [];
            try {
              var color_ = h['style']
                  .toString()
                  .split(");")[0]
                  .split(" rgba(")[1]
                  .split(
                  ","); // supposing the site is using the same format and all colors are rgba
              for (int i = 0; i < 3; i++) {
                color.add(int.parse(color_[i]));
              }
              color.add(double.parse(color_[3].toString()).toDouble());
            } catch (e) {
              dev.log(e.toString());
              color = [];
            }

            var cnt = 1;
            try {
              cnt = int.parse(h['colspan'].toString());
            } catch (e) {
              dev.log(h.toString());
              dev.log(e.toString());
            }
            hourData = {
              'nCnt': cnt,
              'type': 1,
              'lecturers': lecturers,
              'course': elements[0].getText().trimLeft().trimRight(),
              'classCode': elements[2].getText().trimLeft().trimRight(),
              'color': color
            };
          }
          // dev.log(hourData.toString());
          hours.add(hourData);
        }
        days.add([day.find('th')?.getText().trimRight().trimLeft(), hours]);
        // dev.log(days[days.length-1].toString());
      }
      weeks.add(days);
    }

   // dev.log(jsonEncode({'timetableOptions': timetableOptions, 'tt':weeks}));
    return {
      'timetableOptions': timetableOptions,
      'weeks': weeks
    };
  }

  // get available courses of a timetable
  Future<List> getSelectionOptions(
      {required selection, required class_}) async {
    return post(Uri.parse(url), body: selection, headers: _headers)
        .then((Response response) {
      var _data = response.body;
      var soup = BeautifulSoup(_data);
      // find available classes to select
      List classOptions = [];
      var classOptions_ =
          soup.findAll('select', class_: class_)[0].findAll('option');
//    dev.log(timetableOptions_.toString());
      for (Bs4Element option in classOptions_) {
        String val = option['value'].toString();
        if ("" != val) classOptions.add(val);
      }
      // dev.log(classOptions_.toString());
      // dev.log(classOptions.toString());
      return classOptions;
    });
  }
// sample data of SWE-2 2022 spring timetable

}

// faced some "robot" issues during testing the site blocked automated requests, this is not an issue in real devices
//  final cookies = {
//    'visid_incap_2578667': 'Hp1VknXkSWe/TlbdG1zQnnbgx2AAAAAAQUIPAAAAAADiOC2iDD0ueuqeVGbKmv9G',
//    'incap_ses_1344_2578667': 'A9i8eQrZeC+1nfWdR9mmEmnDPGIAAAAAHjgx4fZi9n7SGPiNN8R8vQ==',
//    'incap_ses_1211_2578667': 'vSzYBvancUIx4OHapVbOEGHOPGIAAAAAu1YGcoIhqyeJUMts2qGx1A=='
//  };

// all cookies
//  final cookies = {'visid_incap_2578667': 'Hp1VknXkSWe/TlbdG1zQnnbgx2AAAAAAQUIPAAAAAADiOC2iDD0ueuqeVGbKmv9G',
//              'incap_ses_1344_2578667': 'A9i8eQrZeC+1nfWdR9mmEmnDPGIAAAAAHjgx4fZi9n7SGPiNN8R8vQ==',
//              'incap_ses_1211_2578667': 'vSzYBvancUIx4OHapVbOEGHOPGIAAAAAu1YGcoIhqyeJUMts2qGx1A==',
//               '__utma': '229837128.602774191.1596009437.1647818999.1648149357.374',
//               '__utmz': '229837128.1647645313.372.57.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided)',
//              '__utmc': '229837128',
//               '__utmt': '1',
//              '__utmb': '229837128.9.10.1648149357'};
