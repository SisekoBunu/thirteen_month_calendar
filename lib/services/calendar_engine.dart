import '../models/calendar_type.dart';

abstract class CalendarEngine {
  CalendarType get type;

  String get displayName;

  DateTime get selectedGregorianDate;

  void selectGregorianDate(DateTime date);

  void selectCalendarDate({
    required int monthIndex,
    required int day,
  });

  void goToNextMonth();

  void goToPreviousMonth();

  List<String> getMonthNames();

  int getDaysInMonth(int monthIndex, int year);

  String getFormattedSelectedDate();

  String getMonthYearLabel();

  int getDisplayYear();

  int getSelectedMonthIndex();

  int getSelectedDay();

  int getTodayMonthIndex();

  int getTodayDay();

  List<String> getHolidaysForDate({
    required int year,
    required int monthIndex,
    required int? day,
  });

  List<String> getTimelineEventsForDate({
    required int year,
    required int monthIndex,
    required int? day,
  });
}
