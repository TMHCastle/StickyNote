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
      appBar: AppBar(title: const Text("设置")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("界面外观",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),

          // Control Opacity
          _buildSlider(
            "控制栏/按钮透明度",
            provider.controlOpacity,
            (val) => provider.setControlOpacity(val),
            max: 1.0,
            min: 0.1,
          ),

          // Background Opacity
          _buildSlider(
            "背景透明度",
            provider.bgOpacity,
            (val) => provider.setBgOpacity(val),
          ),

          // Font Size
          _buildSlider(
            "便签字体大小 (${provider.fontSize.toInt()})",
            provider.fontSize,
            (val) => provider.setFontSize(val),
            min: 10.0,
            max: 30.0,
          ),

          const Divider(height: 32),

          const Text("全局背景色",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("点击选择背景基色"),
            trailing: ColorIndicator(
              width: 40,
              height: 40,
              borderRadius: 4,
              color: Color(provider.layoutBackgroundColor),
              onSelectFocus: false,
              onSelect: () async {
                final Color newColor = await showColorPickerDialog(
                  context,
                  Color(provider.layoutBackgroundColor),
                  title: Text("全局背景色"),
                  width: 40,
                  height: 40,
                  spacing: 0,
                  runSpacing: 0,
                  borderRadius: 0,
                  wheelDiameter: 165,
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

  Widget _buildSlider(String label, double value, Function(double) onChanged,
      {double min = 0.0, double max = 1.0}) {
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
      ],
    );
  }
}
