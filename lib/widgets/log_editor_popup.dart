import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log_entry.dart';
import '../models/category_model.dart';
import '../providers/log_provider.dart';
import '../utils/app_strings.dart';
import 'three_bar_color_picker.dart';

class LogEditorPopup extends StatefulWidget {
  final LogEntry? log; // If null, it's Add mode
  final VoidCallback onClose;

  const LogEditorPopup({super.key, this.log, required this.onClose});

  @override
  State<LogEditorPopup> createState() => _LogEditorPopupState();
}

class _LogEditorPopupState extends State<LogEditorPopup> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(); 

  late String _title;
  late String _category;
  Color? _color;
  Color? _bgColor;
  
  // _showColorPickers removed, always shown or compact

  @override
  void initState() {
    super.initState();
    if (widget.log != null) {
      _title = widget.log!.title;
      _category = widget.log!.category;
      _color = widget.log!.color != null ? Color(widget.log!.color!) : null;
      _bgColor = widget.log!.backgroundColor != null ? Color(widget.log!.backgroundColor!) : null;
      _controller.text = _title;
    } else {
      _title = '';
      _category = '默认';
      _color = null;
      _bgColor = null;
    }
  }

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

    return Container(
      width: 320,
      constraints: const BoxConstraints(minHeight: 200), // Min Height requested
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.95), // Premium Dark
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Header
           Row(
             children: [
               Text(widget.log == null ? AppStrings.get(context, 'addLog') : AppStrings.get(context, 'editLog'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
               const Spacer(),
               GestureDetector(
                 onTap: widget.onClose,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white10, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(4),
                  child:
                      const Icon(Icons.close, color: Colors.white70, size: 16),
                ),
               )
             ],
           ),
          const SizedBox(height: 16),
           
           // Content Input
           TextField(
             controller: _controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
             decoration: InputDecoration(
               hintText: AppStrings.get(context, 'enterContent'),
               hintStyle: const TextStyle(color: Colors.white38),
               filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
               isDense: true,
              contentPadding: const EdgeInsets.all(12),
             ),
            maxLines: 4,
            minLines: 2,
           ),
          const SizedBox(height: 16),
           
          // Category & Add Button
           Row(
            children: [
               Expanded(
                 child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                   decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                   ),
                   child: DropdownButtonHideUnderline(
                     child: DropdownButton<String>(
                       value: categories.any((c) => c.name == _category) ? _category : categories.first.name,
                      dropdownColor: const Color(0xFF2C2C2C),
                      icon: const Icon(Icons.expand_more,
                          color: Colors.white54, size: 20),
                       isDense: true,
                       style: const TextStyle(color: Colors.white, fontSize: 13),
                       onChanged: (val) {
                         if (val != null) setState(() => _category = val);
                       },
                       items: categories.map((c) => DropdownMenuItem(
                           value: c.name,
                           child: Row(
                             children: [
                                  Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(right: 8),
                                         decoration: BoxDecoration(color: Color(c.colorValue), shape: BoxShape.circle)),
                               Text(c.name),
                             ],
                           )
                       )).toList(),
                     ),
                   ),
                 ),
               ),
              const SizedBox(width: 8),
               GestureDetector(
                 onTap: () => _showAddCategoryDialog(context, provider),
                 child: Container(
                  width: 36,
                  height: 36,
                   decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                   ),
                  child:
                      const Icon(Icons.add, color: Colors.blueAccent, size: 20),
                 ),
               ),
             ],
           ),
          const SizedBox(height: 16),
           
          // Colors (Always shown now)
          Row(
            children: [
              _buildColorOption(
                  AppStrings.get(context, 'textColorLabel'),
                  _color, (c) => setState(() => _color = c)),
              const SizedBox(width: 16),
              _buildColorOption(
                  AppStrings.get(context, 'bgColorLabel'),
                  _bgColor, (c) => setState(() => _bgColor = c)),
              const Spacer(),
              if (_color != null || _bgColor != null)
                TextButton.icon(
                  onPressed: () => setState(() {
                    _color = null;
                    _bgColor = null;
                  }),
                  icon: const Icon(Icons.format_clear,
                      size: 14, color: Colors.white54),
                  label: Text(AppStrings.get(context, 'reset'),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white54)),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                 )
            ],
          ),
           
          const SizedBox(height: 20),
           
          // Actions
          Row(
            children: [
              if (widget.log != null) ...[
                IconButton(
                  onPressed: () {
                    if (widget.log != null) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(AppStrings.get(context, 'delete')),
                          content:
                              Text(AppStrings.get(context, 'deleteLogConfirm')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(AppStrings.get(context, 'cancel'),
                                  style: const TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.removeLog(widget.log!.id);
                                Navigator.of(ctx).pop();
                                widget.onClose();
                              },
                              child: Text(AppStrings.get(context, 'confirm'),
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: AppStrings.get(context, 'delete'),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    if (widget.log == null) {
                      provider.addLog(text,
                          category: _category,
                          color: _color?.value,
                          backgroundColor: _bgColor?.value);
                    } else {
                      final updated = widget.log!.copyWith(
                          title: text,
                          category: _category,
                          color: _color?.value,
                          backgroundColor: _bgColor?.value);
                      provider.updateLog(updated);
                    }
                    widget.onClose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                      widget.log == null
                          ? AppStrings.get(context, 'add')
                          : AppStrings.get(context, 'edit'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(
      String label, Color? color, ValueChanged<Color> onPick) {
    return GestureDetector(
      onTap: () => _showColorPicker(context, color ?? Colors.white, onPick),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                color: color ?? Colors.transparent,
                border: Border.all(color: Colors.white30),
                borderRadius: BorderRadius.circular(4)),
            child: color == null
                ? const Center(
                    child: Icon(Icons.close, size: 12, color: Colors.white30))
                : null,
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, LogProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(AppStrings.get(context, 'addCategory'), style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: _categoryController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get(context, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              final text = _categoryController.text.trim();
              if (text.isNotEmpty) {
                provider.addCategory(text, Colors.grey.value);
                setState(() => _category = text);
              }
              _categoryController.clear();
              Navigator.pop(ctx);
            },
            child: Text(AppStrings.get(context, 'add')),
          ),
        ],
      ),
    );
  }
  
  void _showColorPicker(BuildContext context, Color current, ValueChanged<Color> onPick) {
     showDialog(
       context: context,
       builder: (ctx) {
          Color temp = current == Colors.transparent ? Colors.white : current;
         return AlertDialog(
           backgroundColor: Colors.grey[900],
           content: SingleChildScrollView(
              child:
                  ThreeBarColorPicker(color: temp, onChanged: (c) => temp = c),
           ),
           actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppStrings.get(context, 'cancel'))),
              TextButton(
                  onPressed: () {
                    onPick(temp);
                    Navigator.pop(ctx);
                  },
                  child: Text(AppStrings.get(context, 'confirm'))),
           ],
         );
       }
     );
  }
}
