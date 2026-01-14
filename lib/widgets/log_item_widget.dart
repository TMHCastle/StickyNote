import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log_entry.dart';
import '../providers/log_provider.dart';

class LogItemWidget extends StatelessWidget {
  final LogEntry log;
  final double noteOpacity; // 每条便签透明度
  final double fontSize; // 字体大小

  const LogItemWidget({
    super.key,
    required this.log,
    this.noteOpacity = 1.0,
    this.fontSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LogProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: (log.backgroundColor != null
                ? Color(log.backgroundColor!)
                : Colors.white)
            .withOpacity(noteOpacity),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: log.done,
        onChanged: (val) {
          // 生成一个新的 LogEntry，修改 done 状态
          final updatedLog = LogEntry(
            id: log.id,
            title: log.title,
            done: val ?? false,
            category: log.category,
            color: log.color,
            backgroundColor: log.backgroundColor,
          );
          provider.updateLog(updatedLog);
        },
        title: Text(
          log.title,
          style: TextStyle(
            decoration: log.done ? TextDecoration.lineThrough : null,
            color: log.color != null ? Color(log.color!) : Colors.black,
            fontSize: fontSize,
          ),
        ),
        secondary: log.category != '默认'
            ? Chip(
                label: Text(
                  log.category,
                  style: const TextStyle(fontSize: 10),
                ),
              )
            : null,
      ),
    );
  }
}
