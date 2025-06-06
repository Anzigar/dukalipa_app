/// Formats a date to YYYY-MM-DD for API requests
String formatDateForApi(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Calculates the date range for the current month
DateTimeRange getCurrentMonthRange() {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  return DateTimeRange(start: startOfMonth, end: endOfMonth);
}

/// Calculates the date range for the last 30 days
DateTimeRange getLast30DaysRange() {
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  return DateTimeRange(start: thirtyDaysAgo, end: now);
}

/// A class that represents a date range with a start and end date
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({
    required this.start,
    required this.end,
  });
}
