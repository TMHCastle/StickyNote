import 'package:flutter/material.dart';

class StrokedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  /// 文字填充色（你已有的自适应逻辑可继续使用）
  final Color fillColor;

  /// 背景颜色（用于计算描边颜色）
  final Color backgroundColor;

  /// 背景透明度 0.0 ~ 1.0
  final double backgroundOpacity;

  /// 描边宽度（不可调）
  final double strokeWidth;

  const StrokedText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    required this.fillColor,
    required this.backgroundColor,
    required this.backgroundOpacity,
    this.strokeWidth = 2.8, // 不可调
  });

  @override
  Widget build(BuildContext context) {
    final double strokeAlpha = (1.0 - backgroundOpacity).clamp(0.0, 1.0);

    final Color effectiveStrokeColor = backgroundColor.withOpacity(strokeAlpha);

    return Stack(
      children: [
        // ===== 描边层 =====
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = effectiveStrokeColor,
          ),
        ),

        // ===== 填充层 =====
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: fillColor,
          ),
        ),
      ],
    );
  }
}
