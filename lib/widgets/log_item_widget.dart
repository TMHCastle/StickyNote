import 'package:flutter/material.dart';
import '../models/log_entry.dart';

class LogItemWidget extends StatelessWidget {
  final LogEntry log;
  final double noteOpacity; // 每条便签透明度 0~1
  final double fontSize; // 便签字体大小

  const LogItemWidget({
    super.key,
    required this.log,
    this.noteOpacity = 1.0,
    this.fontSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: (log.backgroundColor != null
                ? Color(log.backgroundColor!)
                : Colors.white)
            .withOpacity(noteOpacity),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        log.title,
        style: TextStyle(
          color: log.color != null ? Color(log.color!) : Colors.black,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
