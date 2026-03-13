import 'package:flutter/material.dart';
import '../models/calendar_entry.dart';
import '../services/calendar_logic.dart';

class SelectedDayPanel extends StatelessWidget {
  final String monthName;
  final int year;
  final String culture;
  final int monthIndex;
  final int? selectedDay;
  final List<CalendarEntry> entries;
  final List<String> holidays;
  final List<String> timelineEvents;
  final VoidCallback onClose;
  final VoidCallback onAddEntry;
  final void Function(CalendarEntry entry) onEditEntry;
  final Future<void> Function(String id) onDeleteEntry;
  final String Function(CalendarEntry entry) recurrenceSummaryBuilder;

  const SelectedDayPanel({
    super.key,
    required this.monthName,
    required this.year,
    required this.culture,
    required this.monthIndex,
    required this.selectedDay,
    required this.entries,
    required this.holidays,
    required this.timelineEvents,
    required this.onClose,
    required this.onAddEntry,
    required this.onEditEntry,
    required this.onDeleteEntry,
    required this.recurrenceSummaryBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null) {
      return const SizedBox.shrink();
    }

    final gregorian = CalendarLogic.convertCustomToGregorianDate(
      year,
      monthIndex,
      selectedDay!,
    );

    final gregorianLabel =
        '${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(2, '0')}';

    final eventCount =
        entries.where((e) => e.type == CalendarEntryType.event).length;
    final reminderCount =
        entries.where((e) => e.type == CalendarEntryType.reminder).length;
    final alarmCount =
        entries.where((e) => e.type == CalendarEntryType.alarm).length;

    final allObservances = <String>[
      ...holidays,
      ...timelineEvents,
    ];

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
          const SizedBox(height: 4),
          Text(
            'Gregorian equivalent: $gregorianLabel',
            style: const TextStyle(
              fontSize: 14,
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
            'Observances: ${allObservances.length}',
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 14),
          const Text(
            'Entries',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            _placeholderCard('No entries yet')
          else
            ...entries.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE3E3E3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _typeColor(entry.type),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _typeLabel(entry.type),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          if (entry.timeLabel.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              entry.timeLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            recurrenceSummaryBuilder(entry),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          if (entry.details.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              entry.details,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onEditEntry(entry),
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      onPressed: () async => await onDeleteEntry(entry.id),
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 18),
          const Text(
            'Holidays & Observances',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          if (allObservances.isEmpty)
            _placeholderCard('No holidays yet')
          else
            ...allObservances.map(
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
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholderCard(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
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

  static Color _typeColor(CalendarEntryType type) {
    switch (type) {
      case CalendarEntryType.event:
        return Colors.blue;
      case CalendarEntryType.reminder:
        return Colors.orange;
      case CalendarEntryType.alarm:
        return Colors.red;
    }
  }
}
