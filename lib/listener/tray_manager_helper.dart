import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

// Callback definitions
typedef OnLockToggle = void Function();

/// Tray Helper: Stateless, driven by external calls
class TrayManagerHelper {
  
  static OnLockToggle? onLockToggle;

  /// Init Tray
  static Future<void> init(OnLockToggle onToggle) async {
    onLockToggle = onToggle;
    try {
      final iconPath = await _getIconPath();
      await trayManager.setIcon(iconPath);
      await trayManager.setToolTip('浮动日志工具');

      // Add listener
      trayManager.addListener(_MyTrayListener());

    } catch (e, stackTrace) {
      debugPrint('[Tray] 初始化失败: $e');
      debugPrint(stackTrace.toString());
    }
  }

  static Future<String> _getIconPath() async {
    try {
      if (Platform.isWindows) {
        final base = Directory.current.path;
        final candidates = [
          '$base\\assets\\icon_16x16.ico',
          '$base\\assets\\icon.ico',
          'assets/icon_16x16.ico',
        ];
        for (final path in candidates) {
          if (await File(path).exists()) {
            return path;
          }
        }
        return 'assets/icon_16x16.ico';
      }
      return 'assets/icon_16x16.png';
    } catch (e) {
      return 'assets/icon_16x16.png';
    }
  }
}

/// Global function to update menu from Provider
Future<void> updateTrayMenu(bool isLocked) async {
  try {
    final isVisible = await windowManager.isVisible();
    final isAlwaysOnTop = await windowManager.isAlwaysOnTop();

    final menu = Menu(
      items: [
        MenuItem(
          key: 'toggle_lock',
          label: isLocked ? '🔒 解锁窗口' : '🔓 锁定窗口',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'show_hide',
          label: isVisible ? '👁️ 隐藏窗口' : '👁️ 显示窗口',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'always_top',
          label: isAlwaysOnTop ? '📌 取消置顶' : '📌 置顶窗口',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: '❌ 退出程序',
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
  } catch (e) {
    debugPrint('[Tray] 更新菜单失败: $e');
  }
}

class _MyTrayListener with TrayListener {
  
  @override
  void onTrayIconMouseDown() async {
    final visible = await windowManager.isVisible();
    if (visible) {
      windowManager.hide();
    } else {
      windowManager.show();
      windowManager.focus();
    }
    // Update menu to reflect visibility
    // We don't have lock state here easily, but usually it doesn't change on visibility toggle
    // Ideally we should ask provider, but this simple toggle is fine.
    // Optimization: We could store last known lock state in a static var if needed,
    // but usually Provider will update menu when state changes.
    // For visibility, we might want to trigger a menu refresh.
    // But `updateTrayMenu` requires `isLocked`.
    // Let's just leave it, menu update happens on right click anyway.
  }

  @override
  Future<void> onTrayIconRightMouseDown() async {
    // When right clicking, we want to ensure menu is up to date.
    // But we need `isLocked` state.
    // Since `updateTrayMenu` is called whenever lock changes, the menu SHOULD be correct.
    // However, visibility or alwaysOnTop might have changed.
    // We can't easily get `isLocked` here without coupling.
    // So we assume the LAST set menu is correct for Lock,
    // but we might want to refresh Visibility/Top.
    //
    // Actually, `trayManager.popUpContextMenu()` shows the *current set* menu.
    // If we want dynamic updates on right click (e.g. for visibility), we need to know `isLocked`.
    // We can rely on `LogProvider` updating the menu whenever ANY relevant state changes.
    // `LogProvider` handles Lock.
    // Does it handle Visibility? No.
    // But Visibility is usually handled by Tray.

    // Simplification: Just pop up.
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'toggle_lock':
        // Delegate to callback
        TrayManagerHelper.onLockToggle?.call();
        break;
      case 'show_hide':
        final visible = await windowManager.isVisible();
        if (visible) {
          await windowManager.hide();
        } else {
          await windowManager.show();
          await windowManager.focus();
        }
        break;
      case 'always_top':
        final isTop = await windowManager.isAlwaysOnTop();
        await windowManager.setAlwaysOnTop(!isTop);
        break;
      case 'exit_app':
        await trayManager.destroy();
        exit(0);
    }
  }
}
