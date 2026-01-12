import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log_entry.dart';
import '../providers/log_provider.dart';

class LogItemWidget extends StatelessWidget {
  final LogEntry log;

  const LogItemWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LogProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: log.backgroundColor != null ? Color(log.backgroundColor!) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: log.done,
        onChanged: (val) {
          log.done = val ?? false;
          provider.updateLog(log);
        },
        title: Text(
          log.title,
          style: TextStyle(
            decoration: log.done ? TextDecoration.lineThrough : null,
            color: log.color != null ? Color(log.color!) : Colors.white,
            fontSize: provider.fontSize,
          ),
        ),
        secondary: log.category != '默认'
            ? Chip(
                label: Text(log.category, style: const TextStyle(fontSize: 10)))
            : null,
      ),
    );
  }
}
