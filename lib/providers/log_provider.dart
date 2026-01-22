import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';
import '../models/log_entry.dart';
import '../models/category_model.dart';
import '../listener/tray_manager_helper.dart'; // Import Tray Helper

class LogProvider extends ChangeNotifier {
  final Box box = Hive.box('logBox');

  final List<LogEntry> _logs = [];

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
    _textOpacity = box.get('textOpacity', defaultValue: 1.0);
    _noteBgColor = box.get('noteBgColor', defaultValue: Colors.black.value);
    
    // 语言设置
    if (box.containsKey('locale')) {
      _locale = box.get('locale');
    } else {
      // 首次运行，尝试读取安装程序的语言设置 (Registry)
      _locale = _detectInstallLocale();
      box.put('locale', _locale);
    }
    
    // 排序设置
    _sortAscending = box.get('sortAscending', defaultValue: false);
    _isManualSort =
        box.get('isManualSort', defaultValue: false); // Load manual sort state

    // 加载分类
    _loadCategories();

    // Sync Tray State initially
    updateTrayMenu(_locked);

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
        createdAt: DateTime.now(),
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

  double _textOpacity = 1.0;
  double get textOpacity => _textOpacity;
  void setTextOpacity(double v) {
    _textOpacity = v.clamp(0.0, 1.0);
    box.put('textOpacity', _textOpacity);
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

  /// 日志拖动排序
  void reorderLogs(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= logs.length)
      return; // check against visible list

    // Important: The UI gives indices based on the VISIBLE list (getter logs).
    // If _isManualSort is FALSE, logs are sorted by date.
    // If user drags, we IMPLICITLY switch to Manual Sort.
    if (!_isManualSort) {
      _isManualSort = true;
      box.put('isManualSort', true);
      // NOTE: If we switch to manual sort, the current `_logs` might not match visual order.
      // But reorder happens visually.
      // Simplification: We apply the move to `_logs` directly.
      // Ideally, we should first sort `_logs` to match the previous visual order, then apply the move.
      // BUT, let's assume if they drag, they lose the "Sort By Date" and just get the current underlying order + the move.
      // OR, we just re-sort `_logs` to match date before applying?
      // Let's implement robust switch:
      // If we were sorted by date, we should RE-ORDER `_logs` to match that date-sort FIRST, then apply the drag.
      _logs.sort((a, b) {
        final dateA = a.createdAt;
        final dateB = b.createdAt;
        return _sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    }

    // Bounds check
    if (newIndex > _logs.length) newIndex = _logs.length;
    if (newIndex > oldIndex) newIndex -= 1;

    final item = _logs.removeAt(oldIndex);
    _logs.insert(newIndex, item);

    saveLogs();
    notifyListeners();
  }

  // ================= 分类 =================
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  void _initCategories() {
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

  void updateCategory(String oldName, String newName, int newColorValue) {
    final index = _categories.indexWhere((c) => c.name == oldName);
    if (index != -1) {
      _categories[index] =
          CategoryModel(name: newName, colorValue: newColorValue);
      saveCategories();

      bool logsChanged = false;
      for (var i = 0; i < _logs.length; i++) {
        if (_logs[i].category == oldName) {
          _logs[i] = _logs[i].copyWith(category: newName);
          logsChanged = true;
        }
      }
      if (logsChanged) {
        saveLogs();
      }
      notifyListeners();
    }
  }

  void removeCategory(String name, {bool deleteLogs = false}) {
    _categories.removeWhere((c) => c.name == name);
    saveCategories();

    if (deleteLogs) {
      _logs.removeWhere((log) => log.category == name);
    } else {
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
      final oldCategories = box.get('categories');
      if (oldCategories != null && oldCategories is List) {
        _categories = oldCategories.map((name) {
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
  bool _sortAscending = false; 
  bool get sortAscending => _sortAscending;
  
  bool _isManualSort = false;
  bool get isManualSort => _isManualSort;

  void toggleSortOrder() {
    // Toggling sort order re-enables Date sorting and disables Manual sort
    _isManualSort = false;
    box.put('isManualSort', false);
    
    _sortAscending = !_sortAscending;
    box.put('sortAscending', _sortAscending);
    notifyListeners();
  }

  @override
  List<LogEntry> get logs {
    if (_isManualSort) {
      return List.unmodifiable(_logs);
    }
    // Else return sorted copy
    final sortedList = List<LogEntry>.from(_logs);
    sortedList.sort((a, b) {
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
    // Update Tray
    updateTrayMenu(_locked);
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

  String _detectInstallLocale() {
    if (Platform.isWindows) {
      try {
        // Query Registry: HKCU\Software\SuspensionNote -> InstallLanguage
        final result = Process.runSync('reg', [
          'query',
          'HKCU\\Software\\SuspensionNote',
          '/v',
          'InstallLanguage'
        ]);
        final output = result.stdout.toString().toLowerCase();

        if (output.contains('english')) {
          return 'en';
        } else if (output.contains('chinesesimp')) {
          return 'zh';
        }
      } catch (e) {
        debugPrint('Failed to read registry: $e');
      }
    }
    return 'zh'; // Default to Chinese if detection fails
  }
}
