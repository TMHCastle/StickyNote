import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'title': {
      'zh': '悬浮笔记',
      'en': 'Suspension Note',
    },
    'addLog': {
      'zh': '新增日志',
      'en': 'Add Log',
    },
    'editLog': {
      'zh': '编辑日志',
      'en': 'Edit Log',
    },
    'settings': {
      'zh': '设置',
      'en': 'Settings',
    },
    'language': {
      'zh': '语言 / Language',
      'en': 'Language',
    },
    'noteFontSize': {
      'zh': '便签字号',
      'en': 'Font Size',
    },
    'noteOpacity': {
      'zh': '便签不透明度',
      'en': 'Note Opacity',
    },
    'controlOpacity': {
      'zh': '控件不透明度',
      'en': 'Control Opacity',
    },
    'bgOpacity': {
      'zh': '背景不透明度',
      'en': 'Details Opacity',
    },

    'controlSettings': {
      'zh': '控件设置',
      'en': 'Control Settings',
    },
    'noteSettings': {
      'zh': '便签设置',
      'en': 'Note Settings',
    },
    'textOpacity': {
      'zh': '文字不透明度',
      'en': 'Text Opacity',
    },
    'bgColor': {
      'zh': '背景颜色',
      'en': 'Background Color',
    },
    'bgImage': {
      'zh': '背景图片',
      'en': 'Background Image',
    },
    'useBgImage': {
      'zh': '使用背景图片',
      'en': 'Use Image',
    },
    'noImageSet': {
      'zh': '未设置',
      'en': 'None',
    },
    'manageTags': {
      'zh': '标签管理',
      'en': 'Manage Tags',
    },
    'tagName': {
      'zh': '标签名称',
      'en': 'Tag Name',
    },
    'tagColor': {
      'zh': '标签颜色',
      'en': 'Color',
    },
    'enterContent': {
      'zh': '输入内容...',
      'en': 'Enter content...',
    },
    'confirm': {
      'zh': '确认',
      'en': 'Confirm',
    },
    'cancel': {
      'zh': '取消',
      'en': 'Cancel',
    },
    'delete': {
      'zh': '删除',
      'en': 'Delete',
    },
    'add': {
      'zh': '添加',
      'en': 'Add',
    },
    'edit': {
      'zh': '修改',
      'en': 'Edit',
    },
    'addCategory': {
      'zh': '添加标签',
      'en': 'Add Tag',
    },
    'deleteTagTitle': {
      'zh': '删除标签',
      'en': 'Delete Tag',
    },
    'deleteTagConfirm': {
      'zh': '您确定要删除此标签吗？',
      'en': 'Delete this tag?',
    },
    'deleteLogConfirm': {
      'zh': '确定要删除这条日志吗？',
      'en': 'Are you sure you want to delete this log?',
    },
    'deleteAction': {
      'zh': '删除标签及日志',
      'en': 'Delete Tag & Logs',
    },
    'dissolveAction': {
      'zh': '仅移除标签',
      'en': 'Remove Tag Only',
    },
    'advancedSettings': {
      'zh': '高级设置',
      'en': 'Advanced',
    },
    // Simplified Lock Text
    'clickToLock': {
      'zh': '点击锁定', // Or simply '锁定'
      'en': 'Lock',
    },
    'unlockInTray': {
      'zh': '点击解锁', // Simplified from '去托盘解锁'
      'en': 'Unlock',
    },
    'sortOrder': {
      'zh': '排序方式',
      'en': 'Sort Order',
    },
    'oldestFirst': {
      'zh': '最早在前',
      'en': 'Oldest First',
    },
    'newestFirst': {
      'zh': '最新在前',
      'en': 'Newest First',
    },
    'chinese': {
      'zh': '中文',
      'en': 'Chinese',
    },
    'english': {
      'zh': '英文',
      'en': 'English',
    },
    'default': {
      'zh': '默认',
      'en': 'Default',
    },
    'editTag': {
      'zh': '编辑标签',
      'en': 'Edit Tag',
    },
    'hue': {
      'zh': '色相',
      'en': 'Hue',
    },
    'saturation': {
      'zh': '饱和度',
      'en': 'Saturation',
    },
    'transparency': {
      'zh': '透明度',
      'en': 'Transparency',
    },
    'reset': {
      'zh': '重置',
      'en': 'Reset',
    },
    'textColorLabel': {
      'zh': '文字',
      'en': 'Text',
    },
    'bgColorLabel': {
      'zh': '背景',
      'en': 'Bg',
    },
    'hexLabel': {
      'zh': 'HEX',
      'en': 'HEX',
    },
    'alphaLabel': {
      'zh': 'Alpha', // Or 透明度
      'en': 'Alpha',
    },
  };

  static String get(BuildContext context, String key) {
    try {
      final locale = context.read<LogProvider>().locale;
      return _localizedValues[key]?[locale] ?? _localizedValues[key]?['zh'] ?? key;
    } catch (_) {
      return _localizedValues[key]?['zh'] ?? key;
    }
  }
}
