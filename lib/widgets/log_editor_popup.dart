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
  final TextEditingController _categoryController = TextEditingController(); // For new category

  // State
  late String _title;
  late String _category;
  Color? _color;
  Color? _bgColor;
  
  bool _showColorPickers = false;

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
    
    // Adaptive text color based on popup background (blackish)
    const textColor = Colors.white;

    return Container(
      // Positioned logic will be handled by FloatingOverlay, here we just define the box
      // or we can make this a Dialog-like box.
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85), // Solid background for legibility
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Header
           Row(
             children: [
               Text(widget.log == null ? AppStrings.get(context, 'addLog') : AppStrings.get(context, 'editLog'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
               const Spacer(),
               GestureDetector(
                 onTap: widget.onClose,
                 child: const Icon(Icons.close, color: Colors.white54, size: 20),
               )
             ],
           ),
           const SizedBox(height: 12),
           
           // Content Input
           TextField(
             controller: _controller,
             style: const TextStyle(color: Colors.white),
             decoration: InputDecoration(
               hintText: AppStrings.get(context, 'enterContent'),
               hintStyle: const TextStyle(color: Colors.white38),
               filled: true,
               fillColor: Colors.white.withOpacity(0.05),
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
               isDense: true,
               contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
             ),
             maxLines: 3,
             minLines: 1,
           ),
           const SizedBox(height: 12),
           
           // Controls Row
           Row(
             children: [
               // Category Dropdown
               Expanded(
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.05),
                     borderRadius: BorderRadius.circular(4),
                   ),
                   child: DropdownButtonHideUnderline(
                     child: DropdownButton<String>(
                       value: categories.any((c) => c.name == _category) ? _category : categories.first.name,
                       dropdownColor: Colors.grey[900],
                       icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                       isDense: true,
                       style: const TextStyle(color: Colors.white, fontSize: 13),
                       onChanged: (val) {
                         if (val != null) setState(() => _category = val);
                       },
                       items: categories.map((c) => DropdownMenuItem(
                           value: c.name,
                           child: Row(
                             children: [
                               Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 6),
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
               
               // Add Category Button
               GestureDetector(
                 onTap: () => _showAddCategoryDialog(context, provider),
                 child: Container(
                   width: 32, height: 32,
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.05),
                     borderRadius: BorderRadius.circular(4),
                   ),
                   child: const Icon(Icons.add, color: Colors.white70, size: 18),
                 ),
               ),
               
               const SizedBox(width: 8),
               // Colors Toggle
               GestureDetector(
                 onTap: () => setState(() => _showColorPickers = !_showColorPickers),
                 child: Container(
                   width: 32, height: 32,
                   decoration: BoxDecoration(
                     color: (_color != null || _bgColor != null) ? Colors.blueAccent.withOpacity(0.5) : Colors.white.withOpacity(0.05),
                     borderRadius: BorderRadius.circular(4),
                     border: (_color != null || _bgColor != null) ? Border.all(color: Colors.blueAccent) : null,
                   ),
                   child: const Icon(Icons.palette, color: Colors.white70, size: 16),
                 ),
               ),
             ],
           ),
           
           if (_showColorPickers) ...[
             const SizedBox(height: 12),
             Row(
               children: [
                 Text('Text: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                 GestureDetector(
                    onTap: () => _showColorPicker(context, _color ?? Colors.white, (c) => setState(() => _color = c)),
                    child: Container(
                      width: 20, height: 20, 
                      decoration: BoxDecoration(color: _color ?? Colors.white, border: Border.all(color: Colors.white30), shape: BoxShape.circle),
                    ),
                 ),
                 const SizedBox(width: 16),
                 Text('Bg: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                 GestureDetector(
                    onTap: () => _showColorPicker(context, _bgColor ?? Colors.transparent, (c) => setState(() => _bgColor = c)),
                    child: Container(
                      width: 20, height: 20, 
                      decoration: BoxDecoration(color: _bgColor ?? Colors.black, border: Border.all(color: Colors.white30), shape: BoxShape.circle),
                    ),
                 ),
                 const Spacer(),
                 // Clear colors
                 GestureDetector(
                   onTap: () => setState(() { _color = null; _bgColor = null; }),
                   child: const Icon(Icons.format_clear, size: 16, color: Colors.white54),
                 )
               ],
             ),
           ],
           
           const SizedBox(height: 16),
           
           // Actions
           Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
               TextButton(
                 onPressed: widget.onClose, // Cancel
                 child: Text(AppStrings.get(context, 'cancel'), style: TextStyle(color: Colors.white54)),
               ),
               ElevatedButton(
                 onPressed: () {
                   final text = _controller.text.trim();
                   if (text.isEmpty) return;
                   
                   if (widget.log == null) {
                     provider.addLog(text, category: _category, color: _color?.value, backgroundColor: _bgColor?.value);
                   } else {
                     final updated = widget.log!.copyWith(
                        title: text,
                        category: _category,
                        color: _color?.value,
                        backgroundColor: _bgColor?.value
                     );
                     provider.updateLog(updated);
                   }
                   widget.onClose();
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blueAccent,
                   foregroundColor: Colors.white,
                 ),
                 child: Text(widget.log == null ? AppStrings.get(context, 'add') : AppStrings.get(context, 'edit')), // "Confirm" or "Edit"
               ),
             ],
           )
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
         Color temp = current;
         return AlertDialog(
           backgroundColor: Colors.grey[900],
           content: SingleChildScrollView(
             child: ThreeBarColorPicker(color: current, onChanged: (c) => temp = c),
           ),
           actions: [
             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
             TextButton(onPressed: () { onPick(temp); Navigator.pop(ctx); }, child: const Text('Confirm')),
           ],
         );
       }
     );
  }
}
