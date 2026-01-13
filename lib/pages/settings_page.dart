import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
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

          // 圆角调整
          _buildSlider(
            label: '窗口圆角 (${provider.borderRadius.toInt()})',
            value: provider.borderRadius,
            min: 0,
            max: 30,
            onChanged: provider.setBorderRadius,
          ),

          // 控制栏 / 按钮透明度
          _buildSlider(
            label: '控制栏 / 按钮透明度',
            value: provider.controlOpacity,
            min: 0.1,
            max: 1.0,
            onChanged: provider.setControlOpacity,
          ),

          // 背景透明度
          _buildSlider(
            label: '背景透明度',
            value: provider.bgOpacity,
            min: 0.1,
            max: 1.0,
            onChanged: provider.setBgOpacity,
          ),

          // 便签字体大小
          _buildSlider(
            label: '便签字体大小 (${provider.fontSize.toInt()})',
            value: provider.fontSize,
            min: 10,
            max: 30,
            onChanged: provider.setFontSize,
          ),

          _buildSlider(
            label: '便签透明度',
            value: provider.noteBgOpacity, // 新增字段
            min: 0.0,
            max: 1.0,
            onChanged: provider.setNoteBgOpacity,
          ),

          const Divider(height: 32),
          const Text(
            '全局背景',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          // 是否使用背景图片
          SwitchListTile(
            title: const Text('使用背景图片'),
            value: provider.useBackgroundImage,
            onChanged: provider.setUseBackgroundImage,
          ),

          // 背景颜色选择
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('背景图片'),
            subtitle: provider.backgroundImage != null
                ? Text(provider.backgroundImage!)
                : const Text('未设置图片'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () async {
                    // 使用文件选择器
                    final path = await pickImageFile(); // 自定义方法返回图片路径
                    if (path != null) {
                      provider.setBackgroundImage(path);
                    }
                  },
                ),
                if (provider.backgroundImage != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      provider.removeBackgroundImage();
                    },
                  ),
              ],
            ),
          ),

          const Divider(height: 32),
          const Text(
            '便签整体样式',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          // 便签整体背景色（独立于单条便签）
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('便签背景色'),
            trailing: ColorIndicator(
              width: 40,
              height: 40,
              borderRadius: 6,
              color: Color(provider.noteBackgroundColor),
              onSelectFocus: false,
              onSelect: () async {
                final Color newColor = await showColorPickerDialog(
                  context,
                  Color(provider.noteBackgroundColor),
                  title: const Text('便签整体背景色'),
                  enableOpacity: false,
                );
                provider.setNoteBackgroundColor(newColor.value);
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

  Future<String?> pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.single.path;
    }
    return null;
  }
}
