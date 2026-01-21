import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../models/category_model.dart';
import '../models/log_entry.dart';
import '../providers/log_provider.dart';
import '../utils/app_strings.dart';
import '../widgets/unified_background.dart';
import '../widgets/three_bar_color_picker.dart';

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
        if (!await windowManager.isMaximized()) {
          windowManager.startDragging();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            editingId == null
                ? AppStrings.of(context, 'addLog')
                : AppStrings.of(context, 'editLog'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black.withOpacity(0.4),
          elevation: 0,
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: UnifiedBackground(),
            ),
            Column(
              children: [
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
                                hintText:
                                    AppStrings.of(context, 'enterContent'),
                                hintStyle:
                                    const TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                                suffixIcon: editingId != null
                                    ? IconButton(
                                        icon: const Icon(Icons.close),
                                        tooltip: AppStrings.of(
                                            context, 'cancelEdit'),
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
                      Row(
                        children: [
                          DropdownButton<String>(
                            dropdownColor: Colors.black.withOpacity(0.8),
                            value: categories
                                    .any((c) => c.name == selectedCategory)
                                ? selectedCategory
                                : categories.first.name,
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.name,
                                    child: Text(
                                      c.name,
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
                            tooltip: AppStrings.of(context, 'addCategory'),
                            onPressed: () =>
                                _showAddCategoryDialog(context, provider),
                          ),
                          const Spacer(),
                          _ColorDot(
                            label: 'T',
                            color: selectedColor ?? Colors.white,
                            onTap: () async {
                              final c = await _showColorPicker(
                                context,
                                selectedColor ?? Colors.white,
                              );
                              if (c != null) {
                                setState(() => selectedColor = c);
                              }
                            },
                          ),
                          _ColorDot(
                            label: 'B',
                            color: selectedBgColor ?? Colors.transparent,
                            onTap: () async {
                              final c = await _showColorPicker(
                                context,
                                selectedBgColor ?? Colors.transparent,
                              );
                              if (c != null) {
                                setState(() => selectedBgColor = c);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    onReorder: provider.reorderLogs,
                    itemCount: provider.logs.length,
                    itemBuilder: (context, index) {
                      final LogEntry log = provider.logs[index];
                      // Find category model for color
                      final categoryModel = provider.categories.firstWhere(
                          (c) => c.name == log.category,
                          orElse: () => CategoryModel(
                              name: log.category,
                              colorValue: Colors.grey.value));

                      return ListTile(
                        key: ValueKey(log.id),
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
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryModel.color.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color:
                                        categoryModel.color.withOpacity(0.5)),
                              ),
                              child: Text(
                                log.category,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _enterEdit(log),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.redAccent.withOpacity(0.8),
                              tooltip: AppStrings.of(context, 'delete'),
                              onPressed: () {
                                context.read<LogProvider>().removeLog(log.id);
                                if (editingId == log.id) {
                                  _resetForm();
                                }
                              },
                            ),
                            const Icon(
                              Icons.drag_handle,
                              color: Colors.white70,
                            ),
                          ],
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

  Future<Color?> _showColorPicker(BuildContext context, Color currentColor) {
    return showDialog<Color>(
      context: context,
      builder: (ctx) {
        Color tempColor = currentColor;
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          content: SingleChildScrollView(
            child: ThreeBarColorPicker(
              color: currentColor,
              onChanged: (c) => tempColor = c,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.of(context, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, tempColor),
              child: Text(AppStrings.of(context, 'confirm')),
            ),
          ],
        );
      },
    );
  }

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
        title: Text(AppStrings.of(context, 'addCategory')),
        content: TextField(controller: _categoryController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.of(context, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              final text = _categoryController.text.trim();
              if (text.isNotEmpty) {
                // Temporary default color
                provider.addCategory(text, Colors.grey.value);
                setState(() => selectedCategory = text);
              }
              _categoryController.clear();
              Navigator.pop(ctx);
            },
            child: Text(AppStrings.of(context, 'add')),
          ),
        ],
      ),
    );
  }
}

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
