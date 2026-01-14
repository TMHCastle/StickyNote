import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/log_provider.dart';
import '../widgets/unified_background.dart';
import '../widgets/stroked_text.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();

    final Color backgroundColor = Color(provider.layoutBackgroundColor);
    final double backgroundOpacity = provider.bgOpacity;

    final Color textColor = _adaptiveTextColor(backgroundColor);

    return ClipRRect(
        borderRadius: BorderRadius.circular(provider.borderRadius),
        child: GestureDetector(
          onPanStart: (_) async {
            // 仅在非透明区域触发拖动
            if (!await windowManager.isMaximized()) {
              windowManager.startDragging();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: StrokedText(
                '设置',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fillColor: textColor,
                backgroundColor: backgroundColor,
                backgroundOpacity: backgroundOpacity,
              ),
              backgroundColor: Colors.black.withOpacity(0.4),
              elevation: 0,
            ),
            body: Stack(
              children: [
                const Positioned.fill(
                  child: UnifiedBackground(),
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionTitle(
                      '界面外观',
                      textColor,
                      backgroundColor,
                      backgroundOpacity,
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      label: '窗口圆角 (${provider.borderRadius.toInt()})',
                      value: provider.borderRadius,
                      min: 0,
                      max: 30,
                      onChanged: provider.setBorderRadius,
                      textColor: textColor,
                      backgroundColor: backgroundColor,
                      backgroundOpacity: backgroundOpacity,
                    ),
                    _buildSlider(
                      label: '控制栏 / 按钮透明度',
                      value: provider.controlOpacity,
                      min: 0.1,
                      max: 1.0,
                      onChanged: provider.setControlOpacity,
                      textColor: textColor,
                      backgroundColor: backgroundColor,
                      backgroundOpacity: backgroundOpacity,
                    ),
                    _buildSlider(
                      label: '背景透明度',
                      value: provider.bgOpacity,
                      min: 0.0,
                      max: 1.0,
                      onChanged: provider.setBgOpacity,
                      textColor: textColor,
                      backgroundColor: backgroundColor,
                      backgroundOpacity: backgroundOpacity,
                    ),
                    _buildSlider(
                      label: '便签字体大小 (${provider.fontSize.toInt()})',
                      value: provider.fontSize,
                      min: 10,
                      max: 30,
                      onChanged: provider.setFontSize,
                      textColor: textColor,
                      backgroundColor: backgroundColor,
                      backgroundOpacity: backgroundOpacity,
                    ),
                    _buildSlider(
                      label: '便签透明度',
                      value: provider.noteBgOpacity,
                      min: 0.0,
                      max: 1.0,
                      onChanged: provider.setNoteBgOpacity,
                      textColor: textColor,
                      backgroundColor: backgroundColor,
                      backgroundOpacity: backgroundOpacity,
                    ),
                    const Divider(height: 32, color: Colors.white24),
                    _sectionTitle(
                      '全局背景',
                      textColor,
                      backgroundColor,
                      backgroundOpacity,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: StrokedText(
                        '使用背景图片',
                        fillColor: textColor,
                        backgroundColor: backgroundColor,
                        backgroundOpacity: backgroundOpacity,
                      ),
                      value: provider.useBackgroundImage,
                      onChanged: provider.setUseBackgroundImage,
                    ),
                    if (!provider.useBackgroundImage ||
                        provider.backgroundImage == null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: StrokedText(
                          '背景颜色',
                          fillColor: textColor,
                          backgroundColor: backgroundColor,
                          backgroundOpacity: backgroundOpacity,
                        ),
                        trailing: ColorIndicator(
                          width: 40,
                          height: 40,
                          borderRadius: 6,
                          color: backgroundColor,
                          onSelectFocus: false,
                          onSelect: () async {
                            final Color newColor = await showColorPickerDialog(
                              context,
                              backgroundColor,
                              title: const Text('选择背景颜色'),
                              enableOpacity: false,
                            );
                            provider.setLayoutBackgroundColor(newColor.value);
                          },
                        ),
                      ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: StrokedText(
                        '背景图片',
                        fillColor: textColor,
                        backgroundColor: backgroundColor,
                        backgroundOpacity: backgroundOpacity,
                      ),
                      subtitle: provider.backgroundImage != null
                          ? Text(
                              provider.backgroundImage!,
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                              ),
                            )
                          : Text(
                              '未设置图片',
                              style: TextStyle(
                                color: textColor.withOpacity(0.5),
                              ),
                            ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.upload_file),
                            color: textColor.withOpacity(0.7),
                            onPressed: () async {
                              final path = await pickImageFile();
                              if (path != null) {
                                provider.setBackgroundImage(path);
                              }
                            },
                          ),
                          if (provider.backgroundImage != null)
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: textColor.withOpacity(0.7),
                              onPressed: provider.removeBackgroundImage,
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 32, color: Colors.white24),
                    _sectionTitle(
                      '便签整体样式',
                      textColor,
                      backgroundColor,
                      backgroundOpacity,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: StrokedText(
                        '便签整体背景色',
                        fillColor: textColor,
                        backgroundColor: backgroundColor,
                        backgroundOpacity: backgroundOpacity,
                      ),
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
              ],
            ),
          ),
        ));
  }

  // ===== 分组标题 =====
  Widget _sectionTitle(
    String text,
    Color textColor,
    Color backgroundColor,
    double backgroundOpacity,
  ) {
    return StrokedText(
      text,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      fillColor: textColor,
      backgroundColor: backgroundColor,
      backgroundOpacity: backgroundOpacity,
    );
  }

  // ===== Slider =====
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required Color textColor,
    required Color backgroundColor,
    required double backgroundOpacity,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StrokedText(
          label,
          fillColor: textColor,
          backgroundColor: backgroundColor,
          backgroundOpacity: backgroundOpacity,
        ),
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

  // ===== 自适应文字颜色（稳定、无副作用）=====
  Color _adaptiveTextColor(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  // ===== 文件选择 =====
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
