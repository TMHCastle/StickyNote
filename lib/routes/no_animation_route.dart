import 'package:flutter/material.dart';

class NoAnimationRoute<T> extends PageRouteBuilder<T> {
  NoAnimationRoute({
    required Widget page,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
}
