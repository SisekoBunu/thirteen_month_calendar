import 'package:flutter/material.dart';

class CalendarSettingsDrawer extends StatelessWidget {
  final String currentCulture;
  final String? currentCountry;
  final List<String> cultureOptions;
  final List<String> gregorianCountryOptions;
  final ValueChanged<String> onCultureSelected;
  final ValueChanged<String> onCountrySelected;
  final VoidCallback onNotificationsTap;
  final VoidCallback onTimezoneTap;
  final VoidCallback onSettingsTap;

  const CalendarSettingsDrawer({
    super.key,
    required this.currentCulture,
    required this.currentCountry,
    required this.cultureOptions,
    required this.gregorianCountryOptions,
    required this.onCultureSelected,
    required this.onCountrySelected,
    required this.onNotificationsTap,
    required this.onTimezoneTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Calendar Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(),
            ExpansionTile(
              initiallyExpanded: false,
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text(
                'Calendar System',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(currentCulture),
              children: cultureOptions
                  .map(
                    (culture) => ListTile(
                      title: Text(culture),
                      trailing: culture == currentCulture
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () {
                        Navigator.of(context).pop();
                        onCultureSelected(culture);
                      },
                    ),
                  )
                  .toList(),
            ),
            if (currentCulture == 'Gregorian')
              ExpansionTile(
                initiallyExpanded: false,
                leading: const Icon(Icons.flag_outlined),
                title: const Text(
                  'Holiday Region',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(currentCountry ?? 'International'),
                children: gregorianCountryOptions
                    .map(
                      (country) => ListTile(
                        title: Text(country),
                        trailing: country == (currentCountry ?? 'International')
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          Navigator.of(context).pop();
                          onCountrySelected(country);
                        },
                      ),
                    )
                    .toList(),
              ),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onNotificationsTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.public_outlined),
              title: const Text(
                'Timezone',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onTimezoneTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onSettingsTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}
