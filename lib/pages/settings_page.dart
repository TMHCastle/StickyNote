import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '界面外观',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            label: '控制栏 / 按钮透明度',
            value: provider.controlOpacity,
            min: 0.1,
            max: 1.0,
            onChanged: provider.setControlOpacity,
          ),
          _buildSlider(
            label: '背景透明度',
            value: provider.bgOpacity,
            min: 0.1,
            max: 1.0,
            onChanged: provider.setBgOpacity,
          ),
          _buildSlider(
            label: '便签字体大小 (${provider.fontSize.toInt()})',
            value: provider.fontSize,
            min: 10,
            max: 30,
            onChanged: provider.setFontSize,
          ),
          const Divider(height: 32),
          const Text(
            '全局背景色',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('点击选择背景基色'),
            trailing: ColorIndicator(
              width: 40,
              height: 40,
              borderRadius: 6,
              color: Color(provider.layoutBackgroundColor),
              onSelectFocus: false,
              onSelect: () async {
                final Color newColor = await showColorPickerDialog(
                  context,
                  Color(provider.layoutBackgroundColor),
                  title: const Text('全局背景色'),
                  enableOpacity: false,
                );

                provider.setLayoutBackgroundColor(newColor.value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
