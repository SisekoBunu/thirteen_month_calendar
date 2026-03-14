import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calendar_entry.dart';
import '../models/calendar_type.dart';
import '../models/calendar_view_mode.dart';
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
  CalendarViewMode _viewMode = CalendarViewMode.year;

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

    final showSelectedDayPanel =
        selectedDay != null && _viewMode != CalendarViewMode.month;

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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: _ViewModeSwitcher(
                currentMode: _viewMode,
                onChanged: (mode) {
                  setState(() {
                    _viewMode = mode;
                  });
                },
              ),
            ),
            Expanded(
              child: _buildActiveView(
                engine: engine,
                manager: manager,
                months: months,
                selectedMonthIndex: selectedMonthIndex,
                selectedDay: selectedDay,
                panelYear: panelYear,
                holidays: holidays,
                timelineEvents: timelineEvents,
              ),
            ),
            if (showSelectedDayPanel)
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

  Widget _buildActiveView({
    required dynamic engine,
    required CalendarManager manager,
    required List<String> months,
    required int selectedMonthIndex,
    required int? selectedDay,
    required int panelYear,
    required List<String> holidays,
    required List<String> timelineEvents,
  }) {
    switch (_viewMode) {
      case CalendarViewMode.year:
        return YearOverviewGrid(
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
        );

      case CalendarViewMode.month:
        return _MonthViewPanel(
          monthName: months[selectedMonthIndex],
          year: panelYear,
          daysInMonth: engine.getDaysInMonth(selectedMonthIndex, panelYear),
          selectedDay: selectedDay,
          todayMonthIndex: engine.getTodayMonthIndex(),
          todayDay: engine.getTodayDay(),
          selectedMonthIndex: selectedMonthIndex,
          onDayTap: (day) {
            manager.selectCalendarDate(
              monthIndex: selectedMonthIndex,
              day: day,
            );
          },
        );

      case CalendarViewMode.day:
        return _DayViewPanel(
          monthName: months[selectedMonthIndex],
          year: panelYear,
          selectedDay: selectedDay,
          culture: engine.displayName,
          holidays: holidays,
          timelineEvents: timelineEvents,
        );
    }
  }

  Future<void> _showStartupCalendarDialog(
    BuildContext context,
    CalendarManager manager,
  ) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Choose startup calendar',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 560,
              constraints: const BoxConstraints(maxWidth: 560),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE3E3E3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose your calendar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select the calendar you want this app to open with. You can change it later from the left menu.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...manager.availableCalendars.map(
                      (CalendarType type) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StartupCalendarCard(
                          title: manager.getEngine(type).displayName,
                          subtitle: _startupCardSubtitle(
                            manager.getEngine(type).displayName,
                          ),
                          isRecommended: type == CalendarType.gregorian,
                          onTap: () async {
                            await manager.chooseStartupCalendar(type);
                            if (mounted) Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          await manager.chooseStartupCalendar(
                            CalendarType.gregorian,
                          );
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text('Use Gregorian'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
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

  static String _startupCardSubtitle(String displayName) {
    if (displayName == 'Gregorian') {
      return 'Standard civil calendar';
    }
    if (displayName == 'Christian (Ussher Chronology)') {
      return 'Biblical year numbering and Christian observances';
    }
    if (displayName == 'Islamic (Hijri)') {
      return 'Hijri month names and Islamic observances';
    }
    if (displayName == '13-Month Calendar') {
      return 'Fixed 13-month structure with standalone identity';
    }
    return 'Standalone calendar mode';
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
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'MultiCul Calendar App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'App tools, information, and startup settings.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                children: [
                  _InfoActionCard(
                    icon: Icons.info_outline,
                    title: 'About $activeCalendarName',
                    subtitle: 'Read about the currently selected calendar.',
                    onTap: onAboutTap,
                  ),
                  _InfoActionCard(
                    icon: Icons.flag_outlined,
                    title: 'Choose startup calendar',
                    subtitle: 'Set which calendar opens when the app starts.',
                    onTap: onChooseStartupTap,
                  ),
                  _InfoActionCard(
                    icon: Icons.star_outline,
                    title: 'Rate this app',
                    subtitle: 'Rate support will be connected later.',
                    onTap: () {
                      Navigator.pop(context);
                      _showPlaceholderDialog(
                        context,
                        title: 'Rate this app',
                        message: 'Rating support will be connected later.',
                      );
                    },
                  ),
                  _InfoActionCard(
                    icon: Icons.share_outlined,
                    title: 'Share with a friend',
                    subtitle: 'Sharing support will be connected later.',
                    onTap: () {
                      Navigator.pop(context);
                      _showPlaceholderDialog(
                        context,
                        title: 'Share with a friend',
                        message: 'Sharing support will be connected later.',
                      );
                    },
                  ),
                  _InfoActionCard(
                    icon: Icons.favorite_border,
                    title: 'Donate',
                    subtitle: 'Donation support will be connected later.',
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
            ),
          ],
        ),
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

class _InfoActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InfoActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3E3E3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.black87),
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
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModeSwitcher extends StatelessWidget {
  final CalendarViewMode currentMode;
  final ValueChanged<CalendarViewMode> onChanged;

  const _ViewModeSwitcher({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Row(
        children: CalendarViewMode.values.map((mode) {
          final isSelected = mode == currentMode;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(mode),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black87 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mode.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MonthViewPanel extends StatelessWidget {
  final String monthName;
  final int year;
  final int daysInMonth;
  final int? selectedDay;
  final int todayMonthIndex;
  final int todayDay;
  final int selectedMonthIndex;
  final ValueChanged<int> onDayTap;

  const _MonthViewPanel({
    required this.monthName,
    required this.year,
    required this.daysInMonth,
    required this.selectedDay,
    required this.todayMonthIndex,
    required this.todayDay,
    required this.selectedMonthIndex,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 330;
            final titleSize = compact ? 18.0 : 20.0;
            final topGap = compact ? 8.0 : 12.0;
            final gridGap = compact ? 4.0 : 8.0;
            final weekdaySize = compact ? 9.0 : 11.0;
            final daySize = compact ? 11.0 : 14.0;

            return Column(
              children: [
                Text(
                  '$monthName $year',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: topGap),
                Row(
                  children: [
                    _MonthWeekday('M', fontSize: weekdaySize),
                    _MonthWeekday('T', fontSize: weekdaySize),
                    _MonthWeekday('W', fontSize: weekdaySize),
                    _MonthWeekday('T', fontSize: weekdaySize),
                    _MonthWeekday('F', fontSize: weekdaySize),
                    _MonthWeekday('S', fontSize: weekdaySize),
                    _MonthWeekday('S', fontSize: weekdaySize),
                  ],
                ),
                SizedBox(height: compact ? 6 : 10),
                Expanded(
                  child: GridView.builder(
                    itemCount: daysInMonth,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: gridGap,
                      crossAxisSpacing: gridGap,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isSelected = selectedDay == day;
                      final isToday = todayMonthIndex == selectedMonthIndex &&
                          todayDay == day;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onDayTap(day),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black87
                                : isToday
                                    ? Colors.grey.shade200
                                    : const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE3E3E3)),
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: TextStyle(
                                fontSize: daySize,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DayViewPanel extends StatelessWidget {
  final String monthName;
  final int year;
  final int? selectedDay;
  final String culture;
  final List<String> holidays;
  final List<String> timelineEvents;

  const _DayViewPanel({
    required this.monthName,
    required this.year,
    required this.selectedDay,
    required this.culture,
    required this.holidays,
    required this.timelineEvents,
  });

  @override
  Widget build(BuildContext context) {
    final observances = [...holidays, ...timelineEvents];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: selectedDay == null
            ? const Center(
                child: Text(
                  'Select a day to view its details.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$monthName $selectedDay, $year',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    culture,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Observances',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (observances.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE3E3E3)),
                      ),
                      child: const Text(
                        'No observances for this day.',
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  else
                    ...observances.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE3E3E3)),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _MonthWeekday extends StatelessWidget {
  final String label;
  final double fontSize;

  const _MonthWeekday(this.label, {required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _StartupCalendarCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isRecommended;
  final VoidCallback onTap;

  const _StartupCalendarCard({
    required this.title,
    required this.subtitle,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE3E3E3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
