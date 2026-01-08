import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class FloatingControlButton extends StatefulWidget {
  const FloatingControlButton({super.key});

  @override
  State<FloatingControlButton> createState() => _FloatingControlButtonState();
}

class _FloatingControlButtonState extends State<FloatingControlButton> {
  bool clickThrough = false;
  double opacity = 0.5;

  void toggleClickThrough() async {
    clickThrough = !clickThrough;
    await windowManager.setIgnoreMouseEvents(clickThrough, forward: true);
    setState(() {});
  }

  void changeOpacity(double value) async {
    opacity = value;
    await windowManager.setOpacity(opacity);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: "toggle",
          mini: true,
          child: Icon(clickThrough ? Icons.lock_open : Icons.lock),
          onPressed: toggleClickThrough,
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "edit",
          mini: true,
          child: const Icon(Icons.edit),
          onPressed: () => Navigator.pushNamed(context, '/edit'),
        ),
        const SizedBox(height: 8),
        Slider(
          value: opacity,
          min: 0.2,
          max: 1.0,
          onChanged: changeOpacity,
        )
      ],
    );
  }
}
