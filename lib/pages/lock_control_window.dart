import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';

/// 单窗口锁定穿透控制按钮
/// 注意：不再使用 DesktopMultiWindow
class LockControlWindow extends StatelessWidget {
  const LockControlWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: GestureDetector(
          onTap: () async {
            // 切换锁定穿透状态
            await windowManager.setIgnoreMouseEvents(
              !provider.locked,
              forward: true,
            );
            provider.toggleLocked();
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              shape: BoxShape.circle,
            ),
            child: Icon(
              provider.locked ? Icons.lock : Icons.lock_open,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
