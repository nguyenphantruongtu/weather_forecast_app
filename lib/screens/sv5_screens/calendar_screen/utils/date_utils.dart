import 'package:intl/intl.dart';

class CalendarDateUtils {
  const CalendarDateUtils._();

  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String dayKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(normalize(date));
  }

  static String monthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(normalize(date));
  }

  static List<DateTime> daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final list = <DateTime>[];
    for (var day = 1; day <= last.day; day++) {
      list.add(DateTime(first.year, first.month, day));
    }
    return list;
  }
}
