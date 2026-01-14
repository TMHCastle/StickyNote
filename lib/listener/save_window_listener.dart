import 'dart:ui';

import 'package:window_manager/window_manager.dart';
import '../providers/log_provider.dart';

/// 监听窗口移动/缩放，实时保存位置和大小
class SaveWindowListener extends WindowListener {
  final LogProvider provider;

  SaveWindowListener(this.provider);

  @override
  void onWindowMove() async {
    Rect bounds = await windowManager.getBounds();
    provider.setWindowPosition(bounds.left, bounds.top);
  }

  @override
  void onWindowResize() async {
    Rect bounds = await windowManager.getBounds();
    provider.setWindowSize(bounds.width, bounds.height);
  }
}
