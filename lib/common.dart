import 'package:intl/intl.dart';

String convertDateTimeIntoAmPm(DateTime time) {
  return DateFormat('hh:mm a').format(time);
}

String convertDateToApiFormat(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

String convertIntoWeekFormat(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}
