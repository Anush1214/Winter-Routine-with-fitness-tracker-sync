import 'package:intl/intl.dart';

class TimelineUtils {
  static const String winterArcStartDate = "2026-09-01";
  static const String winterArcEndDate = "2026-12-31";
  static const int totalWinterArcDays = 122;

  static String formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDisplayDate(DateTime date) {
    return DateFormat('EEE, MMM d').format(date).toUpperCase();
  }

  static int getDayNumber(DateTime date) {
    final start = DateTime(date.year, 9, 1);
    final diff = date.difference(start).inDays + 1;
    if (diff < 1) return 1;
    if (diff > totalWinterArcDays) return totalWinterArcDays;
    return diff;
  }

  static int getDaysRemaining(DateTime date) {
    final end = DateTime(date.year, 12, 31);
    final diff = end.difference(date).inDays;
    return diff < 0 ? 0 : diff;
  }

  static List<String> getAll122Days(int year) {
    final days = <String>[];
    DateTime current = DateTime(year, 9, 1);
    final end = DateTime(year, 12, 31);

    while (!current.isAfter(end)) {
      days.add(formatDateKey(current));
      current = current.add(const Duration(days: 1));
    }
    return days;
  }
}
