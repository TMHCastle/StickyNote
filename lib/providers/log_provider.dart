import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
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

  void setControlOpacity(double v) {
    _controlOpacity = v;
    notifyListeners();
  }

  void setFontSize(double v) {
    _fontSize = v;
    notifyListeners();
  }

  void setBgOpacity(double v) {
    _bgOpacity = v;
    notifyListeners();
  }

  void setLayoutBackgroundColor(int v) {
    _layoutBackgroundColor = v;
    notifyListeners();
  }

  void setBackgroundImage(String? path) {
    _backgroundImage = path;
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

  void toggleLocked() {
    _locked = !_locked;
    notifyListeners();
  }
}
