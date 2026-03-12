import 'package:flutter/material.dart';

import '../models/calendar_search_result.dart';
import '../services/calendar_config.dart';

class EntrySearchDialog extends StatefulWidget {
  final List<CalendarSearchResult> Function(String query) onSearch;
  final void Function(CalendarSearchResult result) onResultTap;

  const EntrySearchDialog({
    super.key,
    required this.onSearch,
    required this.onResultTap,
  });

  @override
  State<EntrySearchDialog> createState() => _EntrySearchDialogState();
}

class _EntrySearchDialogState extends State<EntrySearchDialog> {
  final TextEditingController _controller = TextEditingController();
  List<CalendarSearchResult> _results = const [];

  void _runSearch(String value) {
    setState(() {
      _results = widget.onSearch(value);
    });
  }

  String _typeLabel(String typeName) {
    switch (typeName) {
      case 'event':
        return 'Event';
      case 'reminder':
        return 'Reminder';
      case 'alarm':
        return 'Alarm';
      default:
        return typeName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search entries'),
      content: SizedBox(
        width: 700,
        height: 500,
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Search by title, details, or date',
                hintText: 'e.g. meeting, dentist, 14 Sol 2026',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _runSearch,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _controller.text.trim().isEmpty
                  ? const Center(
                      child: Text(
                        'Start typing to search your entries.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : _results.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching entries found.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final result = _results[index];
                            final entry = result.entry;
                            final monthName =
                                CalendarConfig.monthNames[result.monthIndex];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                onTap: () {
                                  widget.onResultTap(result);
                                  Navigator.of(context).pop();
                                },
                                leading: const Icon(Icons.event_note),
                                title: Text(entry.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_typeLabel(entry.type.name)} • $monthName ${result.day}, ${result.year} • ${result.culture}',
                                    ),
                                    if (result.isRecurringMatch)
                                      const Text(
                                        'Recurring occurrence',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    if (entry.timeLabel.trim().isNotEmpty)
                                      Text(entry.timeLabel),
                                    if (entry.details.trim().isNotEmpty)
                                      Text(
                                        entry.details,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
