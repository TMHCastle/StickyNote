import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'listener/tray_manager_helper.dart';
import 'listener/save_window_listener.dart';
import 'app.dart';
import 'providers/log_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Hive 初始化
    await Hive.initFlutter();
    await Hive.openBox('logBox');

    // Create the Single Instance of LogProvider
    final logProvider = LogProvider();
    logProvider.loadWindowState(); // 加载上次位置

    // 2. WindowManager 初始化
    await windowManager.ensureInitialized();

    // 设置窗口参数
    WindowOptions windowOptions = WindowOptions(
      size: Size(logProvider.windowWidth, logProvider.windowHeight),
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.hidden,
      alwaysOnTop: true,
      skipTaskbar: false,
      minimumSize: const Size(200, 300),
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setBounds(Rect.fromLTWH(
        logProvider.windowX,
        logProvider.windowY,
        logProvider.windowWidth,
        logProvider.windowHeight,
      ));
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setIgnoreMouseEvents(false); // 默认不穿透

      // 可选：设置窗口位置
      windowManager.addListener(SaveWindowListener(logProvider));
    });

    // 3. 托盘初始化（传入回调）
    await TrayManagerHelper.init(() {
      // On Toggle Lock from Tray
      logProvider.toggleLocked();
    });

    // Initial sync of tray menu
    updateTrayMenu(logProvider.locked);

    // 4. 启动 Flutter App
    runApp(
      ChangeNotifierProvider.value(
        value: logProvider, // Use the existing instance
        child: const MyApp(),
      ),
    );
  } catch (e) {
    // 错误处理
    debugPrint('初始化失败: $e');
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
