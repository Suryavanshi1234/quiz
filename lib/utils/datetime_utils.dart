import 'package:intl/intl.dart';

class DateTimeUtils {
  static final dateFormat = DateFormat("d MMM, y");

  static String minuteToHHMM(int totalMinutes, {bool? showHourAndMinute}) {
    String hh = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    String mm = (totalMinutes % 60).toString().padLeft(2, '0');

    bool showHourAndMinutePostText = showHourAndMinute ?? true;
    return "$hh:$mm ${(showHourAndMinutePostText ? "hh:mm" : "")}";
  }
}
