import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';
import '../models/log_entry.dart';
import '../models/category_model.dart';

class LogProvider extends ChangeNotifier {
  final Box box = Hive.box('logBox');

  final List<LogEntry> _logs = [];
  // List<LogEntry> get logs => _logs; // Replaced by sorted getter below

  LogProvider() {
    _loadAll();
  }

  // ================= 日志 =================
  void _loadAll() {
    // 日志
    final stored = box.get('logs', defaultValue: []);
    _logs
      ..clear()
      ..addAll(
        stored.map<LogEntry>(
            (e) => LogEntry.fromJson(Map<String, dynamic>.from(e))),
      );

    // 外观设置
    _controlOpacity = box.get('controlOpacity', defaultValue: 1.0);
    _fontSize = box.get('fontSize', defaultValue: 14.0);
    _bgOpacity = box.get('bgOpacity', defaultValue: 0.5);
    _layoutBackgroundColor =
        box.get('layoutBackgroundColor', defaultValue: Colors.black.value);
    _backgroundImage = box.get('backgroundImage');
    _useBackgroundImage =
        box.get('useBackgroundImage', defaultValue: _backgroundImage != null);
    _borderRadius = box.get('borderRadius', defaultValue: 12.0);
    _noteBgOpacity = box.get('noteBgOpacity', defaultValue: 0.5);
    _noteBgColor = box.get('noteBgColor', defaultValue: Colors.black.value);
    
    // 语言设置
    _locale = box.get('locale', defaultValue: 'zh');
    
    // 排序设置
    _sortAscending = box.get('sortAscending', defaultValue: false);

    // 加载分类
    _loadCategories();

    notifyListeners();
  }

  void saveLogs() {
    box.put('logs', _logs.map((e) => e.toJson()).toList());
  }

  void addLog(String title,
      {String category = '默认', int? color, int? backgroundColor}) {
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
  void setControlOpacity(double v) {
    _controlOpacity = v;
    box.put('controlOpacity', v);
    notifyListeners();
  }

  double _fontSize = 14.0;
  double get fontSize => _fontSize;
  void setFontSize(double v) {
    _fontSize = v;
    box.put('fontSize', v);
    notifyListeners();
  }

  double _bgOpacity = 0.5;
  double get bgOpacity => _bgOpacity;
  void setBgOpacity(double v) {
    _bgOpacity = v.clamp(0.0, 1.0);
    box.put('bgOpacity', _bgOpacity);
    notifyListeners();
  }

  int _layoutBackgroundColor = Colors.black.value;
  int get layoutBackgroundColor => _layoutBackgroundColor;
  void setLayoutBackgroundColor(int v) {
    _layoutBackgroundColor = v;
    box.put('layoutBackgroundColor', v);
    notifyListeners();
  }

  String? _backgroundImage;
  String? get backgroundImage => _backgroundImage;
  void setBackgroundImage(String? path) {
    _backgroundImage = path;
    box.put('backgroundImage', path);
    _useBackgroundImage = path != null;
    box.put('useBackgroundImage', _useBackgroundImage);
    notifyListeners();
  }

  void removeBackgroundImage() {
    _backgroundImage = null;
    _useBackgroundImage = false;
    box.delete('backgroundImage');
    box.put('useBackgroundImage', false);
    notifyListeners();
  }

  bool _useBackgroundImage = true;
  bool get useBackgroundImage => _useBackgroundImage;
  void setUseBackgroundImage(bool v) {
    _useBackgroundImage = v;
    box.put('useBackgroundImage', v);
    notifyListeners();
  }

  double _borderRadius = 0;
  double get borderRadius => _borderRadius;
  void setBorderRadius(double v) {
    _borderRadius = v;
    box.put('borderRadius', v);
    notifyListeners();
  }

  double _noteBgOpacity = 0.5;
  double get noteBgOpacity => _noteBgOpacity;
  void setNoteBgOpacity(double v) {
    _noteBgOpacity = v.clamp(0.0, 1.0);
    box.put('noteBgOpacity', _noteBgOpacity);
    notifyListeners();
  }

  int _noteBgColor = Colors.black.value;
  int get noteBgColor => _noteBgColor;
  void setNoteBgColor(int v) {
    _noteBgColor = v;
    box.put('noteBgColor', v);
    notifyListeners();
  }

  // ================= 窗口状态 =================
  double _windowX = 100;
  double _windowY = 100;
  double _windowWidth = 400;
  double _windowHeight = 600;

  double get windowX => _windowX;
  double get windowY => _windowY;
  double get windowWidth => _windowWidth;
  double get windowHeight => _windowHeight;

  void setWindowPosition(double x, double y) {
    _windowX = x;
    _windowY = y;
    saveWindowState();
  }

  void setWindowSize(double width, double height) {
    _windowWidth = width;
    _windowHeight = height;
    saveWindowState();
  }

  void saveWindowState() {
    box.put('windowX', _windowX);
    box.put('windowY', _windowY);
    box.put('windowWidth', _windowWidth);
    box.put('windowHeight', _windowHeight);
  }

  void loadWindowState() {
    _windowX = box.get('windowX', defaultValue: 100.0);
    _windowY = box.get('windowY', defaultValue: 100.0);
    _windowWidth = box.get('windowWidth', defaultValue: 400.0);
    _windowHeight = box.get('windowHeight', defaultValue: 600.0);
  }

  /// 日志拖动排序（ReorderableListView 使用）
  void reorderLogs(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _logs.length) return;
    if (newIndex < 0 || newIndex > _logs.length) return;

    // Flutter 官方推荐写法
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = _logs.removeAt(oldIndex);
    _logs.insert(newIndex, item);

    // 🔒 立刻持久化顺序
    saveLogs();

    notifyListeners();
  }

  // ================= 分类 =================
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  void _initCategories() {
    // 默认分类
    if (_categories.isEmpty) {
      _categories = [
        CategoryModel(name: '默认', colorValue: Colors.grey.value),
        CategoryModel(name: '工作', colorValue: Colors.blue.value),
        CategoryModel(name: '生活', colorValue: Colors.green.value),
        CategoryModel(name: '重要', colorValue: Colors.red.value),
      ];
    }
  }

  void addCategory(String name, int colorValue) {
    if (!_categories.any((c) => c.name == name)) {
      _categories.add(CategoryModel(name: name, colorValue: colorValue));
      saveCategories();
      notifyListeners();
    }
  }

  void removeCategory(String name, {bool deleteLogs = false}) {
    // 移除分类
    _categories.removeWhere((c) => c.name == name);
    saveCategories();

    // 处理日志
    if (deleteLogs) {
      // 删除该分类下的所有日志
      _logs.removeWhere((log) => log.category == name);
    } else {
      // 解散分类：将该分类下的日志重置为 '默认'
      for (var i = 0; i < _logs.length; i++) {
        if (_logs[i].category == name) {
          _logs[i] = _logs[i].copyWith(category: '默认');
        }
      }
    }
    saveLogs();
    notifyListeners();
  }

  void saveCategories() {
    box.put('categories_v2', _categories.map((e) => e.toJson()).toList());
  }

  void _loadCategories() {
    final stored = box.get('categories_v2');
    if (stored != null) {
      _categories = (stored as List)
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      // 尝试迁移旧分类 (List<String>)
      final oldCategories = box.get('categories');
      if (oldCategories != null && oldCategories is List) {
        _categories = oldCategories.map((name) {
          // 简单映射颜色
          int color = Colors.grey.value;
          if (name.toString().contains('工作')) color = Colors.blue.value;
          if (name.toString().contains('生活')) color = Colors.green.value;
          if (name.toString().contains('重要')) color = Colors.red.value;
          return CategoryModel(name: name.toString(), colorValue: color);
        }).toList();
      }
    }
    _initCategories();
  }

  // ================= 排序 =================
  bool _sortAscending = false; // 默认按创建时间倒序 (新的在上面)
  bool get sortAscending => _sortAscending;

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    box.put('sortAscending', _sortAscending);
    notifyListeners();
  }

  @override
  List<LogEntry> get logs {
    // 返回排序后的列表
    final sortedList = List<LogEntry>.from(_logs);
    sortedList.sort((a, b) {
      // 比较创建时间。如果没有则用 ID 或其他兜底
      final dateA = a.createdAt;
      final dateB = b.createdAt;
      return _sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    return sortedList;
  }

  // ================= 锁定状态 =================
  bool _locked = false;
  bool get locked => _locked;

  Future<void> setLocked(bool value) async {
    _locked = value;
    await windowManager.setIgnoreMouseEvents(_locked, forward: true);
    notifyListeners();
  }

  Future<void> toggleLocked() async {
    await setLocked(!_locked);
  }

  // ================= 智能穿透 =================
  bool _tempUnlocked = false;
  bool get tempUnlocked => _tempUnlocked;

  Future<void> setTempUnlock(bool unlock) async {
    if (_tempUnlocked != unlock) {
      _tempUnlocked = unlock;
      // 当处于“锁定”模式时，如果临时解锁（鼠标悬停），则允许鼠标事件
      // 如果未临时解锁（鼠标移出），则恢复忽略鼠标事件
      if (_locked) {
        await windowManager.setIgnoreMouseEvents(!unlock);
      }
      notifyListeners();
    }
  }

  // ================= 语言设置 =================
  String _locale = 'zh';
  String get locale => _locale;
  void setLocale(String v) {
    if (_locale != v) {
      _locale = v;
      box.put('locale', v);
      notifyListeners();
    }
  }
}
