import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:smart_windows_app/main.dart';
import 'package:smart_windows_app/util/helper.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
  log("Handling a background message");
  FlutterAppBadger.updateBadgeCount(1);
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  List<Widget> notificationWidgets = <Widget>[];

  // ignore: prefer_typing_uninitialized_variables
  var previousMessage;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> handleMessage(RemoteMessage? message) async {
    if (message == null) return;
    if (message != previousMessage) {
      FlutterAppBadger.updateBadgeCount(1);
      notificationWidgets.add(
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_sharp),
            title: Text(message.notification!.title.toString()),
            subtitle: Text(message.notification!.body.toString()),
            onTap: () => {Helper.showMessage(message.data['details'])},
          ),
        ),
      );
    }

    previousMessage = message;

    int timestamp = DateTime.now().microsecondsSinceEpoch;

    navigatorKey.currentState?.pushNamed('/', arguments: {
      "notificationWidgets": notificationWidgets,
      "data": message.data,
      "index": 1,
      "timestamp": timestamp,
    });
  }

  Future<void> handleMessageInApp(RemoteMessage? message) async {
    if (message == null) return;
    showOverlayNotification((context) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: SafeArea(
          child: ListTile(
            leading: SizedBox.fromSize(
                size: const Size(40, 40),
                child: ClipOval(
                    child: Container(
                  color: Colors.black,
                ))),
            title: Text(message.notification!.title.toString()),
            subtitle: Text(message.notification!.body.toString()),
            trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  OverlaySupportEntry.of(context)?.dismiss();
                }),
          ),
        ),
      );
    }, duration: const Duration(milliseconds: 10000));

    if (message != previousMessage) {
      FlutterAppBadger.updateBadgeCount(1);
      notificationWidgets.add(
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_sharp),
            title: Text(message.notification!.title.toString()),
            subtitle: Text(message.notification!.body.toString()),
            onTap: () => {Helper.showMessage(message.data['details'])},
          ),
        ),
      );
    }

    previousMessage = message;
    int timestamp = DateTime.now().microsecondsSinceEpoch;
    navigatorKey.currentState?.pushNamed('/', arguments: {
      "notificationWidgets": notificationWidgets,
      "data": message.data,
      "index": 1,
      "timestamp": timestamp,
    });
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    initPushNotifications();
  }

  Future<String?> getFcmToken() async {
    final fCMToken = await _firebaseMessaging.getToken();
    log("FCM Token: $fCMToken");
    return fCMToken;
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen(handleMessageInApp);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  showAlertDialog(BuildContext context, String title, String body) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
