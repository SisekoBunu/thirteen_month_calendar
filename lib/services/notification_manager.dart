import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/calendar_entry.dart';
import '../models/notification_schedule_item.dart';
import 'calendar_logic.dart';
import 'notification_service.dart';
import 'notification_service_factory_default.dart'
    if (dart.library.html) 'notification_service_factory_web.dart'
    if (dart.library.io) 'notification_service_factory_io.dart';

class NotificationManager {
  NotificationManager._();

  static final NotificationService instance = createPlatformNotificationService();

  static Future<void> initialize() async {
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      // Fallback to tz.local as initialized in main.dart
    }

    await instance.initialize();
  }

  static Future<bool> requestPermission() async {
    return instance.requestPermission();
  }

  static Future<void> syncFromEntries(
    Map<String, List<CalendarEntry>> entriesByDate,
  ) async {
    final items = <NotificationScheduleItem>[];

    for (final mapEntry in entriesByDate.entries) {
      final keyParts = mapEntry.key.split('|');
      if (keyParts.length != 4) {
        continue;
      }

      final storageKey = mapEntry.key;
      final year = int.tryParse(keyParts[1]);
      final monthIndex = int.tryParse(keyParts[2]);
      final day = int.tryParse(keyParts[3]);

      if (year == null || monthIndex == null || day == null) {
        continue;
      }

      for (final entry in mapEntry.value) {
        if (entry.type == CalendarEntryType.event) {
          continue;
        }

        final scheduledItems = _buildScheduleItemsForEntry(
          entry: entry,
          storageKey: storageKey,
          year: year,
          monthIndex: monthIndex,
          day: day,
        );

        items.addAll(scheduledItems);
      }
    }

    await instance.syncSchedules(items);
  }

  static Future<void> cancelByEntryId(String entryId) async {
    await instance.cancelByEntryId(entryId);
  }

  static List<NotificationScheduleItem> _buildScheduleItemsForEntry({
    required CalendarEntry entry,
    required String storageKey,
    required int year,
    required int monthIndex,
    required int day,
  }) {
    final parsedTime = _parseTime(entry.timeLabel);
    if (parsedTime == null) {
      return [];
    }

    final items = <NotificationScheduleItem>[];

    final firstDate = CalendarLogic.convertCustomToGregorianDate(
      year,
      monthIndex,
      day,
    );

    final firstScheduledAt = DateTime(
      firstDate.year,
      firstDate.month,
      firstDate.day,
      parsedTime.$1,
      parsedTime.$2,
    );

    if (entry.recurrence == CalendarEntryRecurrence.none) {
      items.add(
        NotificationScheduleItem(
          entryId: entry.id,
          storageKey: storageKey,
          type: entry.type,
          title: entry.title,
          body: entry.details,
          scheduledAt: firstScheduledAt,
          isRecurring: false,
        ),
      );
      return items;
    }

    final anchorOrdinal = _customOrdinal(
      year: entry.anchorYear,
      monthIndex: entry.anchorMonthIndex,
      day: entry.anchorDay,
    );

    final endOrdinal = entry.hasRecurrenceEnd
        ? _customOrdinal(
            year: entry.recurrenceEndYear!,
            monthIndex: entry.recurrenceEndMonthIndex!,
            day: entry.recurrenceEndDay!,
          )
        : anchorOrdinal + 366;

    int occurrenceIndex = 0;

    for (int ordinal = anchorOrdinal; ordinal <= endOrdinal; ordinal++) {
      if (entry.excludedOrdinals.contains(ordinal)) {
        continue;
      }

      final occurrence = _ordinalToCustomDate(ordinal);

      if (!_matchesRecurringDate(
        entry: entry,
        selectedYear: occurrence.year,
        selectedMonthIndex: occurrence.monthIndex,
        selectedDay: occurrence.day,
      )) {
        continue;
      }

      final gregorian = CalendarLogic.convertCustomToGregorianDate(
        occurrence.year,
        occurrence.monthIndex,
        occurrence.day,
      );

      final scheduledAt = DateTime(
        gregorian.year,
        gregorian.month,
        gregorian.day,
        parsedTime.$1,
        parsedTime.$2,
      );

      items.add(
        NotificationScheduleItem(
          entryId: '${entry.id}__$occurrenceIndex',
          storageKey: storageKey,
          type: entry.type,
          title: entry.title,
          body: entry.details,
          scheduledAt: scheduledAt,
          isRecurring: true,
        ),
      );

      occurrenceIndex++;
    }

    return items;
  }

  static (int, int)? _parseTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
    if (match == null) {
      return null;
    }

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);

    if (hour == null || minute == null) {
      return null;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return (hour, minute);
  }

  static int _customOrdinal({
    required int year,
    required int monthIndex,
    required int day,
  }) {
    int total = 0;

    for (int y = 1; y < year; y++) {
      total += CalendarLogic.daysInCustomYear(y);
    }

    total += (monthIndex * 28);
    total += day;

    return total;
  }

  static _CustomDate _ordinalToCustomDate(int ordinal) {
    int remaining = ordinal - 1;
    int year = 1;

    while (true) {
      final yearLength = CalendarLogic.daysInCustomYear(year);
      if (remaining < yearLength) {
        break;
      }
      remaining -= yearLength;
      year++;
    }

    final monthIndex = remaining ~/ 28;
    final day = (remaining % 28) + 1;

    return _CustomDate(
      year: year,
      monthIndex: monthIndex,
      day: day,
    );
  }

  static bool _matchesRecurringDate({
    required CalendarEntry entry,
    required int selectedYear,
    required int selectedMonthIndex,
    required int selectedDay,
  }) {
    if (entry.recurrence == CalendarEntryRecurrence.none) {
      return false;
    }

    final anchorOrdinal = _customOrdinal(
      year: entry.anchorYear,
      monthIndex: entry.anchorMonthIndex,
      day: entry.anchorDay,
    );

    final selectedOrdinal = _customOrdinal(
      year: selectedYear,
      monthIndex: selectedMonthIndex,
      day: selectedDay,
    );

    if (selectedOrdinal < anchorOrdinal) {
      return false;
    }

    if (entry.excludedOrdinals.contains(selectedOrdinal)) {
      return false;
    }

    if (entry.hasRecurrenceEnd) {
      final endOrdinal = _customOrdinal(
        year: entry.recurrenceEndYear!,
        monthIndex: entry.recurrenceEndMonthIndex!,
        day: entry.recurrenceEndDay!,
      );

      if (selectedOrdinal > endOrdinal) {
        return false;
      }
    }

    final difference = selectedOrdinal - anchorOrdinal;

    switch (entry.recurrence) {
      case CalendarEntryRecurrence.none:
        return false;
      case CalendarEntryRecurrence.daily:
        return true;
      case CalendarEntryRecurrence.weekly:
        return difference % 7 == 0;
      case CalendarEntryRecurrence.monthly:
        return selectedDay == entry.anchorDay;
      case CalendarEntryRecurrence.yearly:
        return selectedMonthIndex == entry.anchorMonthIndex &&
            selectedDay == entry.anchorDay;
    }
  }
}

class _CustomDate {
  final int year;
  final int monthIndex;
  final int day;

  const _CustomDate({
    required this.year,
    required this.monthIndex,
    required this.day,
  });
}
