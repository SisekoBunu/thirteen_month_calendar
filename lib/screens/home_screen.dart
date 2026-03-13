import 'package:flutter/material.dart';
import '../widgets/year_overview_grid.dart';
import '../widgets/selected_day_panel.dart';
import '../widgets/day_view_panel.dart';
import '../widgets/app_drawer.dart';
import '../widgets/entry_search_dialog.dart';
import '../widgets/calendar_settings_drawer.dart';
import '../services/calendar_config.dart';
import '../services/calendar_logic.dart';
import '../services/holiday_engine.dart';
import '../services/entry_storage_service.dart';
import '../services/entry_search_service.dart';
import '../services/notification_manager.dart';
import '../models/calendar_entry.dart';
import '../models/calendar_search_result.dart';


enum CalendarViewMode { month, year, day }
enum RecurrenceEndMode { never, onDate }


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  static const double _monthSectionExtent = 360.0;
  static const int _monthWindowBefore = 30;
  static const int _monthWindowAfter = 30;


  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final ScrollController _monthScrollController;


  late final int _scrollBaseYear;
  late final int _scrollBaseMonthIndex;
  late final int _scrollBaseDay;


  int currentMonthIndex = 0;
  int currentYear = 2025;
  int? selectedDay;
  int? previewDay;
  String currentCulture = 'Gregorian';
  String? currentCountry = 'International';
  CalendarViewMode currentViewMode = CalendarViewMode.month;
  CalendarViewMode previousViewMode = CalendarViewMode.month;


  final Map<String, List<CalendarEntry>> entriesByDate = {};
  bool _storageReady = false;
  bool _monthScrollReady = false;
  bool _isJumpingMonthList = false;


  final List<String> cultureOptions = const [
    'Gregorian',
    'Christian',
    'Islamic',
    'Hebrew',
    'Chinese',
    'Hindu',
    'Persian',
    'Mayan',
    'Buddhist',
    'Ethiopian',
    'Japanese Imperial',
    'Korean Dangi',
    'Thai Solar',
  ];


  final List<String> gregorianCountryOptions = const [
    'International',
    'South Africa',
    'USA',
    'United Kingdom',
    'Canada',
    'Australia',
    'New Zealand',
  ];


  @override
  void initState() {
    super.initState();


    final today = CalendarLogic.currentCustomDate();


    _scrollBaseYear = today.year;
    _scrollBaseMonthIndex = today.monthIndex ?? 12;
    _scrollBaseDay = today.day ?? 1;


    currentYear = _scrollBaseYear;
    currentMonthIndex = _scrollBaseMonthIndex;
    selectedDay = null;
    previewDay = _scrollBaseDay;


    _monthScrollController = ScrollController(
      initialScrollOffset: _monthWindowBefore * _monthSectionExtent,
    );
    _monthScrollController.addListener(_handleMonthScroll);


    _loadStoredEntries();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _monthScrollReady = true;
      });
      _handleMonthScroll();
    });
  }


  @override
  void dispose() {
    _monthScrollController.removeListener(_handleMonthScroll);
    _monthScrollController.dispose();
    super.dispose();
  }


  Future<void> _loadStoredEntries() async {
    final stored = await EntryStorageService.loadEntriesByDate();


    if (!mounted) return;


    setState(() {
      entriesByDate
        ..clear()
        ..addAll(stored);
      _storageReady = true;
    });


    await NotificationManager.syncFromEntries(entriesByDate);
  }


  Future<void> _persistEntries() async {
    await EntryStorageService.saveEntriesByDate(entriesByDate);
  }


  Future<void> _syncNotifications() async {
    await NotificationManager.syncFromEntries(entriesByDate);
  }


  Future<void> _requestNotificationPermission() async {
    final allowed = await NotificationManager.requestPermission();


    if (!mounted) return;


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          allowed
              ? 'Notification permission granted.'
              : 'Notification permission was not granted or is unavailable.',
        ),
      ),
    );


    if (allowed) {
      await _syncNotifications();
    }
  }


  int _currentSystemDayForNow() {
    final today = CalendarLogic.currentCustomDate();
    return today.day ?? 1;
  }


  int? get _todayDayForCurrentMonthView {
    final today = CalendarLogic.currentCustomDate();


    if (today.year == currentYear && today.monthIndex == currentMonthIndex) {
      return today.day;
    }


    return null;
  }


  int? get _todayMonthIndexForCurrentYearView {
    final today = CalendarLogic.currentCustomDate();


    if (today.year == currentYear) {
      return today.monthIndex;
    }


    return null;
  }


  int? get _todayDayForCurrentYearView {
    final today = CalendarLogic.currentCustomDate();


    if (today.year == currentYear) {
      return today.day;
    }


    return null;
  }


  int _absoluteMonthIndex({
    required int year,
    required int monthIndex,
  }) {
    return (year * CalendarConfig.monthNames.length) + monthIndex;
  }


  _MonthReference _monthRefFromListIndex(int index) {
    final baseAbsolute = _absoluteMonthIndex(
      year: _scrollBaseYear,
      monthIndex: _scrollBaseMonthIndex,
    );


    final relativeOffset = index - _monthWindowBefore;
    final targetAbsolute = baseAbsolute + relativeOffset;


    int year = targetAbsolute ~/ CalendarConfig.monthNames.length;
    int monthIndex = targetAbsolute % CalendarConfig.monthNames.length;


    if (monthIndex < 0) {
      monthIndex += CalendarConfig.monthNames.length;
      year -= 1;
    }


    return _MonthReference(
      year: year,
      monthIndex: monthIndex,
    );
  }


  int _listIndexForMonth({
    required int year,
    required int monthIndex,
  }) {
    final baseAbsolute = _absoluteMonthIndex(
      year: _scrollBaseYear,
      monthIndex: _scrollBaseMonthIndex,
    );


    final targetAbsolute = _absoluteMonthIndex(
      year: year,
      monthIndex: monthIndex,
    );


    return _monthWindowBefore + (targetAbsolute - baseAbsolute);
  }


  void _handleMonthScroll() {
    if (!_monthScrollReady || _isJumpingMonthList) return;
    if (!_monthScrollController.hasClients) return;


    final offset = _monthScrollController.offset.clamp(
      0.0,
      _monthScrollController.position.maxScrollExtent,
    );


    final visibleIndex = (offset / _monthSectionExtent)
        .round()
        .clamp(0, _monthWindowBefore + _monthWindowAfter);


    final ref = _monthRefFromListIndex(visibleIndex);


    if (ref.year != currentYear || ref.monthIndex != currentMonthIndex) {
      if (!mounted) return;
      setState(() {
        currentYear = ref.year;
        currentMonthIndex = ref.monthIndex;
      });
    }
  }


  Future<void> _jumpMonthListTo({
    required int year,
    required int monthIndex,
    required bool animate,
  }) async {
    if (!_monthScrollController.hasClients) return;


    final targetIndex = _listIndexForMonth(
      year: year,
      monthIndex: monthIndex,
    ).clamp(0, _monthWindowBefore + _monthWindowAfter);


    final targetOffset = targetIndex * _monthSectionExtent;


    _isJumpingMonthList = true;


    if (animate) {
      await _monthScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    } else {
      _monthScrollController.jumpTo(targetOffset);
    }


    if (mounted) {
      setState(() {
        currentYear = year;
        currentMonthIndex = monthIndex;
        _monthScrollReady = true;
      });
    }


    _isJumpingMonthList = false;
  }


  void jumpToToday() {
    final today = CalendarLogic.currentCustomDate();


    setState(() {
      currentYear = today.year;
      currentMonthIndex = today.monthIndex ?? 12;
      selectedDay = null;
      previewDay = today.day;
      currentViewMode = CalendarViewMode.month;
    });


    _jumpMonthListTo(
      year: today.year,
      monthIndex: today.monthIndex ?? 12,
      animate: true,
    );
  }


  void clearSelectedDay() {
    setState(() {
      selectedDay = null;
      previewDay = null;
    });
  }


  void _handleContinuousMonthDayTap({
    required int year,
    required int monthIndex,
    required int day,
  }) {
    setState(() {
      currentYear = year;
      currentMonthIndex = monthIndex;


      if (selectedDay == day &&
          previewDay == day &&
          currentViewMode == CalendarViewMode.month) {
        selectedDay = null;
        previewDay = null;
      } else {
        selectedDay = day;
        previewDay = day;
      }
    });
  }


  void _openSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return EntrySearchDialog(
          onSearch: (query) {
            return EntrySearchService.searchEntries(
              entriesByDate: entriesByDate,
              query: query,
              culture: null,
            );
          },
          onResultTap: _jumpToSearchResult,
        );
      },
    );
  }


  void _jumpToSearchResult(CalendarSearchResult result) {
    setState(() {
      currentCulture = result.culture;
      if (result.culture == 'Gregorian') {
        currentCountry ??= 'International';
      } else {
        currentCountry = null;
      }


      currentYear = result.year;
      currentMonthIndex = result.monthIndex;
      selectedDay = result.day;
      previewDay = result.day;
      previousViewMode = currentViewMode;
      currentViewMode = CalendarViewMode.day;
    });
  }


  void _openCalendarSettingsDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }


  void _selectCulture(String selected) {
    setState(() {
      currentCulture = selected;
      if (selected != 'Gregorian') {
        currentCountry = null;
      } else {
        currentCountry ??= 'International';
      }
      selectedDay = null;
      previewDay = null;
    });
  }


  void _selectCountry(String selected) {
    setState(() {
      currentCountry = selected;
      selectedDay = null;
      previewDay = null;
    });
  }


  void _selectViewMode(CalendarViewMode mode) {
    setState(() {
      if (mode == CalendarViewMode.day) {
        previousViewMode = currentViewMode;
        selectedDay ??= previewDay ?? _currentSystemDayForNow();
      }
      currentViewMode = mode;
    });
  }


  String _dateKey({
    required String culture,
    required int year,
    required int monthIndex,
    required int day,
  }) {
    return '$culture|$year|$monthIndex|$day';
  }


  int _customOrdinal({
    required int year,
    required int monthIndex,
    required int day,
  }) {
    int total = 0;


    for (int y = 1; y < year; y++) {
      total += CalendarLogic.daysInCustomYear(y);
    }


    total += (monthIndex * CalendarConfig.daysPerMonth);
    total += day;


    return total;
  }


  bool _matchesRecurringDate({
    required CalendarEntry entry,
    required int selectedYear,
    required int selectedMonthIndex,
    required int selectedDay,
  }) {
    if (entry.recurrence == CalendarEntryRecurrence.none) {
      return false;
    }


    final anchorOrdinal = _customOrdinal(
      year: entry.anchorYear,
      monthIndex: entry.anchorMonthIndex,
      day: entry.anchorDay,
    );


    final selectedOrdinal = _customOrdinal(
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
      final endOrdinal = _customOrdinal(
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


  String? _findEntryStorageKeyById(String id) {
    for (final mapEntry in entriesByDate.entries) {
      for (final entry in mapEntry.value) {
        if (entry.id == id) {
          return mapEntry.key;
        }
      }
    }
    return null;
  }


  List<CalendarEntry> _entriesForCurrentSelection() {
    if (selectedDay == null) return [];


    final currentKey = _dateKey(
      culture: currentCulture,
      year: currentYear,
      monthIndex: currentMonthIndex,
      day: selectedDay!,
    );


    final directEntries =
        List<CalendarEntry>.from(entriesByDate[currentKey] ?? []);
    final recurringEntries = <CalendarEntry>[];


    for (final mapEntry in entriesByDate.entries) {
      final keyParts = mapEntry.key.split('|');
      if (keyParts.isEmpty || keyParts.first != currentCulture) {
        continue;
      }


      if (mapEntry.key == currentKey) {
        continue;
      }


      for (final entry in mapEntry.value) {
        if (_matchesRecurringDate(
          entry: entry,
          selectedYear: currentYear,
          selectedMonthIndex: currentMonthIndex,
          selectedDay: selectedDay!,
        )) {
          recurringEntries.add(entry);
        }
      }
    }


    return [...directEntries, ...recurringEntries];
  }


  List<String> _holidaysForCurrentSelection() {
    return HolidayEngine.getHolidayNamesForCurrentSelection(
      profile: currentCulture,
      country: currentCountry,
      customYear: currentYear,
      customMonthIndex: currentMonthIndex,
      customDay: selectedDay,
    );
  }


  Future<void> _showAddEntryTypeDialog() async {
    if (selectedDay == null) return;


    final selectedType = await showDialog<CalendarEntryType>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Add Entry'),
          children: [
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(CalendarEntryType.event),
              child: const Text('Event'),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(CalendarEntryType.reminder),
              child: const Text('Reminder'),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(CalendarEntryType.alarm),
              child: const Text('Alarm'),
            ),
          ],
        );
      },
    );


    if (selectedType != null) {
      await _showAddEntryDialog(selectedType);
    }
  }


  Future<void> _showAddEntryDialog(CalendarEntryType type) async {
    if (selectedDay == null) return;


    final titleController = TextEditingController();
    final detailsController = TextEditingController();
    final timeController = TextEditingController();
    CalendarEntryRecurrence selectedRecurrence = CalendarEntryRecurrence.none;


    RecurrenceEndMode endMode = RecurrenceEndMode.never;
    int endYear = currentYear;
    int endMonthIndex = currentMonthIndex;
    int endDay = selectedDay!;


    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final title = _typeLabel(type);


        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('New $title'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: '$title title',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time (optional)',
                        hintText: 'e.g. 09:00',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Details (optional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CalendarEntryRecurrence>(
                      value: selectedRecurrence,
                      decoration: const InputDecoration(
                        labelText: 'Repeat',
                      ),
                      items: CalendarEntryRecurrence.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_recurrenceLabel(value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedRecurrence = value;
                          if (value == CalendarEntryRecurrence.none) {
                            endMode = RecurrenceEndMode.never;
                          }
                        });
                      },
                    ),
                    if (selectedRecurrence != CalendarEntryRecurrence.none) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<RecurrenceEndMode>(
                        value: endMode,
                        decoration: const InputDecoration(
                          labelText: 'Repeat ends',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: RecurrenceEndMode.never,
                            child: Text('Never'),
                          ),
                          DropdownMenuItem(
                            value: RecurrenceEndMode.onDate,
                            child: Text('On date'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            endMode = value;
                          });
                        },
                      ),
                      if (endMode == RecurrenceEndMode.onDate) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: endYear,
                          decoration: const InputDecoration(
                            labelText: 'End year',
                          ),
                          items: List.generate(
                            20,
                            (index) => currentYear + index,
                          )
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              endYear = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: endMonthIndex,
                          decoration: const InputDecoration(
                            labelText: 'End month',
                          ),
                          items: List.generate(
                            CalendarConfig.monthNames.length,
                            (index) => index,
                          )
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(CalendarConfig.monthNames[value]),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              endMonthIndex = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: endDay,
                          decoration: const InputDecoration(
                            labelText: 'End day',
                          ),
                          items: List.generate(
                            CalendarConfig.daysPerMonth,
                            (index) => index + 1,
                          )
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              endDay = value;
                            });
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    if (selectedRecurrence != CalendarEntryRecurrence.none &&
                        endMode == RecurrenceEndMode.onDate) {
                      final anchorOrdinal = _customOrdinal(
                        year: currentYear,
                        monthIndex: currentMonthIndex,
                        day: selectedDay!,
                      );
                      final endOrdinal = _customOrdinal(
                        year: endYear,
                        monthIndex: endMonthIndex,
                        day: endDay,
                      );


                      if (endOrdinal < anchorOrdinal) return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );


    if (confirmed == true) {
      final key = _dateKey(
        culture: currentCulture,
        year: currentYear,
        monthIndex: currentMonthIndex,
        day: selectedDay!,
      );


      final newEntry = CalendarEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
        title: titleController.text.trim(),
        details: detailsController.text.trim(),
        timeLabel: timeController.text.trim(),
        recurrence: selectedRecurrence,
        anchorYear: currentYear,
        anchorMonthIndex: currentMonthIndex,
        anchorDay: selectedDay!,
        recurrenceEndYear:
            selectedRecurrence == CalendarEntryRecurrence.none ||
                    endMode == RecurrenceEndMode.never
                ? null
                : endYear,
        recurrenceEndMonthIndex:
            selectedRecurrence == CalendarEntryRecurrence.none ||
                    endMode == RecurrenceEndMode.never
                ? null
                : endMonthIndex,
        recurrenceEndDay:
            selectedRecurrence == CalendarEntryRecurrence.none ||
                    endMode == RecurrenceEndMode.never
                ? null
                : endDay,
        excludedOrdinals: const [],
      );


      setState(() {
        entriesByDate.putIfAbsent(key, () => []);
        entriesByDate[key] = [newEntry, ...entriesByDate[key]!];
      });


      await _persistEntries();
      await _syncNotifications();
    }
  }


  Future<void> _showEditEntryDialog(CalendarEntry entry) async {
    final storageKey = _findEntryStorageKeyById(entry.id);
    if (storageKey == null) return;


    final titleController = TextEditingController(text: entry.title);
    final detailsController = TextEditingController(text: entry.details);
    final timeController = TextEditingController(text: entry.timeLabel);
    CalendarEntryRecurrence selectedRecurrence = entry.recurrence;


    RecurrenceEndMode endMode = entry.hasRecurrenceEnd
        ? RecurrenceEndMode.onDate
        : RecurrenceEndMode.never;


    int endYear = entry.recurrenceEndYear ?? entry.anchorYear;
    int endMonthIndex = entry.recurrenceEndMonthIndex ?? entry.anchorMonthIndex;
    int endDay = entry.recurrenceEndDay ?? entry.anchorDay;


    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final title = _typeLabel(entry.type);


        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit $title'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: '$title title',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time (optional)',
                        hintText: 'e.g. 09:00',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Details (optional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CalendarEntryRecurrence>(
                      value: selectedRecurrence,
                      decoration: const InputDecoration(
                        labelText: 'Repeat',
                      ),
                      items: CalendarEntryRecurrence.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_recurrenceLabel(value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedRecurrence = value;
                          if (value == CalendarEntryRecurrence.none) {
                            endMode = RecurrenceEndMode.never;
                          }
                        });
                      },
                    ),
                    if (selectedRecurrence != CalendarEntryRecurrence.none) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<RecurrenceEndMode>(
                        value: endMode,
                        decoration: const InputDecoration(
                          labelText: 'Repeat ends',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: RecurrenceEndMode.never,
                            child: Text('Never'),
                          ),
                          DropdownMenuItem(
                            value: RecurrenceEndMode.onDate,
                            child: Text('On date'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            endMode = value;
                          });
                        },
                      ),
                      if (endMode == RecurrenceEndMode.onDate) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: endYear,
                          decoration: const InputDecoration(
                            labelText: 'End year',
                          ),
                          items: List.generate(
                            20,
                            (index) => entry.anchorYear + index,
                          )
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              endYear = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: endMonthIndex,
                          decoration: const InputDecoration(
                            labelText: 'End month',
                          ),
                          items: List.generate(
                            CalendarConfig.monthNames.length,
                            (index) => index,
                          )
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(CalendarConfig.monthNames[value]),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              endMonthIndex = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: endDay,
                          decoration: const InputDecoration(
                            labelText: 'End day',
                          ),
                          items: List.generate(
                            CalendarConfig.daysPerMonth,
                            (index) => index + 1,
                          )
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              endDay = value;
                            });
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    if (selectedRecurrence != CalendarEntryRecurrence.none &&
                        endMode == RecurrenceEndMode.onDate) {
                      final anchorOrdinal = _customOrdinal(
                        year: entry.anchorYear,
                        monthIndex: entry.anchorMonthIndex,
                        day: entry.anchorDay,
                      );
                      final endOrdinal = _customOrdinal(
                        year: endYear,
                        monthIndex: endMonthIndex,
                        day: endDay,
                      );


                      if (endOrdinal < anchorOrdinal) return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );


    if (confirmed == true) {
      final updatedEntry = CalendarEntry(
        id: entry.id,
        type: entry.type,
        title: titleController.text.trim(),
        details: detailsController.text.trim(),
        timeLabel: timeController.text.trim(),
        recurrence: selectedRecurrence,
        anchorYear: entry.anchorYear,
        anchorMonthIndex: entry.anchorMonthIndex,
        anchorDay: entry.anchorDay,
        recurrenceEndYear:
            selectedRecurrence == CalendarEntryRecurrence.none ||
                    endMode == RecurrenceEndMode.never
                ? null
                : endYear,
        recurrenceEndMonthIndex:
            selectedRecurrence == CalendarEntryRecurrence.none ||
                    endMode == RecurrenceEndMode.never
                ? null
                : endMonthIndex,
        recurrenceEndDay:
            selectedRecurrence == CalendarEntryRecurrence.none ||
                    endMode == RecurrenceEndMode.never
                ? null
                : endDay,
        excludedOrdinals: entry.excludedOrdinals,
      );


      setState(() {
        final current = entriesByDate[storageKey] ?? [];
        entriesByDate[storageKey] = current
            .map((e) => e.id == entry.id ? updatedEntry : e)
            .toList();
      });


      await _persistEntries();
      await _syncNotifications();
    }
  }


  Future<void> _deleteEntry(String id) async {
    final storageKey = _findEntryStorageKeyById(id);
    if (storageKey == null) return;


    final current = entriesByDate[storageKey] ?? [];
    final target =
        current.where((e) => e.id == id).cast<CalendarEntry?>().firstWhere(
              (e) => e != null,
              orElse: () => null,
            );


    if (target == null) return;


    if (target.recurrence == CalendarEntryRecurrence.none) {
      setState(() {
        entriesByDate[storageKey] = current.where((e) => e.id != id).toList();
      });
      await _persistEntries();
      await _syncNotifications();
      return;
    }


    if (selectedDay == null) return;


    final choice = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete recurring entry'),
          content: const Text(
            'Do you want to delete only this occurrence, or the entire series?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('occurrence'),
              child: const Text('This occurrence'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('series'),
              child: const Text('Entire series'),
            ),
          ],
        );
      },
    );


    if (choice == 'series') {
      setState(() {
        entriesByDate[storageKey] = current.where((e) => e.id != id).toList();
      });
      await _persistEntries();
      await _syncNotifications();
      return;
    }


    if (choice == 'occurrence') {
      final selectedOrdinal = _customOrdinal(
        year: currentYear,
        monthIndex: currentMonthIndex,
        day: selectedDay!,
      );


      final updatedEntry = CalendarEntry(
        id: target.id,
        type: target.type,
        title: target.title,
        details: target.details,
        timeLabel: target.timeLabel,
        recurrence: target.recurrence,
        anchorYear: target.anchorYear,
        anchorMonthIndex: target.anchorMonthIndex,
        anchorDay: target.anchorDay,
        recurrenceEndYear: target.recurrenceEndYear,
        recurrenceEndMonthIndex: target.recurrenceEndMonthIndex,
        recurrenceEndDay: target.recurrenceEndDay,
        excludedOrdinals: [...target.excludedOrdinals, selectedOrdinal],
      );


      setState(() {
        entriesByDate[storageKey] = current
            .map((e) => e.id == id ? updatedEntry : e)
            .toList();
      });


      await _persistEntries();
      await _syncNotifications();
    }
  }


  static String _typeLabel(CalendarEntryType type) {
    switch (type) {
      case CalendarEntryType.event:
        return 'Event';
      case CalendarEntryType.reminder:
        return 'Reminder';
      case CalendarEntryType.alarm:
        return 'Alarm';
    }
  }


  static String _recurrenceLabel(CalendarEntryRecurrence recurrence) {
    switch (recurrence) {
      case CalendarEntryRecurrence.none:
        return 'Does not repeat';
      case CalendarEntryRecurrence.daily:
        return 'Daily';
      case CalendarEntryRecurrence.weekly:
        return 'Weekly';
      case CalendarEntryRecurrence.monthly:
        return 'Monthly';
      case CalendarEntryRecurrence.yearly:
        return 'Yearly';
    }
  }


  String _recurrenceSummary(CalendarEntry entry) {
    if (entry.recurrence == CalendarEntryRecurrence.none) {
      return 'Does not repeat';
    }


    final base = switch (entry.recurrence) {
      CalendarEntryRecurrence.none => 'Does not repeat',
      CalendarEntryRecurrence.daily => 'Repeats daily',
      CalendarEntryRecurrence.weekly => 'Repeats weekly',
      CalendarEntryRecurrence.monthly => 'Repeats monthly',
      CalendarEntryRecurrence.yearly => 'Repeats yearly',
    };


    if (!entry.hasRecurrenceEnd) {
      return '$base forever';
    }


    return '$base until ${entry.recurrenceEndDay} ${CalendarConfig.monthNames[entry.recurrenceEndMonthIndex!]} ${entry.recurrenceEndYear}';
  }


  void nextPrimary() {
    if (currentViewMode == CalendarViewMode.month) {
      final nextAbsolute = _absoluteMonthIndex(
            year: currentYear,
            monthIndex: currentMonthIndex,
          ) +
          1;


      int nextYear = nextAbsolute ~/ CalendarConfig.monthNames.length;
      int nextMonthIndex = nextAbsolute % CalendarConfig.monthNames.length;


      if (nextMonthIndex < 0) {
        nextMonthIndex += CalendarConfig.monthNames.length;
        nextYear -= 1;
      }


      setState(() {
        selectedDay = null;
        previewDay = null;
      });


      _jumpMonthListTo(
        year: nextYear,
        monthIndex: nextMonthIndex,
        animate: true,
      );
      return;
    }


    setState(() {
      if (currentViewMode == CalendarViewMode.year) {
        currentYear++;
      } else if (currentViewMode == CalendarViewMode.day) {
        if (selectedDay == null) {
          selectedDay = _currentSystemDayForNow();
        } else if (selectedDay! < CalendarConfig.daysPerMonth) {
          selectedDay = selectedDay! + 1;
        } else {
          selectedDay = 1;
          if (currentMonthIndex == CalendarConfig.monthNames.length - 1) {
            currentMonthIndex = 0;
            currentYear++;
          } else {
            currentMonthIndex++;
          }
        }
        previewDay = selectedDay;
      }
    });
  }


  void previousPrimary() {
    if (currentViewMode == CalendarViewMode.month) {
      final previousAbsolute = _absoluteMonthIndex(
            year: currentYear,
            monthIndex: currentMonthIndex,
          ) -
          1;


      int previousYear = previousAbsolute ~/ CalendarConfig.monthNames.length;
      int previousMonthIndex = previousAbsolute % CalendarConfig.monthNames.length;


      if (previousMonthIndex < 0) {
        previousMonthIndex += CalendarConfig.monthNames.length;
        previousYear -= 1;
      }


      setState(() {
        selectedDay = null;
        previewDay = null;
      });


      _jumpMonthListTo(
        year: previousYear,
        monthIndex: previousMonthIndex,
        animate: true,
      );
      return;
    }


    setState(() {
      if (currentViewMode == CalendarViewMode.year) {
        currentYear--;
      } else if (currentViewMode == CalendarViewMode.day) {
        if (selectedDay == null) {
          selectedDay = _currentSystemDayForNow();
        } else if (selectedDay! > 1) {
          selectedDay = selectedDay! - 1;
        } else {
          selectedDay = CalendarConfig.daysPerMonth;
          if (currentMonthIndex == 0) {
            currentMonthIndex = CalendarConfig.monthNames.length - 1;
            currentYear--;
          } else {
            currentMonthIndex--;
          }
        }
        previewDay = selectedDay;
      }
    });
  }


  String get displayedYearLabel {
    return CalendarLogic.displayedYearForCulture(currentCulture, currentYear);
  }


  String get navigationMonthLabel {
    return CalendarConfig.monthNames[currentMonthIndex];
  }


  void showPlaceholderMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  void closeDayView() {
    setState(() {
      currentViewMode = previousViewMode;
    });
  }


  Widget _buildMonthSelector() {
    return PopupMenuButton<CalendarViewMode>(
      tooltip: 'Choose view',
      onSelected: _selectViewMode,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: CalendarViewMode.month,
          child: Text('Month View'),
        ),
        PopupMenuItem(
          value: CalendarViewMode.year,
          child: Text('Year View'),
        ),
        PopupMenuItem(
          value: CalendarViewMode.day,
          child: Text('Day View'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                navigationMonthLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }


  Widget _buildContinuousMonthList() {
    final itemCount = _monthWindowBefore + _monthWindowAfter + 1;


    return ListView.builder(
      controller: _monthScrollController,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final monthRef = _monthRefFromListIndex(index);
        final monthName = CalendarConfig.monthNames[monthRef.monthIndex];


        final today = CalendarLogic.currentCustomDate();
        final todayDay = today.year == monthRef.year &&
                today.monthIndex == monthRef.monthIndex
            ? today.day
            : null;


        final sectionSelectedDay = currentYear == monthRef.year &&
                currentMonthIndex == monthRef.monthIndex
            ? selectedDay
            : null;


        final sectionPreviewDay = currentYear == monthRef.year &&
                currentMonthIndex == monthRef.monthIndex
            ? previewDay
            : null;


        return SizedBox(
          height: _monthSectionExtent,
          child: _ContinuousMonthSection(
            monthName: monthName,
            selectedDay: sectionSelectedDay,
            previewDay: sectionPreviewDay,
            todayDay: todayDay,
            onDayTap: (day) {
              _handleContinuousMonthDayTap(
                year: monthRef.year,
                monthIndex: monthRef.monthIndex,
                day: day,
              );
            },
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final bool isMonthView = currentViewMode == CalendarViewMode.month;
    final bool isYearView = currentViewMode == CalendarViewMode.year;
    final bool isDayView = currentViewMode == CalendarViewMode.day;
    final String currentMonthName = CalendarConfig.monthNames[currentMonthIndex];
    final currentEntries = _entriesForCurrentSelection();
    final currentHolidays = _holidaysForCurrentSelection();


    if (!_storageReady) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }


    return Scaffold(
      key: scaffoldKey,
      drawer: AppDrawer(
        onRateTap: () {
          showPlaceholderMessage('Rate action will be connected later.');
        },
        onShareTap: () {
          showPlaceholderMessage('Share action will be connected later.');
        },
      ),
      endDrawer: CalendarSettingsDrawer(
        currentCulture: currentCulture,
        currentCountry: currentCountry,
        cultureOptions: cultureOptions,
        gregorianCountryOptions: gregorianCountryOptions,
        onCultureSelected: _selectCulture,
        onCountrySelected: _selectCountry,
        onNotificationsTap: _requestNotificationPermission,
        onTimezoneTap: () {
          showPlaceholderMessage('Timezone settings coming later.');
        },
        onSettingsTap: () {
          showPlaceholderMessage('More settings coming later.');
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Menu',
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  ),
                  Expanded(
                    child: Text(
                      displayedYearLabel,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Search',
                    onPressed: _openSearchDialog,
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    tooltip: 'Calendar settings',
                    onPressed: _openCalendarSettingsDrawer,
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: previousPrimary,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMonthSelector(),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: jumpToToday,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.today,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: nextPrimary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: isMonthView
                  ? Column(
                      children: [
                        Expanded(
                          child: _buildContinuousMonthList(),
                        ),
                        if (selectedDay != null)
                          Flexible(
                            child: SingleChildScrollView(
                              child: SelectedDayPanel(
                                monthName: currentMonthName,
                                year: int.tryParse(displayedYearLabel) ?? currentYear,
                                culture: currentCulture,
                                monthIndex: currentMonthIndex,
                                selectedDay: selectedDay,
                                entries: currentEntries,
                                holidays: currentHolidays,
                                onAddEntry: _showAddEntryTypeDialog,
                                onClose: clearSelectedDay,
                                onEditEntry: _showEditEntryDialog,
                                onDeleteEntry: _deleteEntry,
                                recurrenceSummaryBuilder: _recurrenceSummary,
                              ),
                            ),
                          ),
                      ],
                    )
                  : isYearView
                      ? YearOverviewGrid(
                          selectedMonthIndex: currentMonthIndex,
                          selectedDay: selectedDay,
                          todayMonthIndex: _todayMonthIndexForCurrentYearView,
                          todayDay: _todayDayForCurrentYearView,
                          highlightToday: _todayMonthIndexForCurrentYearView != null,
                          onMonthTap: (monthIndex) {
                            setState(() {
                              currentMonthIndex = monthIndex;
                              selectedDay = null;
                              previewDay = null;
                              currentViewMode = CalendarViewMode.month;
                            });


                            _jumpMonthListTo(
                              year: currentYear,
                              monthIndex: monthIndex,
                              animate: false,
                            );
                          },
                          onDayTap: (monthIndex, day) {
                            setState(() {
                              currentMonthIndex = monthIndex;
                              selectedDay = null;
                              previewDay = day;
                              currentViewMode = CalendarViewMode.month;
                            });


                            _jumpMonthListTo(
                              year: currentYear,
                              monthIndex: monthIndex,
                              animate: false,
                            );
                          },
                        )
                      : isDayView
                          ? DayViewPanel(
                              monthName: currentMonthName,
                              year: int.tryParse(displayedYearLabel) ?? currentYear,
                              culture: currentCulture,
                              selectedDay: selectedDay ?? previewDay,
                              entries: currentEntries,
                              holidays: currentHolidays,
                              onClose: closeDayView,
                              onAddEntry: _showAddEntryTypeDialog,
                              onEditEntry: _showEditEntryDialog,
                              onDeleteEntry: _deleteEntry,
                              recurrenceSummaryBuilder: _recurrenceSummary,
                            )
                          : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}


class _MonthReference {
  final int year;
  final int monthIndex;


  const _MonthReference({
    required this.year,
    required this.monthIndex,
  });
}


class _ContinuousMonthSection extends StatelessWidget {
  final String monthName;
  final int? selectedDay;
  final int? previewDay;
  final int? todayDay;
  final ValueChanged<int> onDayTap;


  const _ContinuousMonthSection({
    required this.monthName,
    required this.selectedDay,
    required this.previewDay,
    required this.todayDay,
    required this.onDayTap,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              monthName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              _MiniWeekdayLabel('Mon'),
              _MiniWeekdayLabel('Tue'),
              _MiniWeekdayLabel('Wed'),
              _MiniWeekdayLabel('Thu'),
              _MiniWeekdayLabel('Fri'),
              _MiniWeekdayLabel('Sat'),
              _MiniWeekdayLabel('Sun'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CalendarConfig.daysPerMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = selectedDay == day;
              final isPreview = previewDay == day;
              final isToday = todayDay == day;


              Color backgroundColor = Colors.white;
              Color borderColor = Colors.grey.shade300;
              Color textColor = Colors.black87;
              FontWeight fontWeight = FontWeight.w500;


              if (isSelected) {
                backgroundColor = Colors.black87;
                borderColor = Colors.black87;
                textColor = Colors.white;
                fontWeight = FontWeight.w700;
              } else if (isPreview || isToday) {
                backgroundColor = Colors.grey.shade200;
                borderColor = Colors.grey.shade500;
                textColor = Colors.black87;
                fontWeight = FontWeight.w700;
              }


              return GestureDetector(
                onTap: () => onDayTap(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: fontWeight,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class _MiniWeekdayLabel extends StatelessWidget {
  final String label;


  const _MiniWeekdayLabel(this.label);


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}


