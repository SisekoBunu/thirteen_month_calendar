import 'package:flutter/material.dart';
import '../models/calendar_entry.dart';

class SelectedDayPanel extends StatelessWidget {
  final String monthName;
  final int year;
  final String culture;
  final int? selectedDay;
  final List<CalendarEntry> entries;
  final List<String> holidays;
  final VoidCallback onClose;
  final VoidCallback onAddEntry;

  const SelectedDayPanel({
    super.key,
    required this.monthName,
    required this.year,
    required this.culture,
    required this.selectedDay,
    required this.entries,
    required this.holidays,
    required this.onClose,
    required this.onAddEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null) {
      return const SizedBox.shrink();
    }

    final eventCount =
        entries.where((e) => e.type == CalendarEntryType.event).length;
    final reminderCount =
        entries.where((e) => e.type == CalendarEntryType.reminder).length;
    final alarmCount =
        entries.where((e) => e.type == CalendarEntryType.alarm).length;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Selected Day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              IconButton(
                onPressed: onAddEntry,
                tooltip: 'Add entry',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add, size: 20),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: 'Close',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$monthName $selectedDay, $year',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            culture,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Events: $eventCount',
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            'Reminders: $reminderCount',
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            'Alarms: $alarmCount',
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            'Holidays: ${holidays.length}',
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Latest items',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...entries.take(3).map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• ${_typeLabel(entry.type)}: ${entry.title}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
          ],
          if (holidays.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Holidays & observances',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...holidays.map(
              (holiday) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $holiday',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
          ],
        ],
      ),
    );
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
}
