import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/calendar_manager.dart';
import '../models/calendar_type.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<CalendarManager>();

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Choose Calendar",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ...manager.availableCalendars.map((CalendarType type) {
            final engine = manager.getEngine(type);

            return ListTile(
              title: Text(engine.displayName),
              selected: manager.activeType == type,
              onTap: () {
                manager.setActiveCalendar(type);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
