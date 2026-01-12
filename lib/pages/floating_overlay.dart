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
          Column(
            children: [
              // Header Row (Control Opacity Applied)
              Opacity(
                opacity: provider.controlOpacity,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      // Lock Button
                      IconButton(
                        icon: Icon(
                          provider.clickThrough ? Icons.lock : Icons.lock_open,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        // Only "Locking" can be done here. Unlocking is via Taskbar.
                        onPressed: () {
                          if (!provider.clickThrough) {
                            provider.toggleClickThrough();
                          }
                        },
                        tooltip: provider.clickThrough
                            ? "当前已锁定(穿透)。点击底部任务栏图标解锁。"
                            : "点击锁定(开启穿透)",
                      ),
                      const Spacer(),
                      // Settings Button
                      IconButton(
                        icon: Icon(Icons.settings,
                            color: Colors.white.withOpacity(0.8), size: 20),
                        onPressed: () {
                          if (!provider.clickThrough) {
                            Navigator.pushNamed(context, '/settings');
                          }
                        },
                        tooltip: "设置",
                      ),
                    ],
                  ),
                ),
              ),

              // Scrollable Notes List (NO Opacity Applied - Always Visible)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    ...logs.map((log) => GestureDetector(
                          onTap: () {
                            if (!provider.clickThrough) {
                              Navigator.pushNamed(context, '/edit');
                            }
                          },
                          child: LogItemWidget(log: log),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Edit Button Centered (Control Opacity Applied)
              Opacity(
                opacity: provider.controlOpacity,
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      if (!provider.clickThrough) {
                        Navigator.pushNamed(context, '/edit');
                      }
                    },
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
              ),
              const SizedBox(height: 8),
              // Removed Bottom Control Panel
            ],
          ),
        ],
      ),
    );
  }
}
