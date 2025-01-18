import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:smart_windows_app/main.dart';
import 'package:smart_windows_app/pages/login_page.dart';

class Helper {
  static void showMessage(String text) {
    log(text);
    var alert = AlertDialog(content: Text(text), actions: <Widget>[
      TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(navigatorKey.currentContext!);
          })
    ]);
    showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) => alert);
  }

  static void showToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color.fromARGB(150, 50, 50, 50));
  }

  static void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  static Future<String?> getUserId() async {
    String? accessToken;
    if (await oauth.hasCachedAccountInformation) {
      accessToken = await oauth.getAccessToken();
    } else {
      oauth.logout();
      navigatorKey.currentState?.pushNamed('/login_page');
    }
    if (accessToken != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      String? puid = decodedToken['puid'];
      return puid;
    } else {
      return null;
    }
  }

  static Future<String?> getName() async {
    var accessToken = await oauth.getAccessToken();
    if (accessToken != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      String? puid = decodedToken['name'];
      return puid;
    } else {
      return null;
    }
  }

  static Future<String?> getEmail() async {
    var accessToken = await oauth.getAccessToken();
    if (accessToken != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      String? puid = decodedToken['email'];
      return puid;
    } else {
      return null;
    }
  }

  static Future<void> logout() async {
    await oauth.logout();
  }

  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();

  static bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }
}
