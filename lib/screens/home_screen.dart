import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mled/screens/setup_screen.dart';
import 'package:mled/tools/api_request.dart';
import 'package:mled/widgets/device_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<String> deviceList = <String>[];
  List deviceTimers = [];
  late Box box;

  @override
  initState() {
    super.initState();
    _getIpAddress();
  }

  _getIpAddress() async {
    box = await Hive.openBox("mled");

    setState(() {
      deviceList = box.get("devices", defaultValue: <String>[]);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Add Device'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SetupScreen()));
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _buildListViewOfDevices());

  ListView _buildListViewOfDevices() {
    List<FutureBuilder> containers = <FutureBuilder>[];

    for (String device in deviceList) {
      containers.add(
        FutureBuilder<String>(
          future: getRequest(device + "/information")
              .timeout(const Duration(seconds: 2))
              .onError((error, stackTrace) {
            return Future.error(error!);
          }),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError) {
              var jsonData = snapshot.data.toString();
              var parsedJson = json.decode(jsonData);
              return DeviceCard(
                ipAddress: device,
                toggleState: parsedJson['toggleState'],
                brightness: parsedJson['brightness'],
                ledMode: parsedJson['ledMode'],
                speed: parsedJson["speed"],
                primaryColor: Color(parsedJson["primaryColor"]),
                secondaryColor: Color(parsedJson["secondaryColor"]),
                connection: true,
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  children: const <Widget>[
                    SizedBox(
                      height: 250,
                    ),
                    SpinKitSpinningLines(
                      color: Colors.blue,
                      size: 100,
                      lineWidth: 5.0,
                      itemCount: 5,
                    ),
                  ],
                ),
              );
            } else {
              return DeviceCard(
                ipAddress: device,
                toggleState: false,
                brightness: 255,
                ledMode: 0,
                speed: 2000,
                primaryColor: const Color(0x00720319),
                secondaryColor: const Color(0x00720319),
                connection: false,
              );
            }
          },
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
