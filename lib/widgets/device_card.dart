import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mled/screens/device_screen.dart';
import 'package:mled/tools/api_request.dart';
import 'package:mled/tools/color_convert.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class DeviceCard extends StatefulWidget {
  final String ipAddress;
  String toggleState;
  int brightness;
  int ledMode;
  int speed;
  Timer? timer;

  DeviceCard({Key? key, required this.ipAddress, required this.toggleState, required this.brightness, required this.ledMode, required this.speed}) : super(key: key);

  @override
  _DeviceCard createState() => _DeviceCard();
}

class _DeviceCard extends State<DeviceCard> {
  late DeviceScreen deviceScreen;

  void _callbackSetState(List<String> valueList) {
    setState(() {
      widget.toggleState = valueList.elementAt(0);
      widget.brightness = int.parse(valueList.elementAt(1));
      widget.ledMode = int.parse(valueList.elementAt(2));
    });
  }

  @override
  void initState() {
    super.initState();
    deviceScreen = DeviceScreen(
      ipAddress: widget.ipAddress,
      brightness: widget.brightness,
      ledMode: widget.ledMode,
      toggleState: widget.toggleState,
      speed: widget.speed,
      callbackSetState: _callbackSetState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DeviceScreen(
                      ipAddress: widget.ipAddress,
                      brightness: widget.brightness,
                      ledMode: widget.ledMode,
                      toggleState: widget.toggleState,
                      speed: widget.speed,
                      callbackSetState: _callbackSetState,
                    )));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.toggleState == "ON"
                  ? createMaterialColor(const Color.fromRGBO(5, 194, 112, 0.7))
                  : createMaterialColor(const Color.fromRGBO(255, 59, 59, 0.7)),
              blurRadius: 35,
            ),
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 35,

              spreadRadius: 20
            ),
          ],
        ),
        child: Card(
          color: createMaterialColor(const Color.fromRGBO(40, 41, 61, 1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 30,
          child: Column(
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
                      },
                      color: createMaterialColor(const Color.fromRGBO(235, 234, 239, 0.6)),
                      highlightColor: Colors.blue,
                      splashColor: widget.toggleState == "ON"
                          ? createMaterialColor(const Color.fromRGBO(255, 59, 59, 0.2))
                          : createMaterialColor(const Color.fromRGBO(5, 194, 112, 0.2)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    widget.ipAddress,
                    textScaleFactor: 1.3,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              SfSliderTheme(
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
                      widget.timer?.cancel();
                      widget.timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                        brightnessTimer();
                      });
                    },
                    onChangeEnd: (value) {
                      widget.timer?.cancel();
                      brightnessTimer();
                      setState(() {
                        widget.brightness = value.round();
                      });
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  void brightnessTimer() {
    changeBrightness(widget.ipAddress + "/brightness", '{"brightness": "' + widget.brightness.toString() + '"}');
  }
}
