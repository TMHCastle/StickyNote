import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';

class UnifiedBackground extends StatelessWidget {
  const UnifiedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(provider.borderRadius),
        image: provider.useBackgroundImage && provider.backgroundImage != null
            ? DecorationImage(
                image: FileImage(File(provider.backgroundImage!)),
                fit: BoxFit.cover,
                opacity: provider.bgOpacity,
              )
            : null,
        color: Color(provider.layoutBackgroundColor)
            .withOpacity(provider.bgOpacity),
      ),
    );
  }
}
