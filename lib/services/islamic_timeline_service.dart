class IslamicTimelineEvent {
  final String name;
  final int month;
  final int day;
  final String accuracyLabel;
  final String category;

  const IslamicTimelineEvent({
    required this.name,
    required this.month,
    required this.day,
    required this.accuracyLabel,
    required this.category,
  });
}

class IslamicTimelineService {
  static const List<IslamicTimelineEvent> timelineEvents = [
    IslamicTimelineEvent(
      name: "Hijra to Madinah",
      month: 1,
      day: 1,
      accuracyLabel: "historical",
      category: "Islamic timeline",
    ),
    IslamicTimelineEvent(
      name: "Ashura",
      month: 1,
      day: 10,
      accuracyLabel: "traditional",
      category: "Islamic observance",
    ),
    IslamicTimelineEvent(
      name: "Mawlid al-Nabi",
      month: 3,
      day: 12,
      accuracyLabel: "traditional",
      category: "Islamic observance",
    ),
    IslamicTimelineEvent(
      name: "Laylat al-Barat",
      month: 8,
      day: 15,
      accuracyLabel: "traditional",
      category: "Islamic observance",
    ),
    IslamicTimelineEvent(
      name: "Laylat al-Qadr",
      month: 9,
      day: 27,
      accuracyLabel: "traditional",
      category: "Islamic observance",
    ),
    IslamicTimelineEvent(
      name: "Hajj Days",
      month: 12,
      day: 8,
      accuracyLabel: "religious",
      category: "Islamic observance",
    ),
    IslamicTimelineEvent(
      name: "Day of Arafah",
      month: 12,
      day: 9,
      accuracyLabel: "religious",
      category: "Islamic observance",
    ),
  ];
}
