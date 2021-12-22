import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mled/tools/api_request.dart';
import 'package:mled/tools/led_modes.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class DeviceScreen extends StatefulWidget {
  final String ipAddress;
  String toggleState = "OFF";
  int brightness = 100;
  Timer? timer;

  DeviceScreen({Key? key, required this.ipAddress, required this.toggleState}) : super(key: key);

  @override
  _DeviceScreen createState() => _DeviceScreen();
}

class _DeviceScreen extends State<DeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ipAddress),
      ),
      body: Column(
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
              IconButton(onPressed: _buildListViewLedModes, icon: Icon(Icons.lightbulb))
            ],
          ),
        ],
      ),
    );
  }

  //click on button open alert dialog
  void _buildListViewLedModes() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("LED Modes"),
            content: Container(
              height: 700,
              width: 400,
              child: ListView.builder(
                itemCount: ledModes.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(ledModes[index]),
                    onTap: () {
                      postRequest(widget.ipAddress + "/ledMode", '{"ledMode": "${index}"}');
                      // Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          );
        });
  }

  // void _buildListViewLedModes() {
  //   AlertDialog(
  //     title: const Text("Led Mode"),
  //     content: Expanded(
  //       child: ListView.builder(
  //         itemBuilder: _buildModeItem,
  //         itemCount: ledModes.length,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildModeItem(BuildContext context, int index) {
    return Card(
        elevation: 12.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
        child: Container(
            decoration: const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                leading: Container(
                  padding: const EdgeInsets.only(right: 12.0),
                  decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1.0, color: Colors.white24))),
                  child: const Icon(Icons.light_mode, color: Colors.white),
                ),
                title: Text(
                  ledModes[index],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ))));
  }

  void brightnessTimer() {
    changeBrightness(widget.ipAddress + "/brightness", '{"brightness": "' + widget.brightness.toString() + '"}');
  }
}
