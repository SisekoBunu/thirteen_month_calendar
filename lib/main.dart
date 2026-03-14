import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/calendar_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final calendarManager = await CalendarManager.create();

  runApp(
    ChangeNotifierProvider<CalendarManager>.value(
      value: calendarManager,
      child: const MultiCalApp(),
    ),
  );
}
