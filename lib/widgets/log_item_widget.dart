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
        value: log.done,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          log.title,
          style: TextStyle(
            color: log.color != null ? Color(log.color!) : Colors.white,
            decoration: log.done ? TextDecoration.lineThrough : null,
            fontSize: 12,
          ),
        ),
        onChanged: (val) {
          log.done = val!;
          provider.updateLog(log);
        },
      ),
    );
  }
}
