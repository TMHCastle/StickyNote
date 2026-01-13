// tray_manager_helper.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

bool _isLocked = false;

ValueNotifier<bool> lockNotifier = ValueNotifier(_isLocked);

/// 初始化托盘
Future<void> initTray() async {
  try {
    // 1. 设置托盘图标（不再需要 setup 方法）
    final iconPath = await _getIconPath();

    // 对于 tray_manager 0.2.1+ 版本，直接设置图标和菜单
    await trayManager.setIcon(iconPath);
    await trayManager.setToolTip('浮动日志工具');

    // 2. 创建并设置菜单
    await _updateMenu();

    // 3. 添加事件监听器
    final listener = _MyTrayListener();
    trayManager.addListener(listener);

    debugPrint('托盘初始化完成');
  } catch (e, stackTrace) {
    debugPrint('托盘初始化失败: $e');
    debugPrint('堆栈: $stackTrace');
    // 即使托盘失败，也允许应用继续运行
  }
}

/// 获取图标路径（跨平台兼容）
Future<String> _getIconPath() async {
  try {
    if (Platform.isWindows) {
      // Windows: 需要 .ico 格式
      final currentDir = Directory.current.path;
      final paths = [
        "$currentDir\\assets\\icon_16x16.ico",
        "$currentDir\\assets\\icon.ico",
        "assets/icon.ico",
      ];

      for (final path in paths) {
        final file = File(path);
        if (await file.exists()) {
          debugPrint('找到图标文件: $path');
          return path;
        }
      }

      // 如果没有找到图标，尝试使用相对路径
      debugPrint('警告：未找到托盘图标文件，尝试使用默认路径');
      return "assets/icon.ico";
    } else if (Platform.isMacOS || Platform.isLinux) {
      // macOS/Linux: 使用 PNG
      return "assets/icon.png";
    }

    return "assets/icon.png";
  } catch (e) {
    debugPrint('获取图标路径失败: $e');
    return "assets/icon.png";
  }
}

/// 更新菜单
Future<void> _updateMenu() async {
  try {
    // 动态获取当前状态
    final isVisible = await windowManager.isVisible();
    final isAlwaysOnTop = await windowManager.isAlwaysOnTop();

    final menu = Menu(
      items: [
        // 锁定/解锁
        MenuItem(
          key: 'toggle_lock',
          label: _isLocked ? '🔒 解锁' : '🔓 锁定',
        ),
        MenuItem.separator(),

        // 显示/隐藏窗口
        MenuItem(
          key: 'show_hide',
          label: isVisible ? '👁️ 隐藏窗口' : '👁️ 显示窗口',
        ),
        MenuItem.separator(),

        // 置顶/取消置顶
        MenuItem(
          key: 'always_top',
          label: isAlwaysOnTop ? '📌 取消置顶' : '📌 置顶',
        ),
        MenuItem.separator(),

        // 退出程序
        MenuItem(
          key: 'exit_app',
          label: '❌ 退出程序',
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
    debugPrint('菜单更新完成');
  } catch (e, stackTrace) {
    debugPrint('更新菜单失败: $e');
    debugPrint('堆栈: $stackTrace');
  }
}

/// 切换穿透状态
Future<void> toggleLock() async {
  try {
    _isLocked = !_isLocked;
    await windowManager.setIgnoreMouseEvents(_isLocked, forward: true);
    await _updateMenu();
    lockNotifier.value = _isLocked;
    debugPrint('穿透状态: ${_isLocked ? "已锁定" : "已解除"}');
  } catch (e) {
    debugPrint('切换穿透状态失败: $e');
  }
}

/// 显示/隐藏窗口
Future<void> _toggleWindowVisibility() async {
  try {
    final isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
      debugPrint('窗口已隐藏');
    } else {
      await windowManager.show();
      await windowManager.focus();
      debugPrint('窗口已显示');
    }
  } catch (e) {
    debugPrint('切换窗口显示失败: $e');
  }
}

/// 切换置顶状态
Future<void> _toggleAlwaysOnTop() async {
  try {
    final isAlwaysOnTop = await windowManager.isAlwaysOnTop();
    await windowManager.setAlwaysOnTop(!isAlwaysOnTop);
    debugPrint('置顶状态: ${!isAlwaysOnTop}');
  } catch (e) {
    debugPrint('切换置顶状态失败: $e');
  }
}

/// 托盘事件监听器
class _MyTrayListener with TrayListener {
  bool _isMenuOpen = false;

  @override
  void onTrayIconMouseDown() {
    debugPrint('托盘图标左键点击');
    // 左键点击：切换窗口显示/隐藏
    _toggleWindowVisibility();
  }

  @override
  @override
  Future<void> onTrayIconRightMouseDown() async {
    debugPrint("托盘图标右键按下");

    // 更新菜单文字
    await _updateMenu();

    if (_isMenuOpen) {
      // 菜单已经打开 → 关闭
      await trayManager.popUpContextMenu(); // popUpContextMenu 在菜单已打开时会关闭
      _isMenuOpen = false;
      debugPrint("托盘菜单关闭");
    } else {
      // 菜单未打开 → 打开
      await trayManager.popUpContextMenu();
      _isMenuOpen = true;
      debugPrint("托盘菜单打开");
    }
  }

  @override
  void onTrayIconRightMouseUp() {
    debugPrint("托盘图标右键释放");
  }

  void onTrayIconMouseEnter() {
    debugPrint("鼠标进入托盘图标区域");
  }

  void onTrayIconMouseLeave() {
    debugPrint("鼠标离开托盘图标区域");
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    _isMenuOpen = false; // 点击菜单后，认为菜单关闭
    debugPrint("托盘菜单点击: ${menuItem.key} - ${menuItem.label}");

    try {
      switch (menuItem.key) {
        case 'toggle_lock':
          await toggleLock();
          break;
        case 'show_hide':
          await _toggleWindowVisibility();
          break;
        case 'always_top':
          await _toggleAlwaysOnTop();
          break;
        case 'exit_app':
          debugPrint('退出应用');
          // 先隐藏托盘，再退出
          await trayManager.destroy();
          exit(0);
          // ignore: dead_code
          break;
        default:
          debugPrint('未知菜单项: ${menuItem.key}');
      }
    } catch (e, stackTrace) {
      debugPrint('处理菜单点击失败: $e');
      debugPrint('堆栈: $stackTrace');
    }
  }
}
