import 'package:flutter/widgets.dart';
import '../providers/log_provider.dart';
import 'package:provider/provider.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    // FloatingOverlay
    'clickToLock': {
      'zh': '点击锁定',
      'en': 'Click to Lock',
    },
    'unlockInTray': {
      'zh': '点击解锁',
      'en': 'Click to Unlock',
    },
    'edit': {
      'zh': '编辑',
      'en': 'Edit',
    },

    // EditPage
    'addLog': {
      'zh': '新增日志',
      'en': 'Add Log',
    },
    'editLog': {
      'zh': '修改日志',
      'en': 'Edit Log',
    },
    'enterContent': {
      'zh': '输入便签内容',
      'en': 'Enter note content',
    },
    'cancelEdit': {
      'zh': '取消编辑',
      'en': 'Cancel Edit',
    },
    'addCategory': {
      'zh': '添加分类',
      'en': 'Add Category',
    },
    'textColor': {
      'zh': '文字颜色',
      'en': 'Text Color',
    },
    'bgColor': {
      'zh': '背景颜色',
      'en': 'Bg Color',
    },
    'delete': {
      'zh': '删除',
      'en': 'Delete',
    },
    'cancel': {
      'zh': '取消',
      'en': 'Cancel',
    },
    'add': {
      'zh': '添加',
      'en': 'Add',
    },

    // SettingsPage
    'settings': {
      'zh': '设置',
      'en': 'Settings',
    },
    'basicSettings': {
      'zh': '基础设置',
      'en': 'Basic Settings',
    },
    'advancedSettings': {
      'zh': '高级设置',
      'en': 'Advanced Settings',
    },
    'resetDefaults': {
      'zh': '恢复默认',
      'en': 'Reset Defaults',
    },
    'resetConfirm': {
      'zh': '确定恢复默认设置吗？',
      'en': 'Reset all settings to default?',
    },
    'appearance': {
      'zh': '界面外观',
      'en': 'Appearance',
    },
    'controlOpacity': {
      'zh': '控制栏 / 按钮透明度',
      'en': 'Control Bar / Button Opacity',
    },
    'bgOpacity': {
      'zh': '背景透明度',
      'en': 'Background Opacity',
    },
    'noteFontSize': {
      'zh': '便签字体大小',
      'en': 'Note Font Size',
    },
    'noteOpacity': {
      'zh': '便签透明度',
      'en': 'Note Opacity',
    },
    'globalBackground': {
      'zh': '全局背景',
      'en': 'Global Background',
    },
    'useBgImage': {
      'zh': '使用背景图片',
      'en': 'Use Background Image',
    },
    'pickBgColor': {
      'zh': '选择背景颜色',
      'en': 'Pick Background Color',
    },
    'bgImage': {
      'zh': '背景图片',
      'en': 'Background Image',
    },
    'noImageSet': {
      'zh': '未设置图片',
      'en': 'No Image Set',
    },
    'language': {
      'zh': '语言 / Language',
      'en': 'Language / 语言',
    },
    'manageTags': {
      'zh': '标签/分类管理',
      'en': 'Manage Tags',
    },
    'tagName': {
      'zh': '名称',
      'en': 'Name',
    },
    'tagColor': {
      'zh': '颜色',
      'en': 'Color',
    },
    'deleteTagTitle': {
      'zh': '删除标签',
      'en': 'Delete Tag',
    },
    'deleteTagConfirm': {
      'zh': '如何处理该标签下的便签？',
      'en': 'How to handle logs in this tag?',
    },
    'deleteAction': {
      'zh': '彻底删除 (包括便签)',
      'en': 'Deep Delete (Incl. Logs)',
    },
    'dissolveAction': {
      'zh': '仅解散 (便签归入默认)',
      'en': 'Dissolve (Logs to Default)',
    },
  };

  static String get(BuildContext context, String key) {
    // Read the locale directly from LogProvider without listening constantly if used in non-reactive way,
    // but usually we want to listen.
    // However, to simplify usage: AppStrings.of(context).text(key) or just static helper
    // Let's rely on the Provider being present.
    try {
      final locale = context.read<LogProvider>().locale;
      return _localizedValues[key]?[locale] ?? _localizedValues[key]?['zh'] ?? key;
    } catch (_) {
      return _localizedValues[key]?['zh'] ?? key;
    }
  }

  // Reactive helper
  static String of(BuildContext context, String key) {
    final locale = context.select<LogProvider, String>((p) => p.locale);
    return _localizedValues[key]?[locale] ?? _localizedValues[key]?['zh'] ?? key;
  }
}
