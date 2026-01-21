import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/log_provider.dart';
import '../utils/app_strings.dart';
import '../models/category_model.dart';
import 'three_bar_color_picker.dart';

class SettingsPopup extends StatefulWidget {
  const SettingsPopup({super.key});

  @override
  State<SettingsPopup> createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  bool _isAdvancedExpanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();
    final backgroundColor = Color(provider.layoutBackgroundColor);
    final textColor = _adaptiveTextColor(backgroundColor);

    final popupBgColor = Colors.black.withOpacity(provider.bgOpacity.clamp(0.5, 0.9));

    return Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 600),
      decoration: BoxDecoration(
        color: popupBgColor,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(12), // More rounded
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Basic Settings
            _buildBasicSettings(context, provider, textColor),

            const Divider(color: Colors.white12, height: 1),

            // 2. Tag Management
            _buildTagManagement(context, provider, textColor),

            const Divider(color: Colors.white12, height: 1),

            // 3. Advanced Settings
            InkWell(
              onTap: () {
                setState(() {
                  _isAdvancedExpanded = !_isAdvancedExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      AppStrings.get(context, 'advancedSettings'),
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Icon(
                      _isAdvancedExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: textColor,
                    ),
                  ],
                ),
              ),
            ),
            if (_isAdvancedExpanded)
              _buildAdvancedSettings(context, provider, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicSettings(BuildContext context, LogProvider provider, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language
           _buildDropdownRow(
            context,
            label: AppStrings.get(context, 'language'),
            textColor: textColor,
            value: provider.locale,
            items: const [
              DropdownMenuItem(value: 'zh', child: Text('中文')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (v) {
              if (v != null) provider.setLocale(v);
            },
          ),
          const SizedBox(height: 12),
          
          // Sort Order
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sort Order',
                  style: TextStyle(color: textColor, fontSize: 13)),
              GestureDetector(
                onTap: provider.toggleSortOrder,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                          provider.sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                          color: textColor),
                      const SizedBox(width: 4),
                      Text(
                          provider.sortAscending
                              ? 'Oldest First'
                              : 'Newest First',
                          style: TextStyle(color: textColor, fontSize: 12)),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),

          // Font Size
          _buildSlider(
            label:
                '${AppStrings.get(context, 'noteFontSize')} (${provider.fontSize.toInt()})',
            value: provider.fontSize,
            min: 10,
            max: 30,
            onChanged: provider.setFontSize,
            textColor: textColor,
          ),
          
          const SizedBox(height: 12),
          // === Moved to Basic: Background & Image ===

          _buildSlider(
            label: AppStrings.get(context, 'bgOpacity'),
            value: provider.bgOpacity,
            min: 0.0,
            max: 1.0,
            onChanged: provider.setBgOpacity,
            textColor: textColor,
          ),
          
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppStrings.get(context, 'useBgImage'),
                style: TextStyle(color: textColor, fontSize: 13)),
            value: provider.useBackgroundImage,
            onChanged: provider.setUseBackgroundImage,
            activeColor: Colors.blueAccent,
          ),

          if (!provider.useBackgroundImage || provider.backgroundImage == null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppStrings.get(context, 'bgColor'),
                  style: TextStyle(color: textColor, fontSize: 13)),
              trailing: GestureDetector(
                onTap: () async {
                  _showColorPickerDialog(
                      context, Color(provider.layoutBackgroundColor), (c) {
                    provider.setLayoutBackgroundColor(c.value);
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(provider.layoutBackgroundColor),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                  ),
                ),
              ),
            ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppStrings.get(context, 'bgImage'),
                style: TextStyle(color: textColor, fontSize: 13)),
            subtitle: provider.backgroundImage != null
                ? Text(
                    provider.backgroundImage!
                        .split(Platform.pathSeparator)
                        .last,
                    style: TextStyle(
                        color: textColor.withOpacity(0.6), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(AppStrings.get(context, 'noImageSet'),
                    style: TextStyle(
                        color: textColor.withOpacity(0.5), fontSize: 11)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.upload_file, size: 20),
                  color: textColor.withOpacity(0.8),
                  onPressed: () async {
                    final result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (result != null && result.files.isNotEmpty) {
                      provider.setBackgroundImage(result.files.single.path!);
                    }
                  },
                ),
                if (provider.backgroundImage != null)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: textColor.withOpacity(0.8),
                    onPressed: provider.removeBackgroundImage,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagManagement(
      BuildContext context, LogProvider provider, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(AppStrings.get(context, 'manageTags'), 
                  style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                color: textColor,
                onPressed: () {
                  _showEditTagDialog(context, provider, null);
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: provider.categories.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, index) {
                final cat = provider.categories[index];
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: GestureDetector(
                    onTap: () {
                      _showEditTagDialog(context, provider, cat);
                    },
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(cat.colorValue),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54, width: 1),
                      ),
                    ),
                  ),
                  title: Text(cat.name,
                      style: TextStyle(color: textColor, fontSize: 13)),
                  trailing: cat.name == '默认'
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          color: Colors.redAccent.withOpacity(0.7),
                          onPressed: () {
                            _showDeleteTagConfirm(context, provider, cat);
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings(
      BuildContext context, LogProvider provider, Color textColor) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
        children: [
          // === Moved here from Basic: Note Opacity & Control Opacity ===
          _buildSlider(
            label: AppStrings.get(context, 'noteOpacity'),
            value: provider.noteBgOpacity,
            min: 0.0,
            max: 1.0,
            onChanged: provider.setNoteBgOpacity,
            textColor: textColor,
          ),
          _buildSlider(
            label: AppStrings.get(context, 'controlOpacity'),
            value: provider.controlOpacity,
            min: 0.1,
            max: 1.0,
            onChanged: provider.setControlOpacity,
            textColor: textColor,
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
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textColor, fontSize: 13)),
        SizedBox(
          height: 30,
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow(BuildContext context, {required String label, required String value, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged, required Color textColor}) {
     return Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         Text(label, style: TextStyle(color: textColor, fontSize: 13)),
         DropdownButton<String>(
           dropdownColor: Colors.grey[900],
           value: value,
           items: items.map((e) => DropdownMenuItem(
             value: e.value,
             child: Text((e.child as Text).data!, style: const TextStyle(color: Colors.white, fontSize: 13))
           )).toList(), 
           onChanged: onChanged,
           underline: Container(),
           iconEnabledColor: textColor,
           isDense: true,
         )
       ],
     );
  }

  Color _adaptiveTextColor(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
  
  void _showEditTagDialog(
      BuildContext context, LogProvider provider, CategoryModel? category) {
    final isNew = category == null;
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    Color color = category != null ? Color(category.colorValue) : Colors.blue;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
              isNew ? AppStrings.get(context, 'addCategory') : 'Edit Tag',
              style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: AppStrings.get(context, 'tagName'),
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(AppStrings.get(context, 'tagColor') + ': ',
                      style: const TextStyle(color: Colors.white70)),
                  GestureDetector(
                    onTap: () {
                      _showColorPickerDialog(context, color, (c) {
                        setState(() => color = c);
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.get(context, 'cancel')),
            ),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  if (isNew) {
                    provider.addCategory(nameCtrl.text.trim(), color.value);
                  } else {
                    provider.removeCategory(category.name, deleteLogs: false);
                    provider.addCategory(nameCtrl.text.trim(), color.value);
                  }
                }
                Navigator.pop(ctx);
              },
              child: Text(AppStrings.get(context, 'add')),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteTagConfirm(
      BuildContext context, LogProvider provider, CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(AppStrings.get(context, 'deleteTagTitle'),
            style: const TextStyle(color: Colors.white)),
        content: Text(AppStrings.get(context, 'deleteTagConfirm'),
            style: const TextStyle(color: Colors.white70)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                onPressed: () {
                  provider.removeCategory(category.name, deleteLogs: true);
                  Navigator.pop(ctx);
                },
                style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                child: Text(AppStrings.get(context, 'deleteAction'),
                    style: const TextStyle(color: Colors.redAccent)),
              ),
              TextButton(
                onPressed: () {
                  provider.removeCategory(category.name, deleteLogs: false);
                  Navigator.pop(ctx);
                },
                style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                child: Text(AppStrings.get(context, 'dissolveAction'),
                    style: const TextStyle(color: Colors.orangeAccent)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppStrings.get(context, 'cancel'),
                    style: const TextStyle(color: Colors.white54)),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showColorPickerDialog(
      BuildContext context, Color current, ValueChanged<Color> onConfirm) {
    showDialog(
        context: context,
        builder: (ctx) {
          Color temp = current;
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            content: SingleChildScrollView(
                child: ThreeBarColorPicker(
              color: current,
              onChanged: (c) => temp = c,
            )),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    onConfirm(temp);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Confirm')),
            ],
          );
        });
  }
}
