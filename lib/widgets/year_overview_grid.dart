import 'package:flutter/material.dart';
import '../services/calendar_config.dart';

class YearOverviewGrid extends StatelessWidget {
  final int selectedMonthIndex;
  final int? selectedDay;
  final int? todayMonthIndex;
  final int? todayDay;
  final bool highlightToday;
  final ValueChanged<int> onMonthTap;
  final void Function(int monthIndex, int day) onDayTap;

  const YearOverviewGrid({
    super.key,
    required this.selectedMonthIndex,
    required this.selectedDay,
    required this.todayMonthIndex,
    required this.todayDay,
    required this.highlightToday,
    required this.onMonthTap,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
          childAspectRatio = 0.95;
        } else if (constraints.maxWidth >= 800) {
          crossAxisCount = 3;
          childAspectRatio = 0.92;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 0.9;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          child: GridView.builder(
            itemCount: CalendarConfig.monthNames.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, monthIndex) {
              final isSelectedMonth = monthIndex == selectedMonthIndex;

              return Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelectedMonth
                        ? Colors.black87
                        : Colors.grey.shade300,
                    width: isSelectedMonth ? 1.4 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onMonthTap(monthIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Text(
                          CalendarConfig.monthNames[monthIndex],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        _MiniWeekday('M'),
                        _MiniWeekday('T'),
                        _MiniWeekday('W'),
                        _MiniWeekday('T'),
                        _MiniWeekday('F'),
                        _MiniWeekday('S'),
                        _MiniWeekday('S'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 28,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, dayIndex) {
                          final day = dayIndex + 1;
                          final isSelectedDay =
                              isSelectedMonth && selectedDay == day;

                          final isToday = highlightToday &&
                              todayMonthIndex == monthIndex &&
                              todayDay == day;

                          Color backgroundColor = Colors.transparent;
                          Color textColor = Colors.black87;
                          FontWeight fontWeight = FontWeight.w500;

                          if (isSelectedDay) {
                            backgroundColor = Colors.black87;
                            textColor = Colors.white;
                            fontWeight = FontWeight.w700;
                          } else if (isToday) {
                            backgroundColor = Colors.grey.shade200;
                            textColor = Colors.black87;
                            fontWeight = FontWeight.w700;
                          }

                          return InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => onDayTap(monthIndex, day),
                            child: Container(
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: fontWeight,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MiniWeekday extends StatelessWidget {
  final String label;

  const _MiniWeekday(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
