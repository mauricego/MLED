import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mled/screens/home_screen.dart';
import 'package:mled/tools/edge_alert.dart';
import 'package:permission_handler/permission_handler.dart';

//ignore: must_be_immutable
class Bluetooth extends StatefulWidget {
  Bluetooth({Key? key}) : super(key: key);
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final serviceUUID = "f9c521f6-0f14-4499-8f76-43116b40007d";
  final wifiCharacteristicUUID = "23456f8d-4aa7-4a61-956b-39c9bce0ff00";
  final resetToken = "b055684c-68d4-41e5-ac56-d140a2668cd4";

  @override
  _Bluetooth createState() => _Bluetooth();
}

class _Bluetooth extends State<Bluetooth> {
  late BluetoothDevice connectedDevice;
  List<BluetoothDevice> bluetoothDevicesList = <BluetoothDevice>[];
  List<String> deviceList = <String>[];
  bool gotMatchingIpAddressNotify = false;
  String ipAddress = "0.0.0.0";
  late Box box;

  @override
  initState() async {
    super.initState();
    await Hive.initFlutter();
    box = await Hive.openBox("mled");
    _requestPermissionAndScan();
  }

  @override
  void dispose() {
    box.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        widget.flutterBlue.stopScan();

        try {
          await connectedDevice.disconnect();
        } catch (e) {
          //do nothing. connectedDevice not initialized
        }

        //clear the list
        bluetoothDevicesList.clear();
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
    for (BluetoothDevice device in bluetoothDevicesList) {
      if (device.name.contains("LED-Strip-")) {
        containers.add(
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(child: Center(child: Text(device.name == '' ? '(unknown device)' : device.name))),
                TextButton(
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await widget.flutterBlue.stopScan();
                    try {
                      await device.connect().onError((error, stackTrace) => {device.disconnect(), device.connect()});
                      setState(() {
                        connectedDevice = device;
                      });
                      connectedDevice = device;
                      _showDialog();
                    } catch (e) {
                      if (e != 'already_connected') {
                        rethrow;
                      }
                    }
                  },
                ),
                FlatButton(
                  color: Colors.blue,
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    await widget.flutterBlue.stopScan();
                    try {
                      await device.connect().onError((error, stackTrace) => {device.disconnect(), device.connect()});
                      setState(() {
                        connectedDevice = device;
                      });
                      connectedDevice = device;
                      String jsonString = '{"ssid":"' + widget.resetToken + '",' + '"password":"' + "reset_nvs" + '"}';
                      _sendData(jsonString);
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

  _showDialog() async {
    String ssid = "";
    String password = "";
    final text = await showTextInputDialog(
      context: context,
      textFields: const [
        DialogTextField(
          hintText: 'SSID/WLAN name',
        ),
        DialogTextField(
          hintText: 'Password',
          obscureText: true,
        ),
      ],
      title: 'Connection Setup',
      message: 'Input your SSID/WLAN name and password',
    );
    ssid = text!.elementAt(0);
    password = text.elementAt(1);
    String jsonString = '{"ssid":"' + ssid + '",' + '"password":"' + password + '"}';
    //send data to esp32
    await _sendData(jsonString);
  }

  _addBluetoothDeviceToList(final BluetoothDevice device) {
    if (!bluetoothDevicesList.contains(device)) {
      setState(() {
        bluetoothDevicesList.add(device);
      });
    }
  }

  _requestPermissionAndScan() async {
    //location is needed in order to use bluetooth
    await Permission.location.request().then((value) => _searchDevices(value));
    var status = await Permission.location.status;
  }

  _storeDevices() async {
    box.put("devices", deviceList);
  }

  _getStoredDevices() async {
    List<String>? deviceList = box.get("devices");

    if (deviceList == null) {
      box.put("devices", this.deviceList);
    } else {
      this.deviceList = deviceList;
    }
  }

  _searchDevices(PermissionStatus permission) {
    if (permission.isGranted) {
      widget.flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> devices) {
        for (BluetoothDevice device in devices) {
          _addBluetoothDeviceToList(device);
        }
      });
      widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          if (result.device.name != "" || result.device.name.contains("LED-Strip")) {
            _addBluetoothDeviceToList(result.device);
          }
        }
      });

      widget.flutterBlue.startScan(withDevices: [
        Guid(widget.serviceUUID),
      ]);
    }
  }

  _sendData(String data) async {
    late BluetoothCharacteristic wifiCharacteristic;
    RegExp regExIp = RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    List<BluetoothService> deviceServices = await connectedDevice.discoverServices();

    for (BluetoothService service in deviceServices) {
      if (service.uuid.toString() == widget.serviceUUID) {
        for (BluetoothCharacteristic blCharacteristic in service.characteristics) {
          if (blCharacteristic.uuid.toString() == widget.wifiCharacteristicUUID) {
            wifiCharacteristic = blCharacteristic;
            await wifiCharacteristic.setNotifyValue(true);
            wifiCharacteristic.value.listen((value) {
              ipAddress = utf8.decode(value).toString();
              //notify returns nothing with the first notify
              if (regExIp.hasMatch(ipAddress) && ipAddress != "0.0.0.0" && ipAddress != "") {
                if (!gotMatchingIpAddressNotify) {
                  print("notify:  " + utf8.decode(value).toString());
                  gotMatchingIpAddressNotify = true;
                  _handleNotify();
                }
              } else if (ipAddress != "") {
                _handleNotify();
              }
            });
          }
        }
      }
    }
    //write data to characteristic
    await wifiCharacteristic.write(utf8.encode(data));
  }

  Future<void> _handleNotify() async {
    if (gotMatchingIpAddressNotify) {
      await _getStoredDevices();
      deviceList.add(ipAddress);
      await _storeDevices();
      EdgeAlert.show(context,
          title: 'Connection successfully',
          description: 'You are good to go',
          gravity: EdgeAlert.TOP,
          backgroundColor: const Color.fromRGBO(46, 204, 113, 1.0),
          duration: EdgeAlert.LENGTH_SHORT,
          icon: Icons.done);
      //go back to home screen
      await box.put("isFirstLaunch", false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      EdgeAlert.show(context,
          title: 'Connection failed',
          description: 'Your SSID or Password is invalid',
          gravity: EdgeAlert.TOP,
          backgroundColor: const Color.fromRGBO(237, 66, 69, 1.0),
          duration: EdgeAlert.LENGTH_VERY_LONG,
          icon: Icons.warning);
    }
  }
}
