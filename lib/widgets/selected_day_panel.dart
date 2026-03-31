import 'package:flutter/material.dart';
import '../models/calendar_entry.dart';

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
  final Future<void> Function(CalendarEntry entry) onDeleteEntry;
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
    if (selectedDay == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Selected Day",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: onAddEntry,
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              " , ",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            if (holidays.isNotEmpty) ...[
              const Text(
                "Observances",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...holidays.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text("• "),
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (timelineEvents.isNotEmpty) ...[
              const Text(
                "Timeline / Religious Notes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...timelineEvents.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text("• "),
                ),
              ),
              const SizedBox(height: 10),
            ],

            const Text(
              "Your Entries",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            if (entries.isEmpty)
              const Text("No entries yet")
            else
              ...entries.map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (e.timeLabel.isNotEmpty) Text(e.timeLabel),
                      if (e.details.isNotEmpty) Text(e.details),
                      Text(recurrenceSummaryBuilder(e)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEditEntry(e),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => onDeleteEntry(e),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
