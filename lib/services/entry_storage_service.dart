import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/calendar_entry.dart';

class EntryStorageService {
  static const String _boxName = 'calendar_entries_box';
  static const String _entriesKey = 'entries_by_date';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Future<Map<String, List<CalendarEntry>>> loadEntriesByDate() async {
    final box = Hive.box(_boxName);
    final raw = box.get(_entriesKey);

    if (raw == null) {
      return {};
    }

    try {
      final decoded = jsonDecode(raw as String) as Map<String, dynamic>;

      return decoded.map((key, value) {
        final items = (value as List<dynamic>)
            .map(
              (item) => CalendarEntry.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        return MapEntry(key, items);
      });
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveEntriesByDate(
    Map<String, List<CalendarEntry>> entriesByDate,
  ) async {
    final box = Hive.box(_boxName);

    final serializable = entriesByDate.map(
      (key, value) => MapEntry(
        key,
        value.map((entry) => entry.toJson()).toList(),
      ),
    );

    await box.put(_entriesKey, jsonEncode(serializable));
  }
}
