import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/calendar_type.dart';
import 'calendar_engine.dart';
import 'gregorian_calendar_engine.dart';
import 'christian_calendar_engine.dart';
import 'islamic_calendar_engine.dart';
import 'thirteen_month_calendar_engine.dart';

class CalendarManager extends ChangeNotifier {
  static const String _startupCalendarKey = 'startup_calendar';
  static const String _hasChosenStartupCalendarKey = 'has_chosen_startup_calendar';

  final SharedPreferencesAsync _prefs;

  CalendarType _activeType;

  final Map<CalendarType, CalendarEngine> _engines = {
    CalendarType.gregorian: GregorianCalendarEngine(),
    CalendarType.christian: ChristianCalendarEngine(),
    CalendarType.islamic: IslamicCalendarEngine(),
    CalendarType.thirteenMonth: ThirteenMonthCalendarEngine(),
  };

  final Map<CalendarType, int> _selectedMonthIndex = {
    CalendarType.gregorian: 0,
    CalendarType.christian: 0,
    CalendarType.islamic: 0,
    CalendarType.thirteenMonth: 0,
  };

  final Map<CalendarType, int?> _selectedDay = {
    CalendarType.gregorian: null,
    CalendarType.christian: null,
    CalendarType.islamic: null,
    CalendarType.thirteenMonth: null,
  };

  bool _shouldPromptForStartupCalendar;

  CalendarManager._({
    required SharedPreferencesAsync prefs,
    required CalendarType activeType,
    required bool shouldPromptForStartupCalendar,
  })  : _prefs = prefs,
        _activeType = activeType,
        _shouldPromptForStartupCalendar = shouldPromptForStartupCalendar;

  static Future<CalendarManager> create() async {
    final prefs = SharedPreferencesAsync();

    final savedCalendar = await prefs.getString(_startupCalendarKey);
    final hasChosen = await prefs.getBool(_hasChosenStartupCalendarKey) ?? false;

    final activeType = _calendarTypeFromStorage(savedCalendar) ?? CalendarType.gregorian;

    final manager = CalendarManager._(
      prefs: prefs,
      activeType: activeType,
      shouldPromptForStartupCalendar: !hasChosen,
    );

    manager._initializeCalendarsToToday();
    return manager;
  }

  void _initializeCalendarsToToday() {
    final today = DateTime.now();

    for (final entry in _engines.entries) {
      final engine = entry.value;
      final type = entry.key;

      engine.selectGregorianDate(today);
      _selectedMonthIndex[type] = engine.getTodayMonthIndex();
      _selectedDay[type] = null;
    }
  }

  CalendarType get activeType => _activeType;

  CalendarEngine get activeEngine => _engines[_activeType]!;

  CalendarEngine getEngine(CalendarType type) => _engines[type]!;

  List<CalendarType> get availableCalendars => CalendarType.values;

  int get selectedMonthIndex => _selectedMonthIndex[_activeType] ?? 0;

  int? get selectedDay => _selectedDay[_activeType];

  bool get shouldPromptForStartupCalendar => _shouldPromptForStartupCalendar;

  Future<void> dismissStartupCalendarPrompt() async {
    _shouldPromptForStartupCalendar = false;
    await _prefs.setBool(_hasChosenStartupCalendarKey, true);
    notifyListeners();
  }

  Future<void> setStartupCalendar(CalendarType type) async {
    await _prefs.setString(_startupCalendarKey, _calendarTypeToStorage(type));
    await _prefs.setBool(_hasChosenStartupCalendarKey, true);
  }

  Future<void> chooseStartupCalendar(CalendarType type) async {
    _activeType = type;
    _shouldPromptForStartupCalendar = false;
    await setStartupCalendar(type);
    notifyListeners();
  }

  Future<void> setActiveCalendar(CalendarType type) async {
    _activeType = type;
    notifyListeners();
  }

  void setSelectedMonth(int monthIndex) {
    _selectedMonthIndex[_activeType] = monthIndex;
    notifyListeners();
  }

  void setSelectedDayValue(int? day) {
    _selectedDay[_activeType] = day;
    notifyListeners();
  }

  void setSelection({
    required int monthIndex,
    required int? day,
  }) {
    _selectedMonthIndex[_activeType] = monthIndex;
    _selectedDay[_activeType] = day;
    notifyListeners();
  }

  void selectCalendarDate({
    required int monthIndex,
    required int day,
  }) {
    activeEngine.selectCalendarDate(
      monthIndex: monthIndex,
      day: day,
    );
    _selectedMonthIndex[_activeType] = activeEngine.getSelectedMonthIndex();
    _selectedDay[_activeType] = activeEngine.getSelectedDay();
    notifyListeners();
  }

  void goToNextMonth() {
    activeEngine.goToNextMonth();
    _selectedMonthIndex[_activeType] = activeEngine.getSelectedMonthIndex();

    if (_selectedDay[_activeType] != null) {
      _selectedDay[_activeType] = activeEngine.getSelectedDay();
    }

    notifyListeners();
  }

  void goToPreviousMonth() {
    activeEngine.goToPreviousMonth();
    _selectedMonthIndex[_activeType] = activeEngine.getSelectedMonthIndex();

    if (_selectedDay[_activeType] != null) {
      _selectedDay[_activeType] = activeEngine.getSelectedDay();
    }

    notifyListeners();
  }

  static CalendarType? _calendarTypeFromStorage(String? value) {
    switch (value) {
      case 'gregorian':
        return CalendarType.gregorian;
      case 'christian':
        return CalendarType.christian;
      case 'islamic':
        return CalendarType.islamic;
      case 'thirteenMonth':
        return CalendarType.thirteenMonth;
      default:
        return null;
    }
  }

  static String _calendarTypeToStorage(CalendarType type) {
    switch (type) {
      case CalendarType.gregorian:
        return 'gregorian';
      case CalendarType.christian:
        return 'christian';
      case CalendarType.islamic:
        return 'islamic';
      case CalendarType.thirteenMonth:
        return 'thirteenMonth';
    }
  }
}
