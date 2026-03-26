import 'package:intl/intl.dart';

class AppDateFormatter {
  AppDateFormatter._();

  static String monthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);

  static String shortMonthDay(DateTime d) => DateFormat('MMM d').format(d);

  static String fullDate(DateTime d) =>
      DateFormat('EEEE, MMMM d, yyyy').format(d);
}
