import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mled/screens/device_screen.dart';
import 'package:mled/tools/api_request.dart';
import 'package:mled/tools/color_convert.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class DeviceCard extends StatefulWidget {
  final String ipAddress;
  bool toggleState;
  int brightness;
  int ledMode;
  int speed;
  Color primaryColor;
  Color secondaryColor;
  bool connection;
  Timer? brightnessTimer;
  Timer? checkConnectionTimer;

  DeviceCard(
      {Key? key,
      required this.ipAddress,
      required this.toggleState,
      required this.brightness,
      required this.ledMode,
      required this.speed,
      required this.primaryColor,
      required this.secondaryColor,
      required this.connection})
      : super(key: key);

  @override
  _DeviceCard createState() => _DeviceCard();
}

class _DeviceCard extends State<DeviceCard> {
  void _callbackSetState(List valueList) {
    if (valueList.length == 6) {
      setState(() {
        widget.toggleState = valueList.elementAt(0);
        widget.brightness = valueList.elementAt(1);
        widget.ledMode = valueList.elementAt(2);
        widget.speed = 5000 - int.parse(valueList.elementAt(3).toString());
        widget.primaryColor = valueList.elementAt(4);
        widget.secondaryColor = valueList.elementAt(5);
      });
    } else {
      setState(() {
        widget.connection = valueList.elementAt(0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    widget.brightnessTimer?.cancel();
    widget.checkConnectionTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    widget.checkConnectionTimer?.cancel();
    widget.checkConnectionTimer = (Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      getRequest(widget.ipAddress + "/information")
          .then((value) {
            var jsonData = value.toString();
            var parsedJson = json.decode(jsonData);
            setState(() {
              widget.toggleState = parsedJson['toggleState'];
              widget.brightness = parsedJson['brightness'];
              widget.ledMode = parsedJson['ledMode'];
              widget.speed = 5000 - int.parse(parsedJson["speed"].toString());
              widget.primaryColor = Color(parsedJson["primaryColor"]);
              widget.secondaryColor = Color(parsedJson["secondaryColor"]);
              widget.connection = true;
            });
          })
          .timeout(const Duration(seconds: 4))
          .onError((error, stackTrace) {
            setState(() {
              widget.connection = false;
            });
          });
    }));

    if (!widget.connection) {
      return _buildNoConnectionCard();
    }

    return GestureDetector(
      onTap: () async {
        widget.checkConnectionTimer?.cancel();
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DeviceScreen(
                    ipAddress: widget.ipAddress,
                    brightness: widget.brightness,
                    ledMode: widget.ledMode,
                    toggleState: widget.toggleState,
                    speed: 5000 - widget.speed,
                    primaryColor: widget.primaryColor,
                    secondaryColor: widget.secondaryColor,
                    connection: widget.connection,
                    callbackSetState: _callbackSetState)));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.toggleState
                  ? createMaterialColor(const Color.fromRGBO(5, 194, 112, 0.7))
                  : createMaterialColor(const Color.fromRGBO(255, 59, 59, 0.7)),
              blurRadius: 35,
            ),
            const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.2), blurRadius: 35, spreadRadius: 20),
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
                          color: widget.toggleState
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
                        if (widget.toggleState) {
                          postRequest(widget.ipAddress + "/toggleState", '{"toggleState": false}');
                          setState(() {
                            widget.toggleState = false;
                          });
                        } else {
                          postRequest(widget.ipAddress + "/toggleState", '{"toggleState": true}');
                          setState(() {
                            widget.toggleState = true;
                          });
                        }
                      },
                      color: createMaterialColor(const Color.fromRGBO(235, 234, 239, 0.6)),
                      highlightColor: Colors.blue,
                      splashColor: widget.toggleState
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
                      widget.brightnessTimer?.cancel();
                      widget.brightnessTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                        _brightnessTimer();
                      });
                    },
                    onChangeEnd: (value) {
                      widget.brightnessTimer?.cancel();
                      _brightnessTimer();
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

  void _brightnessTimer() {
    postRequest(widget.ipAddress + "/brightness", '{"brightness": "' + widget.brightness.toString() + '"}');
  }

  Widget _buildNoConnectionCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: createMaterialColor(const Color.fromRGBO(50, 50, 50, 1.0)),
            blurRadius: 35,
          ),
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.2), blurRadius: 35, spreadRadius: 20),
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
                        color: createMaterialColor(const Color.fromRGBO(103, 103, 103, 1.0)),
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.power_settings_new),
                    color: Colors.grey,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  "No Connection to " + widget.ipAddress,
                  textScaleFactor: 1.3,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            SfSliderTheme(
              data: SfSliderThemeData(
                activeTrackColor: const Color.fromRGBO(143, 144, 166, 1),
                inactiveTrackColor: const Color.fromRGBO(143, 144, 166, 1),
                activeTrackHeight: 10,
                inactiveTrackHeight: 10,
                thumbRadius: 12,
                thumbColor: const Color.fromRGBO(255, 255, 255, 1),
                tooltipBackgroundColor: const Color.fromRGBO(85, 88, 112, 1),
              ),
              child: SfSlider(min: 0, max: 100, value: 100, onChanged: (value) {}, onChangeStart: (value) {}, onChangeEnd: (value) {}),
            )
          ],
        ),
      ),
    );
  }
}
