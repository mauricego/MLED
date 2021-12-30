import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:mled/colorPicker/colorpicker.dart";
import 'package:mled/colorPicker/palette.dart';
import 'package:mled/tools/api_request.dart';
import 'package:mled/tools/color_convert.dart';
import 'package:mled/tools/led_modes.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import "package:syncfusion_flutter_core/theme.dart";

class DeviceScreen extends StatefulWidget {
  final String ipAddress;
  String toggleState;
  int brightness;
  int ledMode;
  int speed;
  Color color = Color(0xff3a42ff);
  Timer? brightnessTimer;
  Timer? speedTimer;
  Timer? colorTimer;
  ScrollController ledModeScrollController = ScrollController();
  PanelController panelController = PanelController();
  Color selectedModeIndicator = Colors.yellow;
  final ValueChanged<List<String>> callbackSetState;

  DeviceScreen(
      {Key? key,
      required this.callbackSetState,
      required this.ipAddress,
      required this.brightness,
      required this.ledMode,
      required this.toggleState,
      required this.speed})
      : super(key: key);

  @override
  _DeviceScreen createState() => _DeviceScreen();
}

class _DeviceScreen extends State<DeviceScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.ipAddress),
          ),
          body: SlidingUpPanel(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              controller: widget.panelController,
              minHeight: 0,
              maxHeight: 600,
              color: const Color.fromRGBO(40, 41, 61, 1),
              backdropOpacity: 0.3,
              backdropTapClosesPanel: true,
              backdropEnabled: true,
              panel: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 40,
                      child: Column(children: <Widget>[
                        Container(
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(224, 224, 224, 1),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            margin: const EdgeInsets.all(8.0),
                            child: const SizedBox(
                              height: 8,
                              width: 50,
                            )),
                      ]),
                    ),
                    SizedBox(
                      height: 550,
                      child: ListView.builder(
                        controller: widget.ledModeScrollController,
                        scrollDirection: Axis.vertical,
                        itemCount: ledModes.length,
                        itemBuilder: (BuildContext context, int index) => _buildLedModeItem(context, index),
                      ),
                    ),
                  ],
                ),
              ),
              body: _buildBody())));

  void _showLedModePanel() {
    widget.panelController.show();
    widget.panelController.open();
    widget.ledModeScrollController.animateTo((widget.ledMode * 60) - 30, duration: const Duration(milliseconds: 600), curve: Curves.decelerate);
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        Row(
          children: <Widget>[
            const SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    // color: Colors.green.withAlpha(100),
                    color: widget.toggleState == "ON"
                        ? createMaterialColor(const Color.fromRGBO(5, 194, 112, 0.7))
                        : createMaterialColor(const Color.fromRGBO(255, 59, 59, 0.7)),
                    blurRadius: 15.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.power_settings_new),
                onPressed: () {
                  if (widget.toggleState == "ON") {
                    postRequest(widget.ipAddress + "/toggleState", '{"toggleState": "OFF"}');
                    setState(() {
                      widget.toggleState = "OFF";
                    });
                  } else {
                    postRequest(widget.ipAddress + "/toggleState", '{"toggleState": "ON"}');
                    setState(() {
                      widget.toggleState = "ON";
                    });
                  }
                  widget.callbackSetState([widget.toggleState, widget.brightness.toString(), widget.ledMode.toString(), widget.speed.toString()]);

                },
                color: createMaterialColor(const Color.fromRGBO(235, 234, 239, 0.6)),
                highlightColor: Colors.blue,
                splashColor: widget.toggleState == "ON"
                    ? createMaterialColor(const Color.fromRGBO(255, 59, 59, 0.2))
                    : createMaterialColor(const Color.fromRGBO(5, 194, 112, 0.2)),
              ),
            ),
          ],
        ),
        Column(children: [
          const Text(
            "Brightness",
            textScaleFactor: 1.2,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  blurRadius: 10.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: SfSliderTheme(
              data: SfSliderThemeData(
                activeTrackColor: const Color.fromRGBO(62, 123, 250, 1),
                inactiveTrackColor: const Color.fromRGBO(143, 144, 166, 1),
                activeTrackHeight: 10,
                inactiveTrackHeight: 10,
                thumbRadius: 12,
                thumbColor: const Color.fromRGBO(255, 255, 255, 1),
                tooltipBackgroundColor: const Color.fromRGBO(85, 88, 112, 1),
              ),
              child: SfSlider(
                  min: 0,
                  max: 255,
                  value: widget.brightness.toDouble(),
                  enableTooltip: true,
                  tooltipTextFormatterCallback: (dynamic actualValue, String formattedText) {
                    return ((actualValue / 255) * 100).round().toString() + " %";
                  },
                  onChanged: (value) {
                    setState(() {
                      widget.brightness = value.round();
                    });
                  },
                  onChangeStart: (value) {
                    widget.brightnessTimer?.cancel();
                    widget.brightnessTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                      brightnessUpdate();
                    });
                  },
                  onChangeEnd: (value) {
                    widget.brightnessTimer?.cancel();
                    brightnessUpdate();
                    setState(() {
                      widget.brightness = value.round();
                    });
                    widget.callbackSetState([widget.toggleState, widget.brightness.toString(), widget.ledMode.toString(), widget.speed.toString()]);

                  }),
            ),
          ),
        ]),
        const SizedBox(height: 15),
        Column(children: [
          const Text(
            "Speed",
            textScaleFactor: 1.2,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  blurRadius: 10.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: SfSliderTheme(
              data: SfSliderThemeData(
                activeTrackColor: const Color.fromRGBO(62, 123, 250, 1),
                inactiveTrackColor: const Color.fromRGBO(143, 144, 166, 1),
                activeTrackHeight: 10,
                inactiveTrackHeight: 10,
                thumbRadius: 12,
                thumbColor: const Color.fromRGBO(255, 255, 255, 1),
                tooltipBackgroundColor: const Color.fromRGBO(85, 88, 112, 1),
              ),
              child: SfSlider(
                  min: 0,
                  max: 65535,
                  value: widget.speed.toDouble(),
                  enableTooltip: true,
                  tooltipTextFormatterCallback: (dynamic actualValue, String formattedText) {
                    return ((actualValue / 65535) * 100).round().toString() + " %";
                  },
                  onChanged: (value) {
                    setState(() {
                      widget.speed = value.round();
                    });
                  },
                  onChangeStart: (value) {
                    widget.speedTimer?.cancel();
                    widget.speedTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                      speedUpdate();
                    });
                  },
                  onChangeEnd: (value) {
                    widget.speedTimer?.cancel();
                    speedUpdate();
                    setState(() {
                      widget.speed = value.round();
                    });
                    widget.callbackSetState([widget.toggleState, widget.brightness.toString(), widget.ledMode.toString(), widget.speed.toString()]);

                  }),
            ),
          ),
        ]),
        const SizedBox(height: 25),
        const Text(
          "Led animation mode",
          textScaleFactor: 1.2,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _buildLedModeButton(),
        const SizedBox(height: 50),
        _buildColorPicker(),
      ],
    );
  }

  Widget _buildColorPicker() {
    return ColorPicker(
      portraitOnly: true,
      pickerColor: widget.color,
      colorPickerWidth: 300,
      onColorChangedStart: (Color value){
        widget.colorTimer?.cancel();
        widget.colorTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          colorUpdate();
        });
        setState(() {
          widget.color = value;
        });
      },
      onColorChanged: (Color value) {
        setState(() {
          widget.color = value;
        });
      },
      onColorChangedEnd: (Color value) {
        widget.colorTimer?.cancel();
        brightnessUpdate();
        setState(() {
          widget.color = value;
        });
        widget.callbackSetState([widget.toggleState, widget.brightness.toString(), widget.ledMode.toString(), widget.speed.toString()]);
      },
    );
  }

  Widget _buildLedModeButton() {
    return Container(
        height: 60,
        width: 200,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.2), blurRadius: 20.0, spreadRadius: 20, offset: Offset(0, 5)),
          ],
        ),
        child: Card(
            color: createMaterialColor(const Color.fromRGBO(85, 87, 112, 1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2.0),
            child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onTap: () {
                  _showLedModePanel();
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                leading: Container(
                  padding: const EdgeInsets.only(right: 12.0),
                  decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1.0, color: Colors.white24))),
                  child: _buildLedModeChild(widget.ledMode),
                ),
                title: Text(
                  ledModes[widget.ledMode],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ))));
  }

  Widget _buildLedModeItem(BuildContext context, int index) {
    return (Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: const Color.fromRGBO(85, 87, 112, 1),
        child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(85, 87, 112, 1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
                onTap: () {
                  postRequest(widget.ipAddress + "/ledMode", '{"ledMode": "$index"}');
                  setState(() {
                    widget.ledMode = index;
                    widget.selectedModeIndicator = Colors.yellow;
                  });
                  widget.callbackSetState([widget.toggleState, widget.brightness.toString(), widget.ledMode.toString(), widget.speed.toString()]);
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                leading: Container(
                  padding: const EdgeInsets.only(right: 12.0),
                  decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1.0, color: Colors.white24))),
                  child: _buildLedModeChild(index),
                ),
                title: Text(
                  ledModes[index],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )))));
  }

  Widget _buildLedModeChild(int index) {
    if (widget.ledMode == index) {
      //scroll to selected mode
      return Icon(Icons.light_mode, color: widget.selectedModeIndicator);
    } else {
      return const Icon(Icons.light_mode, color: Colors.white);
    }
    // return Icon(Icons.light_mode, color: widget.selectedModeIndicator);
  }

  void brightnessUpdate() {
    changeBrightness(widget.ipAddress + "/brightness", '{"brightness": "' + widget.brightness.toString() + '"}');
  }

  void speedUpdate() {
    changeBrightness(widget.ipAddress + "/speed", '{"speed": "' + widget.speed.toString() + '"}');
  }

  void colorUpdate() {
    postRequest(widget.ipAddress + "/color", '{"color": "' + widget.color.toString() + '", "colorSide": "' + widget.color.toString() + '"}');
  }
}
