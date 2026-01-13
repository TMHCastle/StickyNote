import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            title: const Text('字体大小'),
            subtitle: Slider(
              min: 10,
              max: 24,
              value: provider.fontSize,
              onChanged: provider.setFontSize,
            ),
          ),
          ListTile(
            title: const Text('控制区透明度'),
            subtitle: Slider(
              min: 0.1,
              max: 1.0,
              value: provider.controlOpacity,
              onChanged: provider.setControlOpacity,
            ),
          ),
          ListTile(
            title: const Text('背景透明度'),
            subtitle: Slider(
              min: 0.1,
              max: 1.0,
              value: provider.bgOpacity,
              onChanged: provider.setBgOpacity,
            ),
          ),
        ],
      ),
    );
  }
}
