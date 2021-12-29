import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mled/colorPicker/utils.dart';

/// Painter for hue color wheel.
class HUEColorWheelPainter extends CustomPainter {
  const HUEColorWheelPainter(this.hsvColor, {this.pointerColor});

  final HSVColor hsvColor;
  final Color? pointerColor;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radio = size.width <= size.height ? size.width / 2 : size.height / 2;

    final List<Color> colors = [
      const HSVColor.fromAHSV(1.0, 360.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 300.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 180.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 60.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor(),
    ];
    final Gradient gradientS = SweepGradient(colors: colors);
    const Gradient gradientR = RadialGradient(
      colors: [
        Colors.white,
        Color(0x00FFFFFF),
      ],
    );
    canvas.drawCircle(center, radio, Paint()..shader = gradientS.createShader(rect));
    canvas.drawCircle(center, radio, Paint()..shader = gradientR.createShader(rect));
    canvas.drawCircle(center, radio, Paint()..color = Colors.black.withOpacity(1 - hsvColor.value));

    canvas.drawCircle(
      Offset(
        center.dx + hsvColor.saturation * radio * cos((hsvColor.hue * pi / 180)),
        center.dy - hsvColor.saturation * radio * sin((hsvColor.hue * pi / 180)),
      ),
      size.height * 0.04,
      Paint()
        ..color = pointerColor ?? (useWhiteForeground(hsvColor.toColor()) ? Colors.white : Colors.black)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Provide Rectangle & Circle 2 categories, 10 variations of palette widget.
class ColorPickerArea extends StatelessWidget {
  const ColorPickerArea(
    this.hsvColor,
    this.onColorChanged,
    this.onColorChangedEnd, {
    Key? key,
  }) : super(key: key);

  final HSVColor hsvColor;
  final ValueChanged<HSVColor> onColorChanged;
  final ValueChanged<HSVColor> onColorChangedEnd;

  void _handleColorWheelChange(double hue, double radio) {
    onColorChanged(hsvColor.withHue(hue).withSaturation(radio));
  }

  void _handleColorWheelChangeEnd() {
    onColorChangedEnd(hsvColor);
  }

  void _handleGesture(Offset position, BuildContext context, double height, double width) {
    RenderBox? getBox = context.findRenderObject() as RenderBox?;
    if (getBox == null) return;

    Offset localOffset = getBox.globalToLocal(position);
    double horizontal = localOffset.dx.clamp(0.0, width);
    double vertical = localOffset.dy.clamp(0.0, height);

    Offset center = Offset(width / 2, height / 2);
    double radio = width <= height ? width / 2 : height / 2;
    double dist = sqrt(pow(horizontal - center.dx, 2) + pow(vertical - center.dy, 2)) / radio;
    double rad = (atan2(horizontal - center.dx, vertical - center.dy) / pi + 1) / 2 * 360;
    _handleColorWheelChange(((rad + 90) % 360).clamp(0, 360), dist.clamp(0, 1));
  }

  void _handleGestureEnd(BuildContext context, double height, double width) {
    _handleColorWheelChangeEnd();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        // return RawGestureDetector(
        //   gestures: {
        //     _AlwaysWinPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<_AlwaysWinPanGestureRecognizer>(
        //       () => _AlwaysWinPanGestureRecognizer(),
        //       (_AlwaysWinPanGestureRecognizer instance) {
        //         instance
        //           ..onDown = ((details) => _handleGesture(details.globalPosition, context, height, width))
        //           ..onUpdate = ((details) => _handleGesture(details.globalPosition, context, height, width))
        //           ..onEnd = ((details) => _handleGestureEnd(context, height, width));
        //       },
        //     ),
        //   },
        //   child: Builder(
        //     builder: (BuildContext _) {
        //       return CustomPaint(painter: HUEColorWheelPainter(hsvColor));
        //     },
        //   ),
        // );

        return GestureDetector(
            onLongPressDown: ((details) => _handleGesture(details.globalPosition, context, height, width)),
            onLongPressEnd: ((details) => _handleGestureEnd(context, height, width)),
            onHorizontalDragUpdate: ((details) => _handleGesture(details.globalPosition, context, height, width)),
            onVerticalDragUpdate: ((details) => _handleGesture(details.globalPosition, context, height, width)),
            onHorizontalDragEnd: ((details) => _handleGestureEnd(context, height, width)),
            onVerticalDragEnd: ((details) => _handleGestureEnd(context, height, width)),
            child: Builder(
              builder: (BuildContext _) {
                return CustomPaint(painter: HUEColorWheelPainter(hsvColor));
              },
            ));
      },
    );
  }
}

class _AlwaysWinPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'alwaysWin';
}
