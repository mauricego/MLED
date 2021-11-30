import 'package:flutter/material.dart';
import 'package:mled/widgets/device_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<String> deviceList = <String>[];

  @override
  initState()  {
    super.initState();
    _getIpAddress();
  }

  _getIpAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getStringList("deviceList") != null) {
        deviceList = prefs.getStringList("deviceList")!;
      }
    });
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
        //TODO ping ip and see if device is online
        Container(child: DeviceCard(ipAddress: device)),
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
