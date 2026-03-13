class IslamicTimelineEvent {
  final String name;
  final int gregorianMonth;
  final int gregorianDay;
  final String accuracyLabel;
  final String category;

  const IslamicTimelineEvent({
    required this.name,
    required this.gregorianMonth,
    required this.gregorianDay,
    required this.accuracyLabel,
    required this.category,
  });
}

class IslamicTimelineService {
  static const List<IslamicTimelineEvent> timelineEvents = [

    IslamicTimelineEvent(
      name: "Creation of Adam",
      gregorianMonth: 4,
      gregorianDay: 1,
      accuracyLabel: "traditional",
      category: "Islamic timeline",
    ),

    IslamicTimelineEvent(
      name: "Hawwa (Eve)",
      gregorianMonth: 4,
      gregorianDay: 2,
      accuracyLabel: "traditional",
      category: "Islamic timeline",
    ),

    IslamicTimelineEvent(
      name: "Nuh and the Flood",
      gregorianMonth: 11,
      gregorianDay: 17,
      accuracyLabel: "approx.",
      category: "Islamic timeline",
    ),

    IslamicTimelineEvent(
      name: "Ibrahim and the Kaaba",
      gregorianMonth: 10,
      gregorianDay: 1,
      accuracyLabel: "approx.",
      category: "Islamic timeline",
    ),

    IslamicTimelineEvent(
      name: "Musa and Pharaoh",
      gregorianMonth: 3,
      gregorianDay: 1,
      accuracyLabel: "approx.",
      category: "Islamic timeline",
    ),

    IslamicTimelineEvent(
      name: "Isa as Prophet",
      gregorianMonth: 12,
      gregorianDay: 25,
      accuracyLabel: "traditional",
      category: "Islamic timeline",
    ),

    IslamicTimelineEvent(
      name: "Birth of Prophet Muhammad",
      gregorianMonth: 4,
      gregorianDay: 22,
      accuracyLabel: "traditional",
      category: "Islamic timeline",
    ),

    IslamicTimelineEvent(
      name: "First Revelation",
      gregorianMonth: 8,
      gregorianDay: 10,
      accuracyLabel: "approx.",
      category: "Islamic timeline",
    ),

    IslamicTimelineEvent(
      name: "Hijra to Medina",
      gregorianMonth: 7,
      gregorianDay: 16,
      accuracyLabel: "historical",
      category: "Islamic timeline",
    ),

    IslamicTimelineEvent(
      name: "Conquest of Mecca",
      gregorianMonth: 1,
      gregorianDay: 11,
      accuracyLabel: "historical",
      category: "Islamic timeline",
    ),

    IslamicTimelineEvent(
      name: "Death of Prophet Muhammad",
      gregorianMonth: 6,
      gregorianDay: 8,
      accuracyLabel: "historical",
      category: "Islamic timeline",
    ),

  ];
}
