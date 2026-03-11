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

  bool get _isFinalMonthOfYear {
    return currentMonthIndex == CalendarConfig.monthNames.length - 1;
  }

  bool get _hasLeapDayThisYear {
    return CalendarLogic.isCustomLeapYear(currentYear);
  }

  void jumpToToday() {
    final today = CalendarLogic.currentCustomDate();

    setState(() {
      currentYear = today.year;
      currentMonthIndex = today.monthIndex ?? 12;
      selectedDay = today.day;
      currentViewMode = CalendarViewMode.month;
    });
  }

  void _showSpecialDayDialog({
    required String title,
    required String description,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecialDayCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.event_available, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildYearEndSpecialDaysSection() {
    if (!_isFinalMonthOfYear) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildSpecialDayCard(
          title: 'Year Day',
          subtitle: 'Occurs after March 28 and sits outside the normal week/month grid.',
          onTap: () {
            _showSpecialDayDialog(
              title: 'Year Day',
              description:
                  'Year Day happens after March 28 at the end of the custom year. '
                  'It does not belong to any month and does not belong to the normal weekly cycle. '
                  'After Year Day, the calendar resets into the new year.',
            );
          },
        ),
        if (_hasLeapDayThisYear)
          _buildSpecialDayCard(
            title: 'Leap Day',
            subtitle: 'Extra correction day after Year Day in leap years only.',
            onTap: () {
              _showSpecialDayDialog(
                title: 'Leap Day',
                description:
                    'Leap Day appears only in leap years, after Year Day and before the next April 1. '
                    'It is outside the normal month/week grid and exists to keep the custom calendar aligned correctly over time.',
              );
            },
          ),
      ],
    );
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
                        _buildYearEndSpecialDaysSection(),
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
