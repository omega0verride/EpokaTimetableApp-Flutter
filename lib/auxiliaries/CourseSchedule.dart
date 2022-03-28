import 'dart:ui';

import 'CustomTime.dart';

class CourseSchedule {
  int nCnt;
  int type;
  List<String> lecturers;
  String course;
  String classCode;
  CustomTime startTime;
  CustomTime endTime;
  Color color;
  List<Color> bgColors;
  List<CourseSchedule> hours = [];

  CourseSchedule(
      {required this.nCnt,
      required this.type,
      required this.lecturers,
      required this.course,
      required this.classCode,
      required this.color,
      required this.bgColors,
      required this.startTime,
      required this.endTime});

  @override
  String toString() {
    return "{course: " +
        course +
        ", nCnt: " +
        nCnt.toString() +
        ", type:" +
        type.toString() +
        ", classCode: " +
        classCode +
        ", lecturers: " +
        lecturers.toString() +
        ", startTime: " +
        startTime.toString() +
        ", endTime: " +
        endTime.toString() +
        "}";
  }
}
