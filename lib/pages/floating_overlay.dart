import 'dart:io';
import 'package:floating_log_app/pages/edit_page.dart';
import 'package:floating_log_app/pages/settings_page.dart';
import 'package:floating_log_app/routes/no_animation_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/log_provider.dart';
import '../widgets/log_item_widget.dart';
import '../listener/tray_manager_helper.dart';
import '../utils/app_strings.dart';

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
            child: Listener(
              onPointerDown: (_) => windowManager.startDragging(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(provider.borderRadius),
                  image: provider.useBackgroundImage &&
                          provider.backgroundImage != null
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

          // ===== 主内容层（便签列表）=====
          Positioned.fill(
            top: 52,
            child: IgnorePointer(
              ignoring: provider.locked,
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                buildDefaultDragHandles: false,
                onReorder: provider.reorderLogs,
                itemCount: provider.logs.length,
                itemBuilder: (context, index) {
                  final log = provider.logs[index];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(log.id), // 必须
                    index: index,
                    child: LogItemWidget(
                      log: log,
                      noteOpacity: provider.noteBgOpacity,
                      fontSize: provider.fontSize,
                    ),
                  );
                },
              ),
            ),
          ),

          // ===== 编辑按钮（始终可点击）=====
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    NoAnimationRoute(page: const EditPage()),
                  );
                },
                icon: Icon(Icons.edit,
                    size: 16,
                    color: Colors.white.withOpacity(provider.controlOpacity)),
                label: Text(
                  AppStrings.of(context, 'edit'),
                  style: TextStyle(
                      color: Colors.white.withOpacity(provider.controlOpacity)),
                ),
                style: TextButton.styleFrom(
                  backgroundColor:
                      Colors.white.withOpacity(0.2 * provider.controlOpacity),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),

          // ===== 顶部锁定按钮（永远可点击，支持拖动窗口）=====
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onPanStart: (_) => windowManager.startDragging(),
              child: ValueListenableBuilder<bool>(
                valueListenable: lockNotifier,
                builder: (context, locked, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async => await toggleLock(),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withOpacity(0.6 * provider.controlOpacity),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            locked ? Icons.lock : Icons.lock_open,
                            size: 16,
                            color: Colors.white
                                .withOpacity(provider.controlOpacity),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          child: Align(
                            alignment: Alignment.centerLeft, // 左对齐
                            child: Stack(
                              children: [
                                // 描边层
                                Text(
                                  locked
                                      ? AppStrings.of(context, 'unlockInTray')
                                      : AppStrings.of(context, 'clickToLock'),
                                  key: ValueKey(
                                      'stroke-$locked'), // 避免与填充层 key 冲突
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 2
                                      ..color = Colors.black.withOpacity(
                                          provider.controlOpacity), // 描边颜色，可改
                                  ),
                                ),
                                // 填充层
                                Text(
                                  locked
                                      ? AppStrings.of(context, 'unlockInTray')
                                      : AppStrings.of(context, 'clickToLock'),
                                  key: ValueKey('fill-$locked'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white
                                        .withOpacity(provider.controlOpacity),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ===== 右上角设置按钮（始终可点击）=====
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.settings, size: 20),
              color: Colors.white.withOpacity(provider.controlOpacity),
              onPressed: () {
                Navigator.of(context).push(
                  NoAnimationRoute(page: const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
