import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mled/tools/api_request.dart';

class DeviceSettingsScreen extends StatefulWidget {
  String ipAddress;

  DeviceSettingsScreen({
    Key? key,
    required this.ipAddress,
  }) : super(key: key);

  @override
  _DeviceSettingsScreen createState() => _DeviceSettingsScreen();
}

class _DeviceSettingsScreen extends State<DeviceSettingsScreen> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Setup"),
        centerTitle: true,
      ),
      body: Column(children: [
        const SizedBox(
          height: 20,
        ),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                fixedSize: const Size(140, 60)),
            child: const Text("Reset Device"),
            onPressed: () async {
              var resBody = {};
              resBody["command"] = "reset_nvs";
              resBody["password"] = "b055684c-68d4-41e5-ac56-d140a2668cd4";
              String str = json.encode(resBody);
              postRequest(widget.ipAddress + "/reset", str);
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                fixedSize: const Size(140, 60)),
            child: const Text("Update Firmware"),
            onPressed: () async {
                getRequest(widget.ipAddress + "/update");
            },
          ),
        )
      ]));

}
