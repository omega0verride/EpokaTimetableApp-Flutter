import 'dart:developer' as dev;

class CustomTime {
  int h = 0;
  int m = 0;

  CustomTime({required this.h, required this.m});

  CustomTime.fromString({required String time}) {
    try {
      h = int.parse(time.split(":")[0]);
      m = int.parse(time.split(":")[1]);
    } catch (e) {
      dev.log("Could not parse time from string! " + time);
    }
  }

  CustomTime.clone({required CustomTime time}) {
    h = time.h;
    m = time.m;
  }

  CustomTime addTime(CustomTime time) {
    int m_ = (m + time.m) % 60;
    int h_ = h + ((m + time.m) ~/ 60); // integer division in dart
    m = m_;
    h = h_;
    return this;
  }

  CustomTime addMinutes(int minutes) {
    int m_ = (m + minutes) % 60;
    int h_ = h + ((m + minutes) ~/ 60); // integer division in dart
    m = m_;
    h = h_;
    return this;
  }

  @override
  String toString() {
    String s = "";
    if (h < 10) {
      s += "0";
    }
    s += h.toString();
    s += ":";
    if (m < 10) {
      s += "0";
    }
    s += m.toString();
    return s;
  }
}
