import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

/// 当前是否处于“鼠标穿透 / 锁定”状态
///
/// true  : IgnoreMouseEvents 开启（窗口不可交互）
/// false : 正常交互
bool _isLocked = false;

/// 对外暴露的状态监听器（用于 UI 同步锁定状态）
ValueNotifier<bool> lockNotifier = ValueNotifier<bool>(_isLocked);

/// =======================
/// 托盘初始化入口
/// =======================
///
/// tray_manager >= 0.2.1 后：
/// - 不再需要 setup()
/// - setIcon / setContextMenu 可直接调用
/// - Listener 需要手动 addListener
Future<void> initTray() async {
  try {
    final iconPath = await _getIconPath();

    await trayManager.setIcon(iconPath);
    await trayManager.setToolTip('浮动日志工具');

    // 初始菜单
    await _updateMenu();

    // 注册托盘事件监听
    trayManager.addListener(_MyTrayListener());

    // debugPrint('[Tray] 初始化完成');
  } catch (e, stackTrace) {
    debugPrint('[Tray] 初始化失败: $e');
    debugPrint(stackTrace.toString());
    // ⚠️ 托盘失败不应影响主程序运行
  }
}

/// =======================
/// 获取托盘图标路径
/// =======================
///
/// Windows : 仅支持 .ico
/// macOS   : 推荐 png（Template Image 可后续优化）
/// Linux   : png
Future<String> _getIconPath() async {
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

      debugPrint('[Tray] 未找到 .ico 图标，使用默认路径');
      return 'assets/icon_16x16.ico';
    }

    // macOS / Linux
    return 'assets/icon_16x16.png';
  } catch (e) {
    debugPrint('[Tray] 获取图标路径失败: $e');
    return 'assets/icon_16x16.png';
  }
}

/// =======================
/// 动态更新托盘菜单
/// =======================
///
/// ⚠️ tray_manager 的 Menu 是“一次性快照”
/// 状态变化后必须重新 setContextMenu
Future<void> _updateMenu() async {
  try {
    final isVisible = await windowManager.isVisible();
    final isAlwaysOnTop = await windowManager.isAlwaysOnTop();

    final menu = Menu(
      items: [
        MenuItem(
          key: 'toggle_lock',
          label: _isLocked ? '🔒 解锁窗口' : '🔓 锁定窗口',
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
    // debugPrint('[Tray] 菜单已更新');
  } catch (e, stackTrace) {
    debugPrint('[Tray] 更新菜单失败: $e');
    debugPrint(stackTrace.toString());
  }
}

/// =======================
/// 切换鼠标穿透（锁定）
/// =======================
///
/// Windows：
/// setIgnoreMouseEvents + forward=true 才能正确穿透
Future<void> toggleLock() async {
  try {
    _isLocked = !_isLocked;

    await windowManager.setIgnoreMouseEvents(
      _isLocked,
      forward: true,
    );

    lockNotifier.value = _isLocked;

    await _updateMenu();

    // debugPrint('[Tray] 穿透状态: ${_isLocked ? "已锁定" : "已解除"}');
  } catch (e) {
    debugPrint('[Tray] 切换穿透状态失败: $e');
  }
}

/// =======================
/// 显示 / 隐藏窗口
/// =======================
Future<void> _toggleWindowVisibility() async {
  try {
    final visible = await windowManager.isVisible();

    if (visible) {
      await windowManager.hide();
      // debugPrint('[Tray] 窗口已隐藏');
    } else {
      await windowManager.show();
      await windowManager.focus();
      // debugPrint('[Tray] 窗口已显示');
    }
  } catch (e) {
    debugPrint('[Tray] 切换窗口显示失败: $e');
  }
}

/// =======================
/// 切换置顶状态
/// =======================
Future<void> _toggleAlwaysOnTop() async {
  try {
    final isTop = await windowManager.isAlwaysOnTop();
    await windowManager.setAlwaysOnTop(!isTop);
    // debugPrint('[Tray] 置顶状态: ${!isTop}');
  } catch (e) {
    debugPrint('[Tray] 切换置顶失败: $e');
  }
}

/// =======================
/// 托盘事件监听器
/// =======================
class _MyTrayListener with TrayListener {
  bool _menuOpen = false;

  /// 左键点击托盘图标
  /// 约定行为：切换窗口显示
  @override
  void onTrayIconMouseDown() {
    _toggleWindowVisibility();
  }

  /// 右键点击托盘图标
  ///
  /// tray_manager 在 Windows 上：
  /// popUpContextMenu() 会自动处理显示 / 关闭
  @override
  Future<void> onTrayIconRightMouseDown() async {
    await _updateMenu();
    await trayManager.popUpContextMenu();
    _menuOpen = !_menuOpen;
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    _menuOpen = false;

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
          await trayManager.destroy();
          exit(0);
      }
    } catch (e, stackTrace) {
      debugPrint('[Tray] 菜单处理失败: $e');
      debugPrint(stackTrace.toString());
    }
  }
}
