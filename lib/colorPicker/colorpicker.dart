import 'package:flutter/material.dart';

import 'package:mled/colorPicker/palette.dart';
import 'package:mled/colorPicker/utils.dart';

/// The default layout of Color Picker.
class ColorPicker extends StatefulWidget {
  const ColorPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    required this.onColorChangedEnd,
    this.pickerHsvColor,
    this.onHsvColorChanged,
    this.enableAlpha = false,
    this.showLabel = false,
    @Deprecated('Use Theme.of(context).textTheme.bodyText1 & 2 to alter text style.') this.labelTextStyle,
    this.displayThumbColor = false,
    this.portraitOnly = false,
    this.colorPickerWidth = 300.0,
    this.pickerAreaHeightPercent = 1.0,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
    this.hexInputBar = false,
    this.hexInputController,
    this.colorHistory,
    this.onHistoryChanged,
  }) : super(key: key);

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color> onColorChangedEnd;
  final HSVColor? pickerHsvColor;
  final ValueChanged<HSVColor>? onHsvColorChanged;
  final bool enableAlpha;
  final bool showLabel;
  final TextStyle? labelTextStyle;
  final bool displayThumbColor;
  final bool portraitOnly;
  final double colorPickerWidth;
  final double pickerAreaHeightPercent;
  final BorderRadius pickerAreaBorderRadius;
  final bool hexInputBar;

  /// Do not forget to `dispose()` your [TextEditingController] if you creating
  /// it inside any kind of [StatefulWidget]'s [State].
  /// Reference: https://en.wikipedia.org/wiki/Web_colors#Hex_triplet
  final TextEditingController? hexInputController;
  final List<Color>? colorHistory;
  final ValueChanged<List<Color>>? onHistoryChanged;

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);
  bool fingerUp = false;

  @override
  void initState() {
    currentHsvColor = (widget.pickerHsvColor != null) ? widget.pickerHsvColor as HSVColor : HSVColor.fromColor(widget.pickerColor);
    super.initState();
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = (widget.pickerHsvColor != null) ? widget.pickerHsvColor as HSVColor : HSVColor.fromColor(widget.pickerColor);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onColorChanging(HSVColor color) {
    setState(() {
      currentHsvColor = color;
    });
    widget.onColorChanged(currentHsvColor.toColor());
  }

  void onColorChangingEnd(HSVColor color) {
    setState(() {
      currentHsvColor = color;
    });
    widget.onColorChangedEnd(currentHsvColor.toColor());
  }

  Widget colorPicker() {
    return ClipRRect(
      borderRadius: widget.pickerAreaBorderRadius,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ColorPickerArea(
          currentHsvColor,
          onColorChanging,
          onColorChangingEnd,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: widget.colorPickerWidth,
          height: widget.colorPickerWidth * widget.pickerAreaHeightPercent,
          child: colorPicker(),
        ),
      ],
    );
  }
}
