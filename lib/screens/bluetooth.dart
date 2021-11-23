import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mled/screens/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

//ignore: must_be_immutable
class Bluetooth extends StatefulWidget {
  Bluetooth({Key? key}) : super(key: key);
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  late BluetoothDevice connectedDevice;
  late String ipAddress;

  @override
  _Bluetooth createState() => _Bluetooth();
}

class _Bluetooth extends State<Bluetooth> {
  late List<BluetoothService> _services;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndScan();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        print("Scan stopped back button");
        widget.flutterBlue.stopScan();
        //disconnect the device
        try {
          await widget.connectedDevice.disconnect();
        } catch (e) {
          print(e);
        }
        //clear the list
        widget.devicesList.clear();
        //clear the state
        setState(() {});
        // pop to get back to home
        Navigator.pop(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Find devices"),
            centerTitle: true,
          ),
          body: _buildListViewOfDevices()));

  ListView _buildListViewOfDevices() {
    List<Container> containers = <Container>[];
    for (BluetoothDevice device in widget.devicesList) {
      if (device.name.contains("LED-Strip-")) {
        containers.add(
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(device.name == '' ? '(unknown device)' : device.name),
                      Text(device.id.toString()),
                    ],
                  ),
                ),
                FlatButton(
                  color: Colors.blue,
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    widget.flutterBlue.stopScan();
                    try {
                      device.connect().onError((error, stackTrace) => {device.disconnect(), device.connect()});
                      setState(() {
                        widget.connectedDevice = device;
                      });
                      _showDialog();
                    } catch (e) {
                      if (e != 'already_connected') {
                        rethrow;
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  _showDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Wanna Exit?'),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(context, false), // passing false
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () => {
                  Navigator.pop(context, true),
                  _sendData("{ssid: '57Dps3P', password: '3p7SD#m\$87sa5k?=7HG'"),
                }, // passing true
                child: Text('Yes'),
              ),
            ],
          );
        }).then((exit) {
      if (exit == null) return;

      if (exit) {
        // user pressed Yes button
      } else {
        // user pressed No button
      }
    });
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  _sendData(String data) async {
    late BluetoothCharacteristic characteristic;
    List<BluetoothService> deviceServices = await widget.connectedDevice.discoverServices();
    for (BluetoothService service in deviceServices) {
      if (service.uuid.toString() == "f9c521f6-0f14-4499-8f76-43116b40007d") {
        for (BluetoothCharacteristic blCharateristic in service.characteristics) {
          if (blCharateristic.uuid.toString() == "23456f8d-4aa7-4a61-956b-39c9bce0ff00") {
            characteristic = blCharateristic;
          }
        }
      }
    }
    //write data to characteristic
    await characteristic.write(utf8.encode(data)).then((value) => characteristic.read().then((value) => widget.ipAddress = (utf8.decode(value))));
    print(widget.ipAddress);
  }

  _requestPermissionAndScan() async {
    //location is needed in order to use bluetooth
    await Permission.location.request().then((value) => _searchDevices(value));
    var status = await Permission.location.status;
  }

  _searchDevices(PermissionStatus permission) {
    if (permission.isGranted) {
      widget.flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> devices) {
        for (BluetoothDevice device in devices) {
          _addDeviceTolist(device);
        }
      });
      widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          if (result.device.name != "") {
            _addDeviceTolist(result.device);
          }
        }
      });
      widget.flutterBlue.startScan();
    }
  }
}
