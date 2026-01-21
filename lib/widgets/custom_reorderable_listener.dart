import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomReorderableDelayedDragStartListener extends ReorderableDragStartListener {
  final Duration delay;

  const CustomReorderableDelayedDragStartListener({
    super.key,
    required super.child,
    required super.index,
    super.enabled,
    this.delay = const Duration(milliseconds: 300),
  });

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(
      delay: delay,
      debugOwner: this,
    );
  }
}
