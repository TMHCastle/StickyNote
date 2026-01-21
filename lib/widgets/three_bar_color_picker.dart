import 'package:flutter/material.dart';

class ThreeBarColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onChanged;

  const ThreeBarColorPicker({
    super.key,
    required this.color,
    required this.onChanged,
  });

  @override
  State<ThreeBarColorPicker> createState() => _ThreeBarColorPickerState();
}

class _ThreeBarColorPickerState extends State<ThreeBarColorPicker> {
  late double _hue;
  late double _saturation;
  late double _value;
  late double _opacity;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _opacity = widget.color.opacity;
  }

  @override
  void didUpdateWidget(covariant ThreeBarColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      final hsv = HSVColor.fromColor(widget.color);
      // Only update if significantly different to prevent sliding jitter
      if ((hsv.hue - _hue).abs() > 1 ||
          (hsv.saturation - _saturation).abs() > 0.01 ||
          (hsv.value - _value).abs() > 0.01 ||
          (widget.color.opacity - _opacity).abs() > 0.01) {
        _hue = hsv.hue;
        _saturation = hsv.saturation;
        _value = hsv.value;
        _opacity = widget.color.opacity;
      }
    }
  }

  void _updateColor() {
    final hsv = HSVColor.fromAHSV(_opacity, _hue, _saturation, _value);
    widget.onChanged(hsv.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hue Slider (Gradient)
        _buildLabel('Color (Hue)'),
        _buildGradientSlider(
          value: _hue,
          min: 0,
          max: 360,
          onChanged: (v) {
            setState(() => _hue = v);
            _updateColor();
          },
          colors: const [
            Colors.red,
            Colors.yellow,
            Colors.green,
            Colors.cyan,
            Colors.blue,
            Colors.purple,
            Colors.red,
          ],
        ),

        // 2. Saturation/Value
        _buildLabel('Saturation/Depth'),
         _buildGradientSlider(
          value: _saturation,
          min: 0,
          max: 1,
          onChanged: (v) {
            setState(() => _saturation = v);
            _updateColor();
          },
          colors: [
            HSVColor.fromAHSV(1, _hue, 0, _value).toColor(),
            HSVColor.fromAHSV(1, _hue, 1, _value).toColor(),
          ],
        ),
        
        // 3. Opacity
        _buildLabel('Transparency'),
        _buildGradientSlider(
          value: _opacity,
          min: 0,
          max: 1,
          onChanged: (v) {
            setState(() => _opacity = v);
            _updateColor();
          },
          colors: [
            Colors.transparent,
            HSVColor.fromAHSV(1, _hue, _saturation, _value).toColor(),
          ],
        ),
        
        // Preview
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '#${widget.color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2, top: 8),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    );
  }

  Widget _buildGradientSlider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required List<Color> colors,
  }) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: colors),
        border: Border.all(color: Colors.white12),
      ),
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 24,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 2),
          overlayShape: SliderComponentShape.noOverlay,
          trackShape: _CustomTrackShape(),
          thumbColor: Colors.white,
          activeTrackColor: Colors.transparent,
          inactiveTrackColor: Colors.transparent,
        ),
        child: Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
