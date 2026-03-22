import 'package:flutter/material.dart';
import '../models/calendar_entry.dart';

class EntryEditorDialog extends StatefulWidget {
  final CalendarEntry? existing;
  final int year;
  final int monthIndex;
  final int day;

  const EntryEditorDialog({
    super.key,
    this.existing,
    required this.year,
    required this.monthIndex,
    required this.day,
  });

  @override
  State<EntryEditorDialog> createState() => _EntryEditorDialogState();
}

class _EntryEditorDialogState extends State<EntryEditorDialog> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  CalendarEntryType _selectedType = CalendarEntryType.event;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _detailsController.text = widget.existing!.details;
      _selectedType = widget.existing!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<CalendarEntryType>(
              value: _selectedType,
              isExpanded: true,
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
              items: CalendarEntryType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(labelText: 'Details'),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'No time selected',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedTime = picked);
                    }
                  },
                  child: const Text('Pick Time'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final entry = CalendarEntry(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: _selectedType,
              title: _titleController.text,
              details: _detailsController.text,
              timeLabel: _selectedTime != null
                  ? _selectedTime!.format(context)
                  : "",
              recurrence: CalendarEntryRecurrence.none,
              anchorYear: widget.year,
              anchorMonthIndex: widget.monthIndex,
              anchorDay: widget.day,
              recurrenceEndYear: null,
              recurrenceEndMonthIndex: null,
              recurrenceEndDay: null,
              excludedOrdinals: [],
            );

            Navigator.pop(context, entry);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
