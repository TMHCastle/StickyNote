import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';

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
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(editingId == null ? "编辑日志" : "修改日志"),
      ),
      body: Column(
        children: [
          // Input Area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "输入便签内容",
                          border: InputBorder.none,
                          suffixIcon: editingId != null
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _resetForm,
                                )
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(editingId == null ? Icons.add : Icons.save,
                          color: Colors.blue),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          if (editingId == null) {
                            provider.addLog(
                              _controller.text,
                              category: selectedCategory,
                              color: selectedColor?.value,
                              backgroundColor: selectedBgColor?.value,
                            );
                          } else {
                            final log = provider.logs
                                .firstWhere((l) => l.id == editingId);
                            log.title = _controller.text;
                            log.category = selectedCategory;
                            log.color = selectedColor?.value;
                            log.backgroundColor = selectedBgColor?.value;
                            provider.updateLog(log);
                            _resetForm();
                          }
                          _controller.clear();
                        }
                      },
                    )
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    // Category Dropdown
                    DropdownButton<String>(
                      value: categories.contains(selectedCategory)
                          ? selectedCategory
                          : categories.first,
                      items: categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedCategory = val);
                      },
                      underline: Container(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      onPressed: () =>
                          _showAddCategoryDialog(context, provider),
                    ),
                    const Spacer(),
                    // Color Pickers
                    GestureDetector(
                      onTap: () async {
                        final Color newColor = await showColorPickerDialog(
                          context,
                          selectedColor ?? Colors.white,
                          title: Text("文字颜色"),
                          width: 40,
                          height: 40,
                          spacing: 0,
                          runSpacing: 0,
                          borderRadius: 0,
                          wheelDiameter: 165,
                          enableOpacity: false,
                        );
                        setState(() => selectedColor = newColor);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selectedColor ?? Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Center(
                            child: Text("T",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black))),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final Color newColor = await showColorPickerDialog(
                          context,
                          selectedBgColor ?? Colors.transparent,
                          title: Text("背景颜色"),
                          width: 40,
                          height: 40,
                          spacing: 0,
                          runSpacing: 0,
                          borderRadius: 0,
                          wheelDiameter: 165,
                          enableOpacity: true,
                        );
                        setState(() => selectedBgColor = newColor);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selectedBgColor ?? Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Center(
                            child: Text("B",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black))),
                      ),
                    ),
                  ],
                ),
                // Global settings moved to SettingsPage
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: provider.logs.length,
              itemBuilder: (context, index) {
                final log = provider.logs[index];
                return ListTile(
                  leading: Container(
                    width: 4,
                    color: log.backgroundColor != null
                        ? Color(log.backgroundColor!)
                        : Colors.grey,
                  ),
                  title: Text(log.title,
                      style: TextStyle(
                          color: log.color != null
                              ? Color(log.color!)
                              : Colors.black)),
                  subtitle: Text(log.category),
                  onTap: () {
                    setState(() {
                      editingId = log.id;
                      _controller.text = log.title;
                      selectedCategory = log.category;
                      selectedColor =
                          log.color != null ? Color(log.color!) : null;
                      selectedBgColor = log.backgroundColor != null
                          ? Color(log.backgroundColor!)
                          : null;
                    });
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => provider.removeLog(log.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
        builder: (ctx) {
          return AlertDialog(
            title: const Text("添加分类"),
            content: TextField(controller: _categoryController),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: const Text("取消")),
              TextButton(
                  onPressed: () {
                    if (_categoryController.text.isNotEmpty) {
                      provider.addCategory(_categoryController.text);
                      setState(() {
                        selectedCategory = _categoryController.text;
                      });
                      _categoryController.clear();
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("添加")),
            ],
          );
        });
  }
}
