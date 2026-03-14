import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/calendar_manager.dart';
import '../models/calendar_type.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<CalendarManager>();

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
                    'Choose Calendar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Switch between standalone calendar systems.',
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
                children: manager.availableCalendars.map((CalendarType type) {
                  final engine = manager.getEngine(type);
                  final isSelected = manager.activeType == type;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        manager.setActiveCalendar(type);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1F1F1F)
                              : const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1F1F1F)
                                : const Color(0xFFE3E3E3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isSelected ? 0.08 : 0.03,
                              ),
                              blurRadius: isSelected ? 10 : 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    engine.displayName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _calendarSubtitle(engine.displayName),
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.3,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.chevron_right,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calendarSubtitle(String displayName) {
    if (displayName == 'Gregorian') {
      return 'Standard civil calendar';
    }
    if (displayName == 'Christian (Ussher Chronology)') {
      return 'Christian year count and observances';
    }
    if (displayName == 'Islamic (Hijri)') {
      return 'Hijri month names and observances';
    }
    if (displayName == '13-Month Calendar') {
      return 'Fixed 13-month standalone calendar';
    }
    return 'Standalone calendar mode';
  }
}
