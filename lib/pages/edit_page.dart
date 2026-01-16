import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/log_provider.dart';
import '../models/log_entry.dart';
import '../widgets/unified_background.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  String? editingId;
  String selectedCategory = '默认';
  Color? selectedColor;
  Color? selectedBgColor;

  @override
  void dispose() {
    _controller.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();
    final categories = provider.categories;

    return GestureDetector(
      onPanStart: (_) async {
        // 仅在非透明区域触发拖动
        if (!await windowManager.isMaximized()) {
          windowManager.startDragging();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(editingId == null ? '新增日志' : '修改日志'),
          backgroundColor: Colors.black.withOpacity(0.4),
          elevation: 0,
        ),
        body: Stack(
          children: [
            // ===== 统一背景（与 FloatingOverlay 完全一致）=====
            const Positioned.fill(
              child: UnifiedBackground(),
            ),

            // ===== 实际内容 =====
            Column(
              children: [
                // ===== 输入区 =====
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: '输入便签内容',
                                hintStyle:
                                    const TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                                suffixIcon: editingId != null
                                    ? IconButton(
                                        icon: const Icon(Icons.close),
                                        tooltip: '取消编辑',
                                        onPressed: _resetForm,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              editingId == null ? Icons.add : Icons.save,
                              color: Colors.lightBlueAccent,
                            ),
                            onPressed: _saveOrUpdate,
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),

                      // ===== 分类 + 颜色 =====
                      Row(
                        children: [
                          DropdownButton<String>(
                            dropdownColor: Colors.black.withOpacity(0.8),
                            value: categories.contains(selectedCategory)
                                ? selectedCategory
                                : categories.first,
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedCategory = val);
                              }
                            },
                            underline: const SizedBox(),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 18,
                              color: Colors.white70,
                            ),
                            tooltip: '新增分类',
                            onPressed: () =>
                                _showAddCategoryDialog(context, provider),
                          ),
                          const Spacer(),

                          // 文字颜色
                          _ColorDot(
                            label: 'T',
                            color: selectedColor ?? Colors.white,
                            onTap: () async {
                              final c = await showColorPickerDialog(
                                context,
                                selectedColor ?? Colors.white,
                                title: const Text('文字颜色'),
                                enableOpacity: false,
                              );
                              setState(() => selectedColor = c);
                            },
                          ),

                          // 背景颜色
                          _ColorDot(
                            label: 'B',
                            color: selectedBgColor ?? Colors.transparent,
                            onTap: () async {
                              final c = await showColorPickerDialog(
                                context,
                                selectedBgColor ?? Colors.transparent,
                                title: const Text('背景颜色'),
                                enableOpacity: true,
                              );
                              setState(() => selectedBgColor = c);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

// ===== 日志列表（可拖动）=====
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    onReorder: provider.reorderLogs,
                    itemCount: provider.logs.length,
                    itemBuilder: (context, index) {
                      final LogEntry log = provider.logs[index];

                      return ListTile(
                        key: ValueKey(log.id), // 必须
                        leading: Container(
                          width: 4,
                          color: log.backgroundColor != null
                              ? Color(log.backgroundColor!)
                              : Colors.grey,
                        ),
                        title: Text(
                          log.title,
                          style: TextStyle(
                            color: log.color != null
                                ? Color(log.color!)
                                : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          log.category,
                          style: const TextStyle(color: Colors.white60),
                        ),
                        onTap: () => _enterEdit(log),
                        trailing: const Icon(
                          Icons.drag_handle,
                          color: Colors.white70,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== 行为方法（保持原样）=====

  void _saveOrUpdate() {
    final provider = context.read<LogProvider>();
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (editingId == null) {
      provider.addLog(
        text,
        category: selectedCategory,
        color: selectedColor?.value,
        backgroundColor: selectedBgColor?.value,
      );
    } else {
      final log = provider.logs.firstWhere((l) => l.id == editingId);
      final updated = log.copyWith(
        title: text,
        category: selectedCategory,
        color: selectedColor?.value,
        backgroundColor: selectedBgColor?.value,
      );
      provider.updateLog(updated);
    }

    _resetForm();
  }

  void _enterEdit(LogEntry log) {
    setState(() {
      editingId = log.id;
      _controller.text = log.title;
      selectedCategory = log.category;
      selectedColor = log.color != null ? Color(log.color!) : null;
      selectedBgColor =
          log.backgroundColor != null ? Color(log.backgroundColor!) : null;
    });
  }

  void _resetForm() {
    setState(() {
      editingId = null;
      _controller.clear();
      selectedCategory = '默认';
      selectedColor = null;
      selectedBgColor = null;
    });
  }

  void _showAddCategoryDialog(BuildContext context, LogProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加分类'),
        content: TextField(controller: _categoryController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final text = _categoryController.text.trim();
              if (text.isNotEmpty) {
                provider.addCategory(text);
                setState(() => selectedCategory = text);
              }
              _categoryController.clear();
              Navigator.pop(ctx);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}

// ===== 小组件：颜色点（保持原样）=====

class _ColorDot extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ColorDot({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
