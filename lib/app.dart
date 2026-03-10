import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class ThirteenMonthCalendarApp extends StatelessWidget {
  const ThirteenMonthCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '13 Month Calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
      ),
      home: const HomeScreen(),
    );
  }
}
