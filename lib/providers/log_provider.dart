import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';
import '../models/log_entry.dart';

class LogProvider extends ChangeNotifier {
  final Box box = Hive.box('logBox');

  final List<LogEntry> _logs = [];
  List<LogEntry> get logs => _logs;

  LogProvider() {
    loadLogs();
  }

  // ================= 日志 =================

  void loadLogs() {
    final stored = box.get('logs', defaultValue: []);
    _logs
      ..clear()
      ..addAll(
        stored.map<LogEntry>(
          (e) => LogEntry.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    notifyListeners();
  }

  void saveLogs() {
    box.put('logs', _logs.map((e) => e.toJson()).toList());
  }

  void addLog(
    String title, {
    String category = '默认',
    int? color,
    int? backgroundColor,
  }) {
    _logs.add(
      LogEntry(
        id: const Uuid().v4(),
        title: title,
        category: category,
        color: color,
        backgroundColor: backgroundColor,
      ),
    );
    saveLogs();
    notifyListeners();
  }

  void updateLog(LogEntry log) {
    final index = _logs.indexWhere((e) => e.id == log.id);
    if (index != -1) {
      _logs[index] = log;
      saveLogs();
      notifyListeners();
    }
  }

  void removeLog(String id) {
    _logs.removeWhere((e) => e.id == id);
    saveLogs();
    notifyListeners();
  }

  // ================= 外观设置 =================

  double _controlOpacity = 1.0;
  double get controlOpacity => _controlOpacity;

  double _fontSize = 14.0;
  double get fontSize => _fontSize;

  double _bgOpacity = 0.5;
  double get bgOpacity => _bgOpacity;

  int _layoutBackgroundColor = Colors.black.value;
  int get layoutBackgroundColor => _layoutBackgroundColor;

  String? _backgroundImage;
  String? get backgroundImage => _backgroundImage;

  // 圆角角度
  double _borderRadius = 12.0;
  double get borderRadius => _borderRadius;

// 是否使用背景图片
  bool _useBackgroundImage = true;
  bool get useBackgroundImage => _useBackgroundImage;

// 便签整体背景颜色（独立于单条便签）
  int _noteBackgroundColor = Colors.black54.value;
  int get noteBackgroundColor => _noteBackgroundColor;

  void setControlOpacity(double v) {
    _controlOpacity = v;
    notifyListeners();
  }

  void setFontSize(double v) {
    _fontSize = v;
    notifyListeners();
  }

  void setBgOpacity(double v) {
    _bgOpacity = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setLayoutBackgroundColor(int v) {
    _layoutBackgroundColor = v;
    notifyListeners();
  }

  void setBackgroundImage(String? path) {
    _backgroundImage = path;
    _useBackgroundImage = path != null;
    notifyListeners();
  }

  void removeBackgroundImage() {
    _backgroundImage = null;
    _useBackgroundImage = false;
    notifyListeners();
  }

  void setBorderRadius(double v) {
    _borderRadius = v;
    notifyListeners();
  }

  void setUseBackgroundImage(bool v) {
    _useBackgroundImage = v;
    notifyListeners();
  }

  void setNoteBackgroundColor(int v) {
    _noteBackgroundColor = v;
    notifyListeners();
  }

  double _noteBgOpacity = 0.5; // 0~1
  double get noteBgOpacity => _noteBgOpacity;
  void setNoteBgOpacity(double v) {
    _noteBgOpacity = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  int _noteBgColor = Colors.black.value;
  int get noteBgColor => _noteBgColor;
  void setNoteBgColor(int v) {
    _noteBgColor = v;
    notifyListeners();
  }

  // ================= 分类 =================

  final List<String> _categories = ['默认', '工作', '生活', '重要'];
  List<String> get categories => _categories;

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  // ================= 锁定状态（方案 A 核心） =================

  bool _locked = false;

  bool get locked => _locked;

  /// 托盘主控：修改锁定状态，并通知 UI
  Future<void> setLocked(bool value) async {
    _locked = value;
    await windowManager.setIgnoreMouseEvents(_locked, forward: true);
    notifyListeners();
  }

  /// 切换锁定状态（可选，用于 FloatingOverlay）
  Future<void> toggleLocked() async {
    await setLocked(!_locked);
  }
}
