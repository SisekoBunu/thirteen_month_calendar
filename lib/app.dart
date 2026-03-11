import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool _checked = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final hide = prefs.getBool('hide_disclaimer') ?? false;

    if (!hide) {
      await Future.delayed(const Duration(milliseconds: 300));
      _showDisclaimer(prefs);
    }

    setState(() {
      _ready = true;
    });
  }

  void _showDisclaimer(SharedPreferences prefs) {
    bool dontShow = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Welcome'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'This app presents an alternative 13-month calendar structure.\n\n'
                    'It does NOT replace the Gregorian calendar. '
                    'Gregorian dates are still shown as the real-world reference.\n\n'
                    'Additional culture systems and calendar features will continue to be added over time.',
                    style: TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: dontShow,
                        onChanged: (v) {
                          setStateDialog(() {
                            dontShow = v ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text('Don’t show again'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Continue'),
                  onPressed: () async {
                    if (dontShow) {
                      await prefs.setBool('hide_disclaimer', true);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return const HomeScreen();
  }
}
