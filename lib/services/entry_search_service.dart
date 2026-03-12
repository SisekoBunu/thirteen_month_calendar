import '../models/calendar_entry.dart';
import '../models/calendar_search_result.dart';
import 'calendar_config.dart';
import 'calendar_logic.dart';

class EntrySearchService {
  static List<CalendarSearchResult> searchEntries({
    required Map<String, List<CalendarEntry>> entriesByDate,
    required String query,
    String? culture,
  }) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    final results = <CalendarSearchResult>[];
    final seen = <String>{};

    for (final mapEntry in entriesByDate.entries) {
      final keyParts = mapEntry.key.split('|');
      if (keyParts.length != 4) {
        continue;
      }

      final entryCulture = keyParts[0];
      final year = int.tryParse(keyParts[1]);
      final monthIndex = int.tryParse(keyParts[2]);
      final day = int.tryParse(keyParts[3]);

      if (year == null || monthIndex == null || day == null) {
        continue;
      }

      if (culture != null && entryCulture != culture) {
        continue;
      }

      for (final entry in mapEntry.value) {
        if (_matchesEntry(
          entry: entry,
          year: year,
          monthIndex: monthIndex,
          day: day,
          query: trimmedQuery,
        )) {
          final dedupeKey = '${entry.id}|$year|$monthIndex|$day';
          if (seen.add(dedupeKey)) {
            results.add(
              CalendarSearchResult(
                storageKey: mapEntry.key,
                culture: entryCulture,
                year: year,
                monthIndex: monthIndex,
                day: day,
                entry: entry,
                isRecurringMatch: false,
              ),
            );
          }
        }
      }
    }

    final recurringResults = _searchRecurringOccurrences(
      entriesByDate: entriesByDate,
      query: trimmedQuery,
      culture: culture,
      existingKeys: seen,
    );

    results.addAll(recurringResults);

    results.sort((a, b) {
      final ordinalA = _customOrdinal(
        year: a.year,
        monthIndex: a.monthIndex,
        day: a.day,
      );
      final ordinalB = _customOrdinal(
        year: b.year,
        monthIndex: b.monthIndex,
        day: b.day,
      );
      return ordinalA.compareTo(ordinalB);
    });

    return results;
  }

  static List<CalendarSearchResult> _searchRecurringOccurrences({
    required Map<String, List<CalendarEntry>> entriesByDate,
    required String query,
    required String? culture,
    required Set<String> existingKeys,
  }) {
    final results = <CalendarSearchResult>[];

    for (final mapEntry in entriesByDate.entries) {
      final keyParts = mapEntry.key.split('|');
      if (keyParts.length != 4) {
        continue;
      }

      final entryCulture = keyParts[0];
      if (culture != null && entryCulture != culture) {
        continue;
      }

      for (final entry in mapEntry.value) {
        if (entry.recurrence == CalendarEntryRecurrence.none) {
          continue;
        }

        final anchorMatches = _matchesEntry(
          entry: entry,
          year: entry.anchorYear,
          monthIndex: entry.anchorMonthIndex,
          day: entry.anchorDay,
          query: query,
        );

        if (!anchorMatches) {
          continue;
        }

        final occurrences = _expandOccurrences(entry);

        for (final occurrence in occurrences) {
          final dedupeKey =
              '${entry.id}|${occurrence.year}|${occurrence.monthIndex}|${occurrence.day}';

          if (existingKeys.add(dedupeKey)) {
            results.add(
              CalendarSearchResult(
                storageKey: mapEntry.key,
                culture: entryCulture,
                year: occurrence.year,
                monthIndex: occurrence.monthIndex,
                day: occurrence.day,
                entry: entry,
                isRecurringMatch: occurrence.year != entry.anchorYear ||
                    occurrence.monthIndex != entry.anchorMonthIndex ||
                    occurrence.day != entry.anchorDay,
              ),
            );
          }
        }
      }
    }

    return results;
  }

  static bool _matchesEntry({
    required CalendarEntry entry,
    required int year,
    required int monthIndex,
    required int day,
    required String query,
  }) {
    final monthName = CalendarConfig.monthNames[monthIndex].toLowerCase();
    final dateText = '$day $monthName $year'.toLowerCase();
    final isoLikeDate = '$year-${(monthIndex + 1).toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    return entry.title.toLowerCase().contains(query) ||
        entry.details.toLowerCase().contains(query) ||
        dateText.contains(query) ||
        isoLikeDate.contains(query);
  }

  static List<_OccurrenceDate> _expandOccurrences(CalendarEntry entry) {
    final results = <_OccurrenceDate>[];

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
        : anchorOrdinal + (CalendarConfig.monthsPerYear * CalendarConfig.daysPerMonth * 4);

    for (int ordinal = anchorOrdinal; ordinal <= endOrdinal; ordinal++) {
      if (entry.excludedOrdinals.contains(ordinal)) {
        continue;
      }

      final date = _ordinalToDate(ordinal);

      if (_matchesRecurringDate(
        entry: entry,
        selectedYear: date.year,
        selectedMonthIndex: date.monthIndex,
        selectedDay: date.day,
      )) {
        results.add(date);
      }
    }

    return results;
  }

  static bool _matchesRecurringDate({
    required CalendarEntry entry,
    required int selectedYear,
    required int selectedMonthIndex,
    required int selectedDay,
  }) {
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
      final recurrenceEndOrdinal = _customOrdinal(
        year: entry.recurrenceEndYear!,
        monthIndex: entry.recurrenceEndMonthIndex!,
        day: entry.recurrenceEndDay!,
      );

      if (selectedOrdinal > recurrenceEndOrdinal) {
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

  static int _customOrdinal({
    required int year,
    required int monthIndex,
    required int day,
  }) {
    int total = 0;

    for (int y = 1; y < year; y++) {
      total += CalendarLogic.daysInCustomYear(y);
    }

    total += (monthIndex * CalendarConfig.daysPerMonth);
    total += day;

    return total;
  }

  static _OccurrenceDate _ordinalToDate(int ordinal) {
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

    final monthIndex = remaining ~/ CalendarConfig.daysPerMonth;
    final day = (remaining % CalendarConfig.daysPerMonth) + 1;

    return _OccurrenceDate(
      year: year,
      monthIndex: monthIndex,
      day: day,
    );
  }
}

class _OccurrenceDate {
  final int year;
  final int monthIndex;
  final int day;

  const _OccurrenceDate({
    required this.year,
    required this.monthIndex,
    required this.day,
  });
}
