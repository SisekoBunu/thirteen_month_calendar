import 'package:flutter/material.dart';
import '../services/calendar_config.dart';

class CalendarGrid extends StatelessWidget {
  final int? selectedDay;
  final int? previewDay;
  final int? todayDay;
  final ValueChanged<int> onDayTap;

  const CalendarGrid({
    super.key,
    required this.selectedDay,
    required this.previewDay,
    required this.todayDay,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> weekdayNames = const [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        children: [
          Row(
            children: weekdayNames.map((dayName) {
              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      dayName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
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
          ),
        ],
      ),
    );
  }
}
