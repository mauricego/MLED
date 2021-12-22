import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mled/screens/device_screen.dart';
import 'package:mled/tools/api_request.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class DeviceCard extends StatefulWidget {
  final String ipAddress;
  String toggleState = "OFF";
  int brightness = 100;
  Timer? timer;

  DeviceCard({Key? key, required this.ipAddress, required this.toggleState}) : super(key: key);

  @override
  _DeviceCard createState() => _DeviceCard();
}

class _DeviceCard extends State<DeviceCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => DeviceScreen(ipAddress: widget.ipAddress, toggleState: widget.toggleState)));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 20,
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
                const SizedBox(width: 20),
                Text(widget.ipAddress, textScaleFactor: 1.3),
              ],
            ),
            SfSlider(
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
          ],
        ),
      ),
    );
  }

  void brightnessTimer() {
    changeBrightness(widget.ipAddress + "/brightness", '{"brightness": "' + widget.brightness.toString() + '"}');
  }
}
