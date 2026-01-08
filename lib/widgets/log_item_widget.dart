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

    return CheckboxListTile(
      value: log.done,
      title: Text(
        log.title,
        style: TextStyle(
          color: Colors.white,
          decoration: log.done ? TextDecoration.lineThrough : null,
        ),
      ),
      onChanged: (val) {
        log.done = val!;
        provider.updateLog(log);
      },
    );
  }
}
