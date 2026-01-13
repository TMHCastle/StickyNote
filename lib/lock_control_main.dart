import 'package:flutter/material.dart';
import 'pages/lock_control_window.dart';

void lockControlMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LockControlWindow(),
  ));
}
