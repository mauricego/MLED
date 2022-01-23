import 'package:http/http.dart';
import 'dart:convert';

Future<void> postRequest(String ipAddress, String data) async{
    final url = Uri.parse("http://" + ipAddress);
    final headers = {"Content-type": "application/json"};
    final response = await post(url, headers: headers, body: data);
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
}

Future<String> getRequest(String ipAddress) async{
    final url = Uri.parse("http://" + ipAddress);
    final headers = {"Content-type": "application/json"};
    final response = await get(url, headers: headers);
    print(url);
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');

    return Future.value(response.body.toString());
}