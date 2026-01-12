import 'package:flutter/material.dart';

import 'pages/floating_overlay.dart';
import 'pages/edit_page.dart';
import 'pages/settings_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Floating Log App',
      initialRoute: '/',
      routes: {
        '/': (context) => FloatingOverlay(),
        '/edit': (context) => EditPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
