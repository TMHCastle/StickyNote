import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'tray_manager_helper.dart';
import 'app.dart';
import 'providers/log_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Hive 初始化
    await Hive.initFlutter();
    await Hive.openBox('logBox');

    // 2. WindowManager 初始化
    await windowManager.ensureInitialized();

    // 设置窗口参数
    WindowOptions windowOptions = const WindowOptions(
      size: Size(300, 500),
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.hidden,
      alwaysOnTop: true,
      skipTaskbar: false, // 确保窗口不在任务栏显示
      minimumSize: Size(200, 300),
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setIgnoreMouseEvents(false); // 默认不穿透

      // 可选：设置窗口位置
      await windowManager.setPosition(Offset.zero);
    });

    // 3. 托盘初始化（放在最后，确保窗口已准备好）
    await initTray();

    // 4. 启动 Flutter App
    runApp(
      ChangeNotifierProvider(
        create: (context) => LogProvider(),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    // 错误处理
    debugPrint('初始化失败: $e');
    // 可以显示错误对话框或退回到基本功能
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('应用初始化失败: $e'),
          ),
        ),
      ),
    );
  }
}
