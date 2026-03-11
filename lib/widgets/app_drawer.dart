import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../screens/how_it_works_screen.dart';
import '../screens/donate_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onRateTap;
  final VoidCallback onShareTap;

  const AppDrawer({
    super.key,
    required this.onRateTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '13 Month Calendar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text(
                      'About this app',
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: const Text(
                      'What the app is and why it exists',
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: const Text(
                      'How the app works',
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: const Text(
                      'Views, entries, dates, and navigation',
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HowItWorksScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: const Text(
                      'Rate this app',
                      style: TextStyle(fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onRateTap();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text(
                      'Share the app with a friend',
                      style: TextStyle(fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onShareTap();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.volunteer_activism_outlined),
                    title: const Text(
                      'Donate',
                      style: TextStyle(fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DonateScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
