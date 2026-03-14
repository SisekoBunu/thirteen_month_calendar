import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class MultiCalApp extends StatelessWidget {
  const MultiCalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiCul Calendar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3EEF3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF3EEF3),
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
