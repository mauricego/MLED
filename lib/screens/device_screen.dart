import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:mled/tools/api_request.dart';
import 'package:mled/tools/led_modes.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class DeviceScreen extends StatefulWidget {
  final String ipAddress;
  String toggleState = "ON";
  int brightness = 255;
  int ledMode = 0;

  Timer? timer;
  ScrollController controller = ScrollController();
  PanelController panelController = PanelController();
  Color selectedModeIndicator = Colors.yellow;

  DeviceScreen({Key? key, required this.ipAddress}) : super(key: key);

  @override
  _DeviceScreen createState() => _DeviceScreen();
}

class _DeviceScreen extends State<DeviceScreen> {

  @override
  void initState() {
    Timer(
      const Duration(milliseconds: 10),
          () {
        widget.controller.jumpTo((widget.ledMode * 60) - 30);
        // widget.panelController.open();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.ipAddress),
        ),
        body: SizedBox(
          height: 700,
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
                          color: widget.toggleState == "ON" ? Colors.green.withAlpha(100) : Colors.red.withAlpha(100),
                          blurRadius: 15.0,
                          spreadRadius: 0.0,
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
                      splashColor: widget.toggleState == "ON" ? Colors.red.withAlpha(100) : Colors.green.withAlpha(100),
                    ),
                  ),
                  Expanded(
                    child: SfSlider(
                        min: 0,
                        max: 255,
                        value: widget.brightness.toDouble(),
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
                  ),
                  // IconButton(onPressed: () => _buildModeItem(), icon: const Icon(Icons.lightbulb))
                ],
              ),
              SizedBox(
                height: 500,
                child: ListView.builder(
                    controller: widget.controller,
                    scrollDirection: Axis.vertical,
                    itemCount: ledModes.length,
                    itemBuilder: (BuildContext context, int index) => _buildModeItem(context, index)),
              )
            ],
          ),
        ));
  }

  Widget _buildModeItem(BuildContext context, int index) {
    return (Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2.0),
        child: Container(
            decoration: const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: ListTile(
                onTap: () {
                  postRequest(widget.ipAddress + "/ledMode", '{"ledMode": "$index"}');
                  setState(() {
                    widget.ledMode = index;
                    widget.selectedModeIndicator = Colors.yellow;
                  });
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                leading: Container(
                  padding: const EdgeInsets.only(right: 12.0),
                  decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1.0, color: Colors.white24))),
                  child: _buildChild(index),
                ),
                title: Text(
                  ledModes[index],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )))));
  }

  Widget _buildChild(int index) {
    if (widget.ledMode == index) {
      //scroll to selected mode
      return Icon(Icons.light_mode, color: widget.selectedModeIndicator);
    } else {
      return Icon(Icons.light_mode, color: Colors.white);
    }
    // return Icon(Icons.light_mode, color: widget.selectedModeIndicator);
  }

  void brightnessTimer() {
    changeBrightness(widget.ipAddress + "/brightness", '{"brightness": "' + widget.brightness.toString() + '"}');
  }
}
