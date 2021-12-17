import 'package:http/http.dart';
import 'dart:convert';

Future<void> postRequest(String ipAddress, String data) async{
    final url = Uri.parse("https://postman-echo.com/get?test=123");
    final headers = {"Content-type": "application/json"};
    const json = '{"title": "Hello", "body": "body text", "userId": 1}';
    final response = await get(url, headers: headers);
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
}