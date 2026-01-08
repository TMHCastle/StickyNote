import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/log_provider.dart';
import '../widgets/log_item_widget.dart';
import '../widgets/floating_control_button.dart';

class FloatingOverlay extends StatefulWidget {
  const FloatingOverlay({super.key});

  @override
  State<FloatingOverlay> createState() => _FloatingOverlayState();
}

class _FloatingOverlayState extends State<FloatingOverlay> {
  double opacity = 0.5;
  bool clickThrough = false;

  void toggleClickThrough() async {
    clickThrough = !clickThrough;
    await windowManager.setIgnoreMouseEvents(clickThrough, forward: true);
    setState(() {});
  }

  void setOpacity(double value) async {
    opacity = value;
    await windowManager.setOpacity(opacity);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<LogProvider>().logs;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(opacity),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return LogItemWidget(log: logs[index]);
              },
            ),
          ),
          const Positioned(
            bottom: 16,
            right: 16,
            child: FloatingControlButton(),
          )
        ],
      ),
    );
  }
}
