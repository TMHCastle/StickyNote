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

  void loadLogs() {
    final stored = box.get('logs', defaultValue: []);
    _logs.clear();
    for (var json in stored) {
      _logs.add(LogEntry.fromJson(Map<String, dynamic>.from(json)));
    }
    notifyListeners();
  }

  void saveLogs() {
    box.put('logs', _logs.map((e) => e.toJson()).toList());
  }

  void addLog(String title,
      {String category = '默认', int? color, int? backgroundColor}) {
    _logs.add(LogEntry(
      id: const Uuid().v4(),
      title: title,
      category: category,
      color: color,
      backgroundColor: backgroundColor,
    ));
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

  final List<String> _categories = ['默认', '工作', '生活', '重要'];
  List<String> get categories => _categories;

  bool _clickThrough = false;
  bool get clickThrough => _clickThrough;

  void setControlOpacity(double value) {
    _controlOpacity = value;
    notifyListeners();
  }

  void setFontSize(double value) {
    _fontSize = value;
    notifyListeners();
  }

  void setBgOpacity(double value) {
    _bgOpacity = value;
    notifyListeners();
  }

  void setLayoutBackgroundColor(int color) {
    _layoutBackgroundColor = color;
    notifyListeners();
  }

  void setBackgroundImage(String? path) {
    _backgroundImage = path;
    notifyListeners();
  }

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  void toggleClickThrough() {
    _clickThrough = !_clickThrough;
    notifyListeners();
  }

  void setClickThrough(bool value) {
    _clickThrough = value;
    notifyListeners();
  }
}
