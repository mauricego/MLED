import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mled/tools/api_request.dart';

class DeviceCard extends StatefulWidget {
  final String ipAddress;
  String toggleState = "OFF";

  DeviceCard({Key? key, required this.ipAddress, required this.toggleState}) : super(key: key);

  @override
  _DeviceCard createState() => _DeviceCard();
}

class _DeviceCard extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 50,
        height: 100,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 10,
            child: Center(
                child: Row(
              children: <Widget>[
                const SizedBox(width: 20),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), boxShadow: [
                    BoxShadow(
                      // color: Colors.green.withAlpha(100),
                      color: widget.toggleState == "ON" ? Colors.green.withAlpha(100) : Colors.red.withAlpha(100),
                      blurRadius: 15.0,
                      spreadRadius: 0.0,
                    ),
                  ]),
                  child: IconButton(
                    icon: const Icon(Icons.power_settings_new),
                    onPressed: () {
                      if (widget.toggleState == "ON") {
                        postRequest(widget.ipAddress + "/toggleState", '{"toggleState": "OFF"');
                        setState(() {
                          widget.toggleState = "OFF";
                        });
                      } else {
                        postRequest(widget.ipAddress + "/toggleState", '{"toggleState": "ON"');
                        setState(() {
                          widget.toggleState = "ON";
                        });
                      }
                    },
                    splashColor: widget.toggleState == "ON" ? Colors.red.withAlpha(100) : Colors.green.withAlpha(100),
                  ),
                ),
                const SizedBox(width: 15),
                Text(widget.ipAddress),
              ],
            ))));
  }
}
