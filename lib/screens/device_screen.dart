import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final ValueChanged<List<String>> callbackSetState;

  DeviceScreen(
      {Key? key, required this.callbackSetState, required this.ipAddress, required this.brightness, required this.ledMode, required this.toggleState})
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
                        controller: widget.controller,
                        scrollDirection: Axis.vertical,
                        itemCount: ledModes.length,
                        itemBuilder: (BuildContext context, int index) => _buildModeItem(context, index),
                      ),
                    ),
                  ],
                ),
              ),
              body: _buildBody())));

  void _showLedModePanel() {
    widget.panelController.show();
    widget.panelController.open();
    widget.controller.animateTo((widget.ledMode * 60) - 30, duration: const Duration(milliseconds: 600), curve: Curves.decelerate);
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
                    widget.callbackSetState([widget.toggleState, widget.brightness.toString(), widget.ledMode.toString()]);
                  } else {
                    postRequest(widget.ipAddress + "/toggleState", '{"toggleState": "ON"}');
                    setState(() {
                      widget.toggleState = "ON";
                    });
                    widget.callbackSetState([widget.toggleState, widget.brightness.toString(), widget.ledMode.toString()]);
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
                    widget.callbackSetState([widget.toggleState, widget.brightness.toString(), widget.ledMode.toString()]);
                  }),
            ),
          ],
        ),
        _buildModeButton()
      ],
    );
  }

  Widget _buildModeButton() {
    return SizedBox(
        height: 60,
        width: 200,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2.0),
            child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(64, 75, 96, .9),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                    onTap: () {
                      _showLedModePanel();
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                    leading: Container(
                      padding: const EdgeInsets.only(right: 12.0),
                      decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1.0, color: Colors.white24))),
                      child: _buildChild(widget.ledMode),
                    ),
                    title: Text(
                      ledModes[widget.ledMode],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )))));
  }

  Widget _buildModeItem(BuildContext context, int index) {
    return (Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2.0),
        child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(64, 75, 96, .9),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
                onTap: () {
                  postRequest(widget.ipAddress + "/ledMode", '{"ledMode": "$index"}');
                  setState(() {
                    widget.ledMode = index;
                    widget.selectedModeIndicator = Colors.yellow;
                  });
                  widget.callbackSetState([widget.toggleState, widget.brightness.toString(), widget.ledMode.toString()]);
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
      return const Icon(Icons.light_mode, color: Colors.white);
    }
    // return Icon(Icons.light_mode, color: widget.selectedModeIndicator);
  }

  void brightnessTimer() {
    changeBrightness(widget.ipAddress + "/brightness", '{"brightness": "' + widget.brightness.toString() + '"}');
  }
}
