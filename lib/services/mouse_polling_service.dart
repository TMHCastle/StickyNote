import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class MousePollingService {
  Timer? _timer;
  bool _isHovering = false;
  final Function(bool) onHoverChanged;
  final Rect Function() getHotArea;

  MousePollingService({
    required this.onHoverChanged,
    required this.getHotArea,
  });

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      await _checkMouse();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkMouse() async {
    try {
      // 1. 获取鼠标在屏幕上的全局坐标
      final mousePos = await screenRetriever.getCursorScreenPoint();
      
      // 2. 获取窗口在屏幕上的位置
      final windowPos = await windowManager.getPosition();
      final windowSize = await windowManager.getSize();
      
      // 3. 将鼠标坐标转换为相对于窗口的坐标
      final relativeX = mousePos.dx - windowPos.dx;
      final relativeY = mousePos.dy - windowPos.dy;
      
      // 4. 判断是否在窗口内 (简单性能优化)
      if (relativeX < 0 || relativeX > windowSize.width ||
          relativeY < 0 || relativeY > windowSize.height) {
        if (_isHovering) {
          _isHovering = false;
          onHoverChanged(false);
        }
        return;
      }

      // 5. 获取热区 (Lock Button 区域)
      final hotRect = getHotArea();

      // 6. 碰撞检测
      final isNowHovering = hotRect.contains(Offset(relativeX, relativeY));

      if (_isHovering != isNowHovering) {
        _isHovering = isNowHovering;
        onHoverChanged(_isHovering);
      }
    } catch (e) {
      debugPrint('MousePollingService error: $e');
    }
  }
}
