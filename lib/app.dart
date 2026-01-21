import 'package:flutter/material.dart';
import 'pages/floating_overlay.dart';
import 'pages/edit_page.dart';
// import 'pages/settings_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'SourceHanSans',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const FloatingOverlay(),
        '/edit': (_) => const EditPage(),
        // '/settings': (_) => const SettingsPage(), // removed
      },
    );
  }
}
