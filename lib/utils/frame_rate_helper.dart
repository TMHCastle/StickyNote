import 'dart:ui';

class FrameRateHelper {
  static double _refreshRate = 60.0;
  static bool _initialized = false;

  static double get refreshRate => _refreshRate;

  /// 初始化：只需要调用一次
  static void init() {
    if (_initialized) return;
    _initialized = true;

    final timings = <FrameTiming>[];

    PlatformDispatcher.instance.onReportTimings = (List<FrameTiming> t) {
      timings.addAll(t);
      if (timings.length >= 10) {
        final avgFrameTimeMicros = timings
                .map((e) => e.totalSpan.inMicroseconds)
                .reduce((a, b) => a + b) /
            timings.length;

        _refreshRate = (1e6 / avgFrameTimeMicros).clamp(30, 240);
        timings.clear();
      }
    };
  }

  /// 根据基准动画时长，自动适配刷新率
  static Duration adaptiveDuration(
    Duration base, {
    double baseFps = 60,
  }) {
    final scale = baseFps / _refreshRate;
    return Duration(
      milliseconds: (base.inMilliseconds * scale).round(),
    );
  }
}
