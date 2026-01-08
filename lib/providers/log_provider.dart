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

  void addLog(String title) {
    _logs.add(LogEntry(id: const Uuid().v4(), title: title));
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
}
