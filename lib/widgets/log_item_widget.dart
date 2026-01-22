import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log_entry.dart';
import '../models/category_model.dart';
import '../providers/log_provider.dart';

class LogItemWidget extends StatelessWidget {
  final LogEntry log;
  final double noteOpacity;
  final double fontSize;
  final double textOpacity;
  final double controlOpacity;
  final Function(LogEntry) onEdit;

  const LogItemWidget({
    super.key,
    required this.log,
    this.noteOpacity = 1.0,
    this.fontSize = 14.0,
    this.textOpacity = 1.0,
    this.controlOpacity = 1.0,
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
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(baseColor.opacity * noteOpacity),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Main row centered
        children: [
          // 1. Confirm Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: log.done,
                onChanged: (val) {
                  final updatedLog = log.copyWith(done: val);
                  provider.updateLog(updatedLog);
                },
                side: BorderSide(
                    color: baseColor.computeLuminance() > 0.5
                        ? Colors.black45
                        : Colors.white60,
                    width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                activeColor: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 2. Main Content & Tag
          Expanded(
            child: GestureDetector(
              onTap: () => onEdit(log),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (categoryName != '默认')
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            categoryName,
                            style: TextStyle(
                                fontSize: 10,
                                color: tagTextColor.withOpacity(textOpacity),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          log.title,
                          style: TextStyle(
                            decoration:
                                log.done ? TextDecoration.lineThrough : null,
                            color: (log.color != null
                                    ? Color(log.color!)
                                    : (baseColor.computeLuminance() > 0.5
                                        ? Colors.black87
                                        : Colors.white))
                                .withOpacity(textOpacity),
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
              color: (baseColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white)
                  .withOpacity(controlOpacity),
            ),
          ),
        ],
      ),
    );
  }
}
