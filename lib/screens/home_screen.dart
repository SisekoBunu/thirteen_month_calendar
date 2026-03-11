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
  }

  int _currentSystemDayForNow() {
    final today = CalendarLogic.currentCustomDate();
    return today.day ?? 1;
  }

  String _dateKey({
    required String culture,
    required int year,
    required int monthIndex,
    required int day,
  }) {
    return '$culture|$year|$monthIndex|$day';
  }

  List<CalendarEntry> _entriesForCurrentSelection() {
    if (selectedDay == null) return [];
    final key = _dateKey(
      culture: currentCulture,
      year: currentYear,
      monthIndex: currentMonthIndex,
      day: selectedDay!,
    );
    return List<CalendarEntry>.from(entriesByDate[key] ?? []);
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final title = _typeLabel(type);
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
                Navigator.of(context).pop(true);
              },
              child: const Text('Add'),
            ),
          ],
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
      );

      setState(() {
        entriesByDate.putIfAbsent(key, () => []);
        entriesByDate[key] = [newEntry, ...entriesByDate[key]!];
      });
    }
  }

  void _deleteEntry(String id) {
    if (selectedDay == null) return;

    final key = _dateKey(
      culture: currentCulture,
      year: currentYear,
      monthIndex: currentMonthIndex,
      day: selectedDay!,
    );

    setState(() {
      final current = entriesByDate[key] ?? [];
      entriesByDate[key] = current.where((e) => e.id != id).toList();
    });
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
        selectedDay ??= _currentSystemDayForNow();
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

  void handleDayTap(int day) {
    setState(() {
      if (selectedDay == day) {
        selectedDay = null;
      } else {
        selectedDay = day;
      }
    });
  }

  void clearSelectedDay() {
    setState(() {
      selectedDay = null;
    });
  }

  void handleYearViewDayTap(int monthIndex, int day) {
    setState(() {
      previousViewMode = CalendarViewMode.year;
      currentMonthIndex = monthIndex;
      selectedDay = day;
      currentViewMode = CalendarViewMode.day;
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
                            onDayTap: handleDayTap,
                          ),
                        ),
                        if (selectedDay != null)
                          SelectedDayPanel(
                            monthName: currentMonthName,
                            year: int.tryParse(displayedYearLabel) ?? currentYear,
                            culture: currentCulture,
                            selectedDay: selectedDay,
                            entries: currentEntries,
                            holidays: currentHolidays,
                            onAddEntry: _showAddEntryTypeDialog,
                            onClose: clearSelectedDay,
                          ),
                      ],
                    )
                  : isYearView
                      ? YearOverviewGrid(
                          selectedMonthIndex: currentMonthIndex,
                          selectedDay: selectedDay,
                          onMonthTap: (monthIndex) {
                            setState(() {
                              currentMonthIndex = monthIndex;
                              selectedDay = null;
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
                              selectedDay: selectedDay,
                              entries: currentEntries,
                              holidays: currentHolidays,
                              onClose: closeDayView,
                              onAddEntry: _showAddEntryTypeDialog,
                              onDeleteEntry: _deleteEntry,
                            )
                          : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
