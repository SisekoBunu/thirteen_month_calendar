class CultureConfig {
  final String name;
  final EraSystem eraSystem;
  final int yearOffset;

  const CultureConfig({
    required this.name,
    required this.eraSystem,
    this.yearOffset = 0,
  });
}

enum EraSystem {
  astronomical,
  christian,
  offset,
}

class CultureRegistry {
  static const Map<String, CultureConfig> cultures = {
    'Gregorian': CultureConfig(
      name: 'Gregorian',
      eraSystem: EraSystem.astronomical,
    ),
    'Christian': CultureConfig(
      name: 'Christian',
      eraSystem: EraSystem.christian,
    ),
    'Buddhist': CultureConfig(
      name: 'Buddhist',
      eraSystem: EraSystem.offset,
      yearOffset: 543,
    ),
    'Thai Solar': CultureConfig(
      name: 'Thai Solar',
      eraSystem: EraSystem.offset,
      yearOffset: 543,
    ),
    'Korean Dangi': CultureConfig(
      name: 'Korean Dangi',
      eraSystem: EraSystem.offset,
      yearOffset: 2333,
    ),
    'Islamic': CultureConfig(
      name: 'Islamic',
      eraSystem: EraSystem.astronomical,
    ),
    'Hebrew': CultureConfig(
      name: 'Hebrew',
      eraSystem: EraSystem.astronomical,
    ),
    'Chinese': CultureConfig(
      name: 'Chinese',
      eraSystem: EraSystem.astronomical,
    ),
    'Hindu': CultureConfig(
      name: 'Hindu',
      eraSystem: EraSystem.astronomical,
    ),
    'Persian': CultureConfig(
      name: 'Persian',
      eraSystem: EraSystem.astronomical,
    ),
    'Mayan': CultureConfig(
      name: 'Mayan',
      eraSystem: EraSystem.astronomical,
    ),
    'Ethiopian': CultureConfig(
      name: 'Ethiopian',
      eraSystem: EraSystem.astronomical,
    ),
    'Japanese Imperial': CultureConfig(
      name: 'Japanese Imperial',
      eraSystem: EraSystem.astronomical,
    ),
  };
}
