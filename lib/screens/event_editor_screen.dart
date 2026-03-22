import 'package:flutter/material.dart';
import '../models/calendar_entry.dart';

class EventEditorScreen extends StatefulWidget {
  final int year;
  final int monthIndex;
  final int day;

  const EventEditorScreen({
    super.key,
    required this.year,
    required this.monthIndex,
    required this.day,
  });

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  bool _allDay = false;

  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  CalendarEntryRecurrence _recurrence = CalendarEntryRecurrence.none;

  @override
  void initState() {
    super.initState();

    _startDate = DateTime(widget.year, widget.monthIndex + 1, widget.day);
    _endDate = DateTime(widget.year, widget.monthIndex + 1, widget.day);
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay(
      hour: (_startTime.hour + 1) % 24,
      minute: _startTime.minute,
    );
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _allDay
    ? 'All Day'
    : '${_startTime.format(context)} - ${_endTime.format(context)}';

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        leadingWidth: 90,
        title: const Text('New Event'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              final entry = CalendarEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: CalendarEntryType.event,
                title: _titleController.text.trim(),
                details: [
  if (_locationController.text.trim().isNotEmpty)
    'Location: ${_locationController.text.trim()}',
  if (_notesController.text.trim().isNotEmpty)
    'Notes: ${_notesController.text.trim()}',
].join('\n'),
                timeLabel: timeLabel,
                recurrence: _recurrence,
                anchorYear: _startDate.year,
                anchorMonthIndex: _startDate.month - 1,
                anchorDay: _startDate.day,
                recurrenceEndYear: _recurrence == CalendarEntryRecurrence.none
                    ? null
                    : _endDate.year,
                recurrenceEndMonthIndex:
                    _recurrence == CalendarEntryRecurrence.none
                        ? null
                        : _endDate.month - 1,
                recurrenceEndDay: _recurrence == CalendarEntryRecurrence.none
                    ? null
                    : _endDate.day,
                excludedOrdinals: [],
              );

              Navigator.pop(context, entry);
            },
            child: const Text('Add'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('All Day'),
            value: _allDay,
            onChanged: (value) {
              setState(() {
                _allDay = value;
              });
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Starts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickStartDate,
                  child: Text(_formatDate(_startDate)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _allDay ? null : _pickStartTime,
                  child: Text(
                    _allDay ? 'All Day' : _startTime.format(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Ends',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickEndDate,
                  child: Text(_formatDate(_startDate)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _allDay ? null : _pickEndTime,
                  child: Text(
                    _allDay ? 'All Day' : _endTime.format(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<CalendarEntryRecurrence>(
            value: _recurrence,
            decoration: const InputDecoration(
              labelText: 'Repeat',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _recurrence = value;
                });
              }
            },
            items: CalendarEntryRecurrence.values.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value.name.toUpperCase()),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}









