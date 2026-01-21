import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log_entry.dart';
import '../models/category_model.dart';
import '../providers/log_provider.dart';

class LogItemWidget extends StatelessWidget {
  final LogEntry log;
  final double noteOpacity;
  final double fontSize;
  final Function(LogEntry) onEdit; // Callback

  const LogItemWidget({
    super.key,
    required this.log,
    this.noteOpacity = 1.0,
    this.fontSize = 14.0,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LogProvider>();
    
    // Find CategoryModel
    final categoryName = log.category;
    final categoryModel = provider.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () =>
          CategoryModel(name: categoryName, colorValue: Colors.grey.value),
    );

    // Compute text color
    final tagBgColor = Color(categoryModel.colorValue);
    final tagTextColor =
        tagBgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    final baseColor = log.backgroundColor != null
        ? Color(log.backgroundColor!)
        : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(baseColor.opacity * noteOpacity),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Confirm Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: log.done,
              onChanged: (val) {
                final updatedLog = log.copyWith(done: val);
                provider.updateLog(updatedLog);
              },
              side: const BorderSide(color: Colors.white60, width: 1.5),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Main Content & Tag
          Expanded(
            child: GestureDetector(
              onTap: () => onEdit(log),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    log.title,
                    style: TextStyle(
                      decoration: log.done ? TextDecoration.lineThrough : null,
                      color: log.color != null
                          ? Color(log.color!)
                          : Colors.black, // Default text
                      fontSize: fontSize,
                    ),
                  ),
                  if (categoryName != '默认')
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: tagBgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          categoryName,
                          style: TextStyle(fontSize: 10, color: tagTextColor),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. Edit Button
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onEdit(log),
            child: Icon(
              Icons.edit,
              size: 16, 
              // Use adaptive color based on baseColor luminance
              color: baseColor.computeLuminance() > 0.5
                  ? Colors.black54
                  : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
