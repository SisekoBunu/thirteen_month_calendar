import 'package:flutter/material.dart';

class YearOverviewGrid extends StatelessWidget {
  final List<String> monthNames;
  final int selectedMonthIndex;
  final int? selectedDay;
  final int? todayMonthIndex;
  final int? todayDay;
  final bool highlightToday;
  final int Function(int monthIndex) daysInMonth;
  final ValueChanged<int> onMonthTap;
  final void Function(int monthIndex, int day) onDayTap;

  const YearOverviewGrid({
    super.key,
    required this.monthNames,
    required this.daysInMonth,
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
          childAspectRatio = 0.98;
        } else if (constraints.maxWidth >= 800) {
          crossAxisCount = 3;
          childAspectRatio = 0.95;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 0.93;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
          child: GridView.builder(
            itemCount: monthNames.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, monthIndex) {
              final monthDays = daysInMonth(monthIndex);
              final year = DateTime.now().year;
              final startOffset = DateTime(year, monthIndex + 1, 1).weekday - 1;
              final isSelectedMonth = monthIndex == selectedMonthIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelectedMonth
                        ? Colors.black87
                        : Colors.grey.shade300,
                    width: isSelectedMonth ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isSelectedMonth ? 0.06 : 0.03),
                      blurRadius: isSelectedMonth ? 10 : 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onMonthTap(monthIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Text(
                          monthNames[monthIndex],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelectedMonth
                                ? Colors.black
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
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
                    const SizedBox(height: 6),
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: monthDays + startOffset,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 3,
                          crossAxisSpacing: 3,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, dayIndex) {
                          if (dayIndex < startOffset) return const SizedBox.shrink();
                          final day = dayIndex - startOffset + 1;

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
