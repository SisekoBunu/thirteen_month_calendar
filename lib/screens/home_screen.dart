import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calendar_entry.dart';
import '../models/calendar_type.dart';
import '../services/calendar_manager.dart';
import '../widgets/app_drawer.dart';
import '../widgets/selected_day_panel.dart';
import '../widgets/year_overview_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _startupDialogShown = false;

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<CalendarManager>();
    final engine = manager.activeEngine;

    if (manager.shouldPromptForStartupCalendar && !_startupDialogShown) {
      _startupDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showStartupCalendarDialog(context, manager);
      });
    }

    final months = engine.getMonthNames();
    final selectedMonthIndex = manager.selectedMonthIndex;
    final selectedDay = manager.selectedDay;

    final panelYear = engine.getDisplayYear();

    final holidays = engine.getHolidaysForDate(
      year: panelYear,
      monthIndex: selectedMonthIndex,
      day: selectedDay,
    );

    final timelineEvents = engine.getTimelineEventsForDate(
      year: panelYear,
      monthIndex: selectedMonthIndex,
      day: selectedDay,
    );

    final currentHeaderLabel =
        "${months[selectedMonthIndex]} ${engine.getDisplayYear()}";

    return Scaffold(
      drawer: _InfoDrawer(
        activeCalendarName: engine.displayName,
        onAboutTap: () {
          Navigator.pop(context);
          _showAboutCalendarDialog(context, engine.displayName);
        },
        onChooseStartupTap: () {
          Navigator.pop(context);
          _showStartupCalendarDialog(context, manager);
        },
      ),
      endDrawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEF3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu),
                    ),
                  ),
                  _HeaderNavButton(
                    icon: Icons.chevron_left,
                    onTap: manager.goToPreviousMonth,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          currentHeaderLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _headerSubtitle(engine.displayName),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HeaderNavButton(
                    icon: Icons.chevron_right,
                    onTap: manager.goToNextMonth,
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.calendar_month_outlined),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: YearOverviewGrid(
                monthNames: months,
                daysInMonth: (monthIndex) =>
                    engine.getDaysInMonth(monthIndex, engine.getDisplayYear()),
                selectedMonthIndex: selectedMonthIndex,
                selectedDay: selectedDay,
                todayMonthIndex: engine.getTodayMonthIndex(),
                todayDay: engine.getTodayDay(),
                highlightToday: true,
                onMonthTap: (monthIndex) {
                  manager.setSelection(
                    monthIndex: monthIndex,
                    day: null,
                  );
                },
                onDayTap: (monthIndex, day) {
                  manager.selectCalendarDate(
                    monthIndex: monthIndex,
                    day: day,
                  );
                },
              ),
            ),
            SelectedDayPanel(
              monthName: months[selectedMonthIndex],
              year: panelYear,
              culture: engine.displayName,
              monthIndex: selectedMonthIndex,
              selectedDay: selectedDay,
              entries: const <CalendarEntry>[],
              holidays: holidays,
              timelineEvents: timelineEvents,
              onClose: () {
                manager.setSelectedDayValue(null);
              },
              onAddEntry: () {},
              onEditEntry: (entry) {},
              onDeleteEntry: (id) async {},
              recurrenceSummaryBuilder: (entry) => '',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStartupCalendarDialog(
    BuildContext context,
    CalendarManager manager,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose your calendar'),
          content: const Text(
            'Select the calendar you want this app to open with. '
            'You can change it again later from the left menu.',
          ),
          actions: [
            ...manager.availableCalendars.map(
              (CalendarType type) => TextButton(
                onPressed: () async {
                  await manager.chooseStartupCalendar(type);
                  if (mounted) Navigator.pop(context);
                },
                child: Text(manager.getEngine(type).displayName),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutCalendarDialog(BuildContext context, String calendarName) {
    final description = _aboutTextForCalendar(calendarName);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('About $calendarName'),
          content: SingleChildScrollView(
            child: Text(description),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  static String _aboutTextForCalendar(String calendarName) {
    switch (calendarName) {
      case 'Gregorian':
        return 'Gregorian is a standalone calendar in MultiCul Calendar App. '
            'It keeps its own structure, naming, year system, observances, and cultural identity.\n\n'
            'What it shares with the rest of the app is the design and navigation style, not its internal truth.';
      case 'Christian (Ussher Chronology)':
        return 'Christian (Ussher Chronology) is a standalone calendar in MultiCul Calendar App. '
            'It keeps its own structure, naming, year system, observances, and cultural identity.\n\n'
            'What it shares with the rest of the app is the design and navigation style, not its internal truth.';
      case 'Islamic (Hijri)':
        return 'Islamic (Hijri) is a standalone calendar in MultiCul Calendar App. '
            'It keeps its own structure, naming, year system, observances, and cultural identity.\n\n'
            'What it shares with the rest of the app is the design and navigation style, not its internal truth.';
      case '13-Month Calendar':
        return '13-Month Calendar is a standalone calendar in MultiCul Calendar App. '
            'It keeps its own structure, naming, year system, observances, and cultural identity.\n\n'
            'What it shares with the rest of the app is the design and navigation style, not its internal truth.';
      default:
        return 'This calendar is a standalone calendar in MultiCul Calendar App. '
            'It keeps its own structure, naming, year system, observances, and cultural identity.\n\n'
            'What it shares with the rest of the app is the design and navigation style, not its internal truth.';
    }
  }

  static String _headerSubtitle(String displayName) {
    if (displayName == 'Christian (Ussher Chronology)') return 'Christian';
    if (displayName == 'Islamic (Hijri)') return 'Islamic';
    return displayName;
  }
}

class _HeaderNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderNavButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black87),
      ),
    );
  }
}

class _InfoDrawer extends StatelessWidget {
  final String activeCalendarName;
  final VoidCallback onAboutTap;
  final VoidCallback onChooseStartupTap;

  const _InfoDrawer({
    required this.activeCalendarName,
    required this.onAboutTap,
    required this.onChooseStartupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'MultiCul Calendar App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('About $activeCalendarName'),
            onTap: onAboutTap,
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Choose startup calendar'),
            onTap: onChooseStartupTap,
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate this app'),
            onTap: () {
              Navigator.pop(context);
              _showPlaceholderDialog(
                context,
                title: 'Rate this app',
                message: 'Rating support will be connected later.',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share with a friend'),
            onTap: () {
              Navigator.pop(context);
              _showPlaceholderDialog(
                context,
                title: 'Share with a friend',
                message: 'Sharing support will be connected later.',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Donate'),
            onTap: () {
              Navigator.pop(context);
              _showPlaceholderDialog(
                context,
                title: 'Donate',
                message: 'Donation support will be connected later.',
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPlaceholderDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
