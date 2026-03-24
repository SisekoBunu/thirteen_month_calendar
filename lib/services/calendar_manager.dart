import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/calendar_entry.dart';
import '../models/calendar_type.dart';
import 'calendar_engine.dart';
import 'christian_calendar_engine.dart';
import 'gregorian_calendar_engine.dart';
import 'islamic_calendar_engine.dart';
import 'notification_manager.dart';
import 'thirteen_month_calendar_engine.dart';

class CalendarManager extends ChangeNotifier {
  static const String _startupCalendarKey = 'startup_calendar';
  static const String _hasChosenStartupCalendarKey =
      'has_chosen_startup_calendar';
  static const String entriesStorageKey = 'calendarentries_by_date';

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

  final Map<String, List<CalendarEntry>> entriesByDate = {};

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

    final activeType =
        _calendarTypeFromStorage(savedCalendar) ?? CalendarType.gregorian;

    final manager = CalendarManager._(
      prefs: prefs,
      activeType: activeType,
      shouldPromptForStartupCalendar: !hasChosen,
    );

    manager._initializeCalendarsToToday();
    await manager._loadEntries();

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

  List<CalendarEntry> getEntriesForDate({
    required String culture,
    required int year,
    required int monthIndex,
    required int day,
  }) {
    final key = _storageKey(
      culture: culture,
      year: year,
      monthIndex: monthIndex,
      day: day,
    );

    final directEntries = List<CalendarEntry>.from(entriesByDate[key] ?? const []);
    final seenIds = directEntries.map((entry) => entry.id).toSet();

    final recurringMatches = <CalendarEntry>[];

    for (final mapEntry in entriesByDate.entries) {
      final keyParts = mapEntry.key.split('|');
      if (keyParts.length != 4) {
        continue;
      }

      final entryCulture = keyParts[0];
      if (entryCulture != culture) {
        continue;
      }

      for (final entry in mapEntry.value) {
        if (entry.recurrence == CalendarEntryRecurrence.none) {
          continue;
        }

        if (seenIds.contains(entry.id)) {
          continue;
        }

        if (_matchesRecurringDate(
          culture: culture,
          entry: entry,
          selectedYear: year,
          selectedMonthIndex: monthIndex,
          selectedDay: day,
        )) {
          recurringMatches.add(entry);
          seenIds.add(entry.id);
        }
      }
    }

    return [
      ...directEntries,
      ...recurringMatches,
      ..._getGregorianSystemObservances(
        year: year,
        monthIndex: monthIndex,
        day: day,
      ),
    ];
  }

  Future<void> addEntry({
    required String culture,
    required int year,
    required int monthIndex,
    required int day,
    required CalendarEntry entry,
  }) async {
    final key = _storageKey(
      culture: culture,
      year: year,
      monthIndex: monthIndex,
      day: day,
    );

    final items = List<CalendarEntry>.from(entriesByDate[key] ?? const []);
    items.add(entry);
    entriesByDate[key] = items;

    await _persistEntries();
    notifyListeners();
  }

  Future<void> updateEntry({
    required String culture,
    required int year,
    required int monthIndex,
    required int day,
    required CalendarEntry entry,
  }) async {
    _removeEntryById(entry.id);

    final key = _storageKey(
      culture: culture,
      year: year,
      monthIndex: monthIndex,
      day: day,
    );

    final items = List<CalendarEntry>.from(entriesByDate[key] ?? const []);
    items.add(entry);
    entriesByDate[key] = items;

    await _persistEntries();
    notifyListeners();
  }

  
Future<void> deleteSingleOccurrence({
  required String culture,
  required CalendarEntry entry,
  required int year,
  required int monthIndex,
  required int day,
}) async {
  final ordinal = _ordinalForCulture(
    culture: culture,
    year: year,
    monthIndex: monthIndex,
    day: day,
  );

  final updated = entry.copyWith(
    excludedOrdinals: [...entry.excludedOrdinals, ordinal],
  );

  await updateEntry(
    culture: culture,
    year: entry.anchorYear,
    monthIndex: entry.anchorMonthIndex,
    day: entry.anchorDay,
    entry: updated,
  );
}
Future<void> deleteEntry(String id) async {
    _removeEntryById(id);
    await NotificationManager.cancelByEntryId(id);
    await _persistEntries();
    notifyListeners();
  }

  String buildRecurrenceSummary(CalendarEntry entry) {
    
    switch (entry.recurrence) {
      case CalendarEntryRecurrence.none:
        return 'Does not repeat';
      case CalendarEntryRecurrence.daily:
        return 'Repeats daily';
      case CalendarEntryRecurrence.weekly:
        return 'Repeats weekly';
      case CalendarEntryRecurrence.monthly:
        return 'Repeats monthly';
      case CalendarEntryRecurrence.yearly:
        return 'Repeats yearly';
    }
  }

  Future<void> _loadEntries() async {
    final raw = await _prefs.getString(entriesStorageKey);

    if (raw == null || raw.trim().isEmpty) {
      return;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    entriesByDate.clear();

    for (final mapEntry in decoded.entries) {
      final values = (mapEntry.value as List<dynamic>)
          .map((item) => CalendarEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      entriesByDate[mapEntry.key] = values;
    }

    await NotificationManager.syncFromEntries(entriesByDate);
  }

  Future<void> _persistEntries() async {
    final encoded = jsonEncode(
      entriesByDate.map(
        (key, value) => MapEntry(
          key,
          value.map((entry) => entry.toJson()).toList(),
        ),
      ),
    );

    await _prefs.setString(entriesStorageKey, encoded);
    await NotificationManager.syncFromEntries(entriesByDate);
  }

  void _removeEntryById(String id) {
    final keys = entriesByDate.keys.toList();

    for (final key in keys) {
      final updated =
          entriesByDate[key]!.where((entry) => entry.id != id).toList();

      if (updated.isEmpty) {
        entriesByDate.remove(key);
      } else {
        entriesByDate[key] = updated;
      }
    }
  }

  String _storageKey({
    required String culture,
    required int year,
    required int monthIndex,
    required int day,
  }) {
    return '$culture|$year|$monthIndex|$day';
  }

  bool _matchesRecurringDate({
    required String culture,
    required CalendarEntry entry,
    required int selectedYear,
    required int selectedMonthIndex,
    required int selectedDay,
  }) {
    final anchorOrdinal = _ordinalForCulture(
      culture: culture,
      year: entry.anchorYear,
      monthIndex: entry.anchorMonthIndex,
      day: entry.anchorDay,
    );

    final selectedOrdinal = _ordinalForCulture(
      culture: culture,
      year: selectedYear,
      monthIndex: selectedMonthIndex,
      day: selectedDay,
    );

    if (selectedOrdinal < anchorOrdinal) {
      return false;
    }

    if (entry.excludedOrdinals.contains(selectedOrdinal)) {
      return false;
    }

    if (entry.hasRecurrenceEnd) {
      final endOrdinal = _ordinalForCulture(
        culture: culture,
        year: entry.recurrenceEndYear!,
        monthIndex: entry.recurrenceEndMonthIndex!,
        day: entry.recurrenceEndDay!,
      );

      if (selectedOrdinal > endOrdinal) {
        return false;
      }
    }

    final difference = selectedOrdinal - anchorOrdinal;

    switch (entry.recurrence) {
      case CalendarEntryRecurrence.none:
        return false;
      case CalendarEntryRecurrence.daily:
        return true;
      case CalendarEntryRecurrence.weekly:
        return difference % 7 == 0;
      case CalendarEntryRecurrence.monthly:
        return selectedDay == entry.anchorDay;
      case CalendarEntryRecurrence.yearly:
        return selectedMonthIndex == entry.anchorMonthIndex &&
            selectedDay == entry.anchorDay;
    }
  }

  int _ordinalForCulture({
    required String culture,
    required int year,
    required int monthIndex,
    required int day,
  }) {
    final type = _calendarTypeFromCulture(culture);
    final engine = _engines[type]!;

    int total = 0;

    for (int y = 1; y < year; y++) {
      total += _daysInYear(engine, y);
    }

    for (int m = 0; m < monthIndex; m++) {
      total += engine.getDaysInMonth(m, year);
    }

    total += day;
    return total;
  }

  int _daysInYear(CalendarEngine engine, int year) {
    final months = engine.getMonthNames();
    int total = 0;

    for (int i = 0; i < months.length; i++) {
      total += engine.getDaysInMonth(i, year);
    }

    return total;
  }

  CalendarType _calendarTypeFromCulture(String culture) {
    switch (culture) {
      case 'Gregorian':
        return CalendarType.gregorian;
      case 'Christian (Ussher Chronology)':
        return CalendarType.christian;
      case 'Islamic (Hijri)':
        return CalendarType.islamic;
      case '13-Month Calendar':
        return CalendarType.thirteenMonth;
      default:
        return CalendarType.gregorian;
    }
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

  
  
  
  
  List<CalendarEntry> _getGregorianSystemObservances({
    required int year,
    required int monthIndex,
    required int day,
  }) {
    if (_activeType != CalendarType.gregorian) return [];

    final data = [
      {"m":1,"d":1,"t":"New Year's Day","desc":"Start of the year"},
      {"m":2,"d":14,"t":"Valentine's Day","desc":"Celebration of love"},
      {"m":3,"d":8,"t":"International Women's Day","desc":"Global observance"},
      {"m":4,"d":22,"t":"Earth Day","desc":"Environmental awareness"},
      {"m":5,"d":1,"t":"International Workers' Day","desc":"Labour movement"},
      {"m":6,"d":21,"t":"International Day of Yoga","desc":"Wellness and health"},
      {"m":8,"d":12,"t":"International Youth Day","desc":"Youth awareness"},
      {"m":9,"d":21,"t":"International Day of Peace","desc":"Peace awareness"},
      {"m":10,"d":31,"t":"Halloween","desc":"Cultural observance"},
      {"m":11,"d":20,"t":"Universal Children's Day","desc":"Child welfare"},
      {"m":12,"d":25,"t":"Christmas Day","desc":"Global holiday"},
    ];

    final matches = data.where((e) =>
      e["m"] == (monthIndex + 1) && e["d"] == day
    );

    return matches.map((e) {
      return CalendarEntry(
        id: "sys__",
        type: CalendarEntryType.event,
        title: e["t"] as String,
        details: e["desc"] as String,
        timeLabel: "",
        recurrence: CalendarEntryRecurrence.yearly,
        anchorYear: year,
        anchorMonthIndex: monthIndex,
        anchorDay: day,
        recurrenceEndYear: null,
        recurrenceEndMonthIndex: null,
        recurrenceEndDay: null,
        excludedOrdinals: const [],
      );
    }).toList();
  }
}


