import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'services/entry_storage_service.dart';
import 'services/notification_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  await EntryStorageService.initialize();
  await NotificationManager.initialize();

  runApp(const ThirteenMonthCalendarApp());
}
