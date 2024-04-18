import 'package:flutter/material.dart';
import 'package:gv_swim/pages/CreatorInfoPage.dart';
import 'package:gv_swim/pages/gvswim.dart';

void main() {
  runApp(ThemeSwitchingApp());
}

class ThemeSwitchingApp extends StatefulWidget {
  @override
  _ThemeSwitchingAppState createState() => _ThemeSwitchingAppState();
}

class _ThemeSwitchingAppState extends State<ThemeSwitchingApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              textTheme: ThemeData.dark().textTheme.apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
            )
          : ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => GvswimWidget(
              isDarkMode: _isDarkMode,
              toggleTheme: toggleTheme,
            ),
        '/creatorInfo': (context) => CreatorInfoPage(),
      },
    );
  }
}
