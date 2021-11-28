import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:mled/screens/bluetooth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key}) : super(key: key);

  @override
  _DeviceScreen createState() => _DeviceScreen();
}

class _DeviceScreen extends State<DeviceScreen> {
  late String ipAddress;
  late List<String> deviceList;

  @override
  void initState() {
    super.initState();
    _getIpAddress();
  }

  _getIpAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    deviceList = prefs.getStringList("deviceList")!;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Device"),
        centerTitle: true,
      ),
      body: _buildListViewOfDevices());

  ListView _buildListViewOfDevices() {
    List<Container> containers = <Container>[];
    for (String device in deviceList) {
      containers.add(
        Container(
          height: 50,
          child:
            Scrollable(viewportBuilder: (BuildContext context, ViewportOffset position) {
              return Text(device);
            },)
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }
}
