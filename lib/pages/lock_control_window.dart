import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class LockControlWindow extends StatefulWidget {
  const LockControlWindow({super.key});

  @override
  State<LockControlWindow> createState() => _LockControlWindowState();
}

class _LockControlWindowState extends State<LockControlWindow> {
  bool locked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: GestureDetector(
          onTap: () async {
            locked = !locked;

            // 控制主窗口（ID 0）
            final mainWindow = WindowManager.instance;
            await mainWindow.setIgnoreMouseEvents(
              locked,
              forward: true,
            );

            setState(() {});
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              shape: BoxShape.circle,
            ),
            child: Icon(
              locked ? Icons.lock : Icons.lock_open,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
