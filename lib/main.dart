import 'package:flutter/material.dart';
import 'package:mled/screens/home_screen.dart';
import 'package:mled/screens/setup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  late bool isFirstLaunch;

  Future<bool> _start() async {
    await SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool("isFirstLaunch") == null) {
        prefs.setBool("isFirstLaunch", true);
        isFirstLaunch = true;
      } else {
        isFirstLaunch = prefs.getBool("isFirstLaunch")!;
      }
    });
    return Future.value(isFirstLaunch);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: FutureBuilder<bool>(
            future: _start(), // async work
            builder: (context, AsyncSnapshot<bool> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Text('Loading....');
                default:
                  if (snapshot.hasError) {
                    return const Text('Something went wrong. Restart the app');
                  } else {
                    return isFirstLaunch ? const SetupScreen() : const HomeScreen();
                  }
              }
            }));
  }
}
