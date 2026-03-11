import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  Widget _infoCard({
    required String title,
    required List<String> paragraphs,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          ...paragraphs.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, size: 30),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'How It Works',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  children: [
                    _infoCard(
                      title: 'Views',
                      paragraphs: const [
                        'Month View shows one month at a time. Year View shows the full year at a glance. Day View gives more room to focus on one date and the things attached to it.',
                        'The Today button takes you back to the current month and highlights today without forcing the details panel open.',
                      ],
                    ),
                    _infoCard(
                      title: 'Selecting a day',
                      paragraphs: const [
                        'When you tap a day in Month View, the selected day panel opens below the grid. That panel shows the chosen date, its Gregorian equivalent, entries for that day, and any holidays or observances.',
                        'You can also manage entries from that smaller panel without needing to switch to the full Day View every time.',
                      ],
                    ),
                    _infoCard(
                      title: 'Entries',
                      paragraphs: const [
                        'You can add three kinds of entries: events, reminders, and alarms. Entries can include a title, optional time, and optional details.',
                        'Entries can also be edited or deleted after they are created.',
                      ],
                    ),
                    _infoCard(
                      title: 'Gregorian equivalent and holidays',
                      paragraphs: const [
                        'When you select a date, the app shows the Gregorian equivalent so you can understand where that date falls in the normal civil calendar.',
                        'Holiday and observance information can also be shown, along with how those dates line up relative to the Gregorian calendar.',
                      ],
                    ),
                    _infoCard(
                      title: 'Culture and country selection',
                      paragraphs: const [
                        'The culture selector is used to switch the calendar profile. Gregorian is the current main profile being completed first.',
                        'For Gregorian, the country selector lets you switch between different holiday packs such as International, South Africa, USA, United Kingdom, Canada, Australia, and New Zealand.',
                      ],
                    ),
                    _infoCard(
                      title: 'Current development stage',
                      paragraphs: const [
                        'The app already supports the core calendar views, entries, Gregorian reference, and country-based holiday packs.',
                        'More features such as recurring events, search, notifications, and additional culture systems are planned next.',
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
