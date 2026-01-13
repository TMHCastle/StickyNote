import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/log_provider.dart';
import '../widgets/log_item_widget.dart';

class FloatingOverlay extends StatelessWidget {
  const FloatingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ===== 背景层（始终可拖动）=====
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (_) => windowManager.startDragging(),
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
                  color: Color(provider.layoutBackgroundColor)
                      .withOpacity(provider.bgOpacity),
                ),
              ),
            ),
          ),

          // ===== 主内容层（锁定时禁用）=====
          IgnorePointer(
            ignoring: provider.locked,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings, size: 20),
                        color: Colors.white.withOpacity(0.8),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: provider.logs
                        .map((log) => LogItemWidget(log: log))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit');
                  },
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                  label: const Text(
                    '编辑',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ===== 锁定按钮（永远可点）=====
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: provider.toggleLocked,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  provider.locked ? Icons.lock : Icons.lock_open,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
