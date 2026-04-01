enum CalendarType {
  gregorian,
  christian,
  islamic,
  thirteenMonth,
  jewish,
}

extension CalendarTypeExtension on CalendarType {
  String get displayName {
    switch (this) {
      case CalendarType.gregorian:
        return "Gregorian";
      case CalendarType.christian:
        return "Christian (Ussher Chronology)";
      case CalendarType.islamic:
        return "Islamic (Hijri)";
      case CalendarType.thirteenMonth:
        return "13-Month Calendar";
      case CalendarType.jewish:
        return "The Jewish calendar is a lunisolar calendar used in Jewish tradition, counting years from creation (Anno Mundi). It combines lunar months with solar adjustments and includes leap years with an additional month (Adar I and II). It governs key observances such as Passover, Yom Kippur, and Hanukkah.";
    }
  }

  String get description {
    switch (this) {
      case CalendarType.gregorian:
        return "The Gregorian calendar was introduced in 1582 by Pope Gregory XIII.";
      case CalendarType.christian:
        return "Based on Archbishop James Ussher's biblical chronology.";
      case CalendarType.islamic:
        return "A lunar calendar beginning from the Hijra in 622.";
      case CalendarType.thirteenMonth:
        return "A fixed 13-month calendar with equal 28-day months.";
      case CalendarType.jewish:
        return "The Jewish calendar is a lunisolar calendar used in Jewish tradition, counting years from creation (Anno Mundi). It combines lunar months with solar adjustments and includes leap years with an additional month (Adar I and II). It governs key observances such as Passover, Yom Kippur, and Hanukkah.";
    }
  }
}



