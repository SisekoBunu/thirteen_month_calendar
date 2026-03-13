class ChristianTimelineEvent {
  final String name;
  final int gregorianMonth;
  final int gregorianDay;
  final String accuracyLabel;
  final String category;

  const ChristianTimelineEvent({
    required this.name,
    required this.gregorianMonth,
    required this.gregorianDay,
    required this.accuracyLabel,
    required this.category,
  });
}

class ChristianTimelineService {
  static const List<ChristianTimelineEvent> timelineEvents = [

    ChristianTimelineEvent(
      name: "Creation",
      gregorianMonth: 4,
      gregorianDay: 1,
      accuracyLabel: "traditional",
      category: "Biblical timeline",
    ),

    ChristianTimelineEvent(
      name: "Adam and Eve",
      gregorianMonth: 4,
      gregorianDay: 2,
      accuracyLabel: "traditional",
      category: "Biblical timeline",
    ),

    ChristianTimelineEvent(
      name: "Noah's Flood",
      gregorianMonth: 11,
      gregorianDay: 17,
      accuracyLabel: "approx.",
      category: "Biblical timeline",
    ),

    ChristianTimelineEvent(
      name: "Tower of Babel",
      gregorianMonth: 6,
      gregorianDay: 1,
      accuracyLabel: "estimated",
      category: "Biblical timeline",
    ),

    ChristianTimelineEvent(
      name: "Abraham",
      gregorianMonth: 10,
      gregorianDay: 1,
      accuracyLabel: "approx.",
      category: "Biblical timeline",
    ),

    ChristianTimelineEvent(
      name: "Moses",
      gregorianMonth: 3,
      gregorianDay: 1,
      accuracyLabel: "approx.",
      category: "Biblical timeline",
    ),

    ChristianTimelineEvent(
      name: "David",
      gregorianMonth: 5,
      gregorianDay: 1,
      accuracyLabel: "approx.",
      category: "Biblical timeline",
    ),

    ChristianTimelineEvent(
      name: "Birth of Jesus",
      gregorianMonth: 12,
      gregorianDay: 25,
      accuracyLabel: "traditional",
      category: "Biblical timeline",
    ),

    ChristianTimelineEvent(
      name: "Crucifixion",
      gregorianMonth: 4,
      gregorianDay: 3,
      accuracyLabel: "approx.",
      category: "Biblical timeline",
    ),

    ChristianTimelineEvent(
      name: "Resurrection",
      gregorianMonth: 4,
      gregorianDay: 5,
      accuracyLabel: "traditional",
      category: "Biblical timeline",
    ),

    ChristianTimelineEvent(
      name: "Pentecost",
      gregorianMonth: 5,
      gregorianDay: 24,
      accuracyLabel: "traditional",
      category: "Biblical timeline",
    ),

  ];
}
