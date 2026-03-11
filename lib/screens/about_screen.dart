import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                        'About',
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
                      title: 'What this app is',
                      paragraphs: const [
                        '13 Month Calendar is an alternative calendar app built around a fixed 13-month year. Each month has 28 days, the year starts in April, and Sol sits between August and September.',
                        'The app is designed to keep the calendar clean, predictable, and easy to read while still giving you a Gregorian reference so you can relate what you see here to the normal calendar most people use every day.',
                      ],
                    ),
                    _infoCard(
                      title: 'How the calendar works',
                      paragraphs: const [
                        'This calendar uses 13 months with 28 days each, which creates a very regular pattern. That means the months stay neat and balanced instead of shifting around the way they do in the Gregorian calendar.',
                        'To keep the calendar aligned over time, year correction is handled in the background by the app. That means you get the cleaner structure without needing to see extra correction days in the main calendar view.',
                      ],
                    ),
                    _infoCard(
                      title: 'Gregorian reference',
                      paragraphs: const [
                        'Gregorian is the main reference layer currently built into the app. When you select a day, the app can show the Gregorian equivalent date and any linked holidays or observances.',
                        'This makes it easier to use the 13-month structure without losing track of where that day falls in the normal civil calendar.',
                      ],
                    ),
                    _infoCard(
                      title: 'Views and navigation',
                      paragraphs: const [
                        'Month View lets you browse one month at a time. Year View shows the full year at a glance. Day View focuses on one selected day and gives you more room for entries, reminders, alarms, and holiday details.',
                        'The Today button jumps back to the current month and highlights today without forcing the day details panel open.',
                      ],
                    ),
                    _infoCard(
                      title: 'Entries and reminders',
                      paragraphs: const [
                        'You can add events, reminders, and alarms to dates in the calendar. Entries can be viewed from the selected day panel and from Day View.',
                        'As the app grows, more calendar features such as recurring events, search, notifications, and additional cultural calendar systems will be added on top of this core structure.',
                      ],
                    ),
                    _infoCard(
                      title: 'Culture profiles',
                      paragraphs: const [
                        'The culture selector is intended to let the app support different ways of representing the year, along with their own observances, holidays, and calendar logic.',
                        'Gregorian is being completed first so that it can serve as the template for the other profiles that will be added later.',
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
