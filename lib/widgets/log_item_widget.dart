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
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: log.backgroundColor != null
            ? Color(log.backgroundColor!)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(
            value: log.done,
            onChanged: (v) {
              provider.updateLog(log.copyWith(done: v ?? false));
            },
          ),
          Expanded(
            child: Text(
              log.title,
              style: TextStyle(
                fontSize: provider.fontSize,
                color: log.color != null ? Color(log.color!) : Colors.white,
                decoration: log.done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => provider.removeLog(log.id),
          ),
        ],
      ),
    );
  }
}
