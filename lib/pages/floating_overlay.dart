import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/log_provider.dart';
import '../widgets/log_item_widget.dart';

class FloatingOverlay extends StatefulWidget {
  const FloatingOverlay({super.key});

  @override
  State<FloatingOverlay> createState() => _FloatingOverlayState();
}

class _FloatingOverlayState extends State<FloatingOverlay> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowFocus() {
    // When window regains focus (e.g. user clicked taskbar icon),
    // we ensure click through is disabled so they can interact.
    // This provides the "Manual Recovery" mechanism.
    final provider = context.read<LogProvider>();
    if (provider.clickThrough) {
      provider.setClickThrough(false);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();
    final logs = provider.logs;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Logic Change:
      // Window Opacity stays 1.0 (Opaque Window) so we can control
      // Text and Background alpha independently via Widgets.
      windowManager.setOpacity(1.0);

      windowManager.setIgnoreMouseEvents(provider.clickThrough, forward: true);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Background Layer (Image + Color)
          // Controllable by bgOpacity and layoutBackgroundColor
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (details) => windowManager.startDragging(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: provider.backgroundImage != null
                      ? DecorationImage(
                          image: FileImage(File(provider.backgroundImage!)),
                          fit: BoxFit.cover,
                          opacity: provider.bgOpacity,
                        )
                      : null,
                  color: provider.backgroundImage == null
                      ? Color(provider.layoutBackgroundColor)
                          .withOpacity(provider.bgOpacity)
                      : Color(provider.layoutBackgroundColor)
                          .withOpacity(provider.bgOpacity * 0.5),
                ),
              ),
            ),
          ),

          // 2. Content Layer
          // Controllable by textOpacity (Entire content opacity)
          Opacity(
            opacity: provider.textOpacity,
            child: Column(
              children: [
                // Header / Lock Button area
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      // Top-Left Lock Button
                      IconButton(
                        icon: Icon(
                          provider.clickThrough ? Icons.lock : Icons.lock_open,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        onPressed: () => provider.toggleClickThrough(),
                        tooltip: "点击锁定。点击任务栏图标解锁。",
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Scrollable Notes List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      ...logs.map((log) => GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/edit');
                            },
                            child: LogItemWidget(log: log),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Edit Button Centered
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/edit'),
                    icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                    label:
                        const Text("编辑", style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),

                // Control Panel (Bottom)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text("底色",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                          Expanded(
                            child: Slider(
                              value: provider.bgOpacity,
                              min: 0.0,
                              max: 1.0,
                              activeColor: Colors.white,
                              inactiveColor: Colors.white24,
                              onChanged: (val) => provider.setBgOpacity(val),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("整体",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                          Expanded(
                            child: Slider(
                              value: provider.textOpacity,
                              min:
                                  0.2, // min opacity to avoid complete invisible
                              max: 1.0,
                              activeColor: Colors.white,
                              inactiveColor: Colors.white24,
                              onChanged: (val) => provider.setTextOpacity(val),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
