import 'package:flutter/material.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/year_overview_grid.dart';
import '../widgets/selected_day_panel.dart';
import '../widgets/day_view_panel.dart';
import '../widgets/app_drawer.dart';
import '../services/calendar_config.dart';
import '../services/calendar_logic.dart';
import '../services/holiday_engine.dart';
import '../models/calendar_entry.dart';

enum CalendarViewMode { month, year, day }
enum RecurrenceEndMode { never, onDate }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int currentMonthIndex = 0;
  int currentYear = 2025;
  int? selectedDay;
  int? previewDay;
  String currentCulture = 'Gregorian';
  String? currentCountry = 'International';
  CalendarViewMode currentViewMode = CalendarViewMode.month;
  CalendarViewMode previousViewMode = CalendarViewMode.month;

  final Map<String, List<CalendarEntry>> entriesByDate = {};

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

    currentYear = today.year;
    currentMonthIndex = today.monthIndex ?? 12;
    selectedDay = null;
    previewDay = null;
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

  void jumpToToday() {
    final today = CalendarLogic.currentCustomDate();

    setState(() {
      currentYear = today.year;
      currentMonthIndex = today.monthIndex ?? 12;
      selectedDay = null;
      previewDay = today.day;
      currentViewMode = CalendarViewMode.month;
    });
  }

  void handleDayTap(int day) {
    setState(() {
      if (selectedDay == day) {
        selectedDay = null;
        previewDay = null;
      } else {
        selectedDay = day;
        previewDay = day;
      }
    });
  }

  void clearSelectedDay() {
    setState(() {
      selectedDay = null;
      previewDay = null;
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

    final directEntries = List<CalendarEntry>.from(entriesByDate[currentKey] ?? []);
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
    }
  }

  Future<void> _deleteEntry(String id) async {
    final storageKey = _findEntryStorageKeyById(id);
    if (storageKey == null) return;

    final current = entriesByDate[storageKey] ?? [];
    final target = current.where((e) => e.id == id).cast<CalendarEntry?>().firstWhere(
          (e) => e != null,
          orElse: () => null,
        );

    if (target == null) return;

    if (target.recurrence == CalendarEntryRecurrence.none) {
      setState(() {
        entriesByDate[storageKey] = current.where((e) => e.id != id).toList();
      });
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
    setState(() {
      if (currentViewMode == CalendarViewMode.month) {
        if (currentMonthIndex == CalendarConfig.monthNames.length - 1) {
          currentMonthIndex = 0;
          currentYear++;
        } else {
          currentMonthIndex++;
        }
        selectedDay = null;
        previewDay = null;
      } else if (currentViewMode == CalendarViewMode.year) {
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
    setState(() {
      if (currentViewMode == CalendarViewMode.month) {
        if (currentMonthIndex == 0) {
          currentMonthIndex = CalendarConfig.monthNames.length - 1;
          currentYear--;
        } else {
          currentMonthIndex--;
        }
        selectedDay = null;
        previewDay = null;
      } else if (currentViewMode == CalendarViewMode.year) {
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

  String get centerLabel {
    switch (currentViewMode) {
      case CalendarViewMode.month:
        return CalendarConfig.monthNames[currentMonthIndex];
      case CalendarViewMode.year:
        return displayedYearLabel;
      case CalendarViewMode.day:
        if (selectedDay == null) {
          return 'Day View';
        }
        return '$selectedDay ${CalendarConfig.monthNames[currentMonthIndex]}';
    }
  }

  void showPlaceholderMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void setViewMode(CalendarViewMode mode) {
    setState(() {
      if (mode == CalendarViewMode.day) {
        previousViewMode = currentViewMode;
        selectedDay ??= previewDay ?? _currentSystemDayForNow();
      }
      currentViewMode = mode;
    });
  }

  void handleViewModeSelection(CalendarViewMode selected) {
    if (selected == CalendarViewMode.day) {
      setViewMode(CalendarViewMode.day);
    } else {
      setViewMode(selected);
    }
  }

  void handleYearViewDayTap(int monthIndex, int day) {
    setState(() {
      currentMonthIndex = monthIndex;
      selectedDay = null;
      previewDay = day;
      currentViewMode = CalendarViewMode.month;
    });
  }

  void closeDayView() {
    setState(() {
      currentViewMode = previousViewMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMonthView = currentViewMode == CalendarViewMode.month;
    final bool isYearView = currentViewMode == CalendarViewMode.year;
    final bool isDayView = currentViewMode == CalendarViewMode.day;
    final String currentMonthName = CalendarConfig.monthNames[currentMonthIndex];
    final currentEntries = _entriesForCurrentSelection();
    final currentHolidays = _holidaysForCurrentSelection();

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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            const Text(
              '13 Month Calendar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Menu',
                        onPressed: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                        icon: const Icon(Icons.menu),
                      ),
                      PopupMenuButton<CalendarViewMode>(
                        tooltip: 'View mode',
                        onSelected: handleViewModeSelection,
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
                        icon: const Icon(Icons.view_module),
                      ),
                      IconButton(
                        tooltip: 'More',
                        onPressed: () {
                          showPlaceholderMessage('More options coming later.');
                        },
                        icon: const Icon(Icons.more_horiz),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: previousPrimary,
                        ),
                        PopupMenuButton<CalendarViewMode>(
                          tooltip: 'Choose view',
                          onSelected: handleViewModeSelection,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Text(
                              centerLabel,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Today',
                          onPressed: jumpToToday,
                          icon: const Icon(Icons.today),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: nextPrimary,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (isYearView) {
                            showPlaceholderMessage(
                              'Use the arrows to change the year here.',
                            );
                          } else {
                            setViewMode(CalendarViewMode.year);
                          }
                        },
                        child: Text(
                          displayedYearLabel,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Choose culture',
                        onSelected: (selected) {
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
                        },
                        itemBuilder: (context) => cultureOptions
                            .map(
                              (culture) => PopupMenuItem<String>(
                                value: culture,
                                child: Text(culture),
                              ),
                            )
                            .toList(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Text(
                            currentCulture,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (currentCulture == 'Gregorian')
                        PopupMenuButton<String>(
                          tooltip: 'Choose country pack',
                          onSelected: (selected) {
                            setState(() {
                              currentCountry = selected;
                              selectedDay = null;
                              previewDay = null;
                            });
                          },
                          itemBuilder: (context) => gregorianCountryOptions
                              .map(
                                (country) => PopupMenuItem<String>(
                                  value: country,
                                  child: Text(country),
                                ),
                              )
                              .toList(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Text(
                              currentCountry ?? 'International',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: isMonthView
                  ? Column(
                      children: [
                        Expanded(
                          child: CalendarGrid(
                            selectedDay: selectedDay,
                            previewDay: previewDay,
                            todayDay: _todayDayForCurrentMonthView,
                            onDayTap: handleDayTap,
                          ),
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
                          },
                          onDayTap: handleYearViewDayTap,
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
