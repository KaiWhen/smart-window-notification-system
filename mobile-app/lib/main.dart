import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:smart_windows_app/api/firebase_api.dart';
import 'package:smart_windows_app/api/sw_api.dart';
import 'package:smart_windows_app/assets/constants.dart' as constants;
import 'package:smart_windows_app/firebase_options.dart';
import 'package:smart_windows_app/pages/account_page.dart';
import 'package:smart_windows_app/pages/home_page.dart';
import 'package:smart_windows_app/pages/login_page.dart';
import 'package:smart_windows_app/pages/notifications_page.dart';
import 'package:smart_windows_app/pages/ownership_page.dart';
import 'package:smart_windows_app/pages/register_device_page.dart';
import 'package:smart_windows_app/pages/set_thresholds_page.dart';
import 'package:smart_windows_app/pages/user_preference_page.dart';
import 'package:smart_windows_app/util/helper.dart';

final navigatorKey = GlobalKey<NavigatorState>();
String initialRoute = '/login_page';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();
  String? fcmToken = await FirebaseApi().getFcmToken();
  if (fcmToken == null) {
    Helper.showToast("Error connecting to Firebase");
  }
  var puid = await Helper.getUserId();
  if (puid != null) {
    bool fcmSuccess = await SmartWindowApi()
        .postFcmToken(fcmToken, puid); // send fcm token to server
    if (fcmSuccess) {
      initialRoute = '/';
    } else {
      Helper.showToast("Error connecting to server");
    }
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: constants.dlrGreen,
          useMaterial3: true,
          sliderTheme: SliderThemeData(
            showValueIndicator: ShowValueIndicator.always,
            tickMarkShape: SliderTickMarkShape.noTickMark,
            activeTickMarkColor: const Color.fromARGB(0, 0, 0, 0),
            inactiveTickMarkColor: const Color.fromARGB(0, 0, 0, 0),
          )),
      initialRoute: initialRoute,
      navigatorKey: navigatorKey,
      routes: {
        '/': (context) => const HomePage(),
        '/notifications_page': (context) => const NotificationsPage(),
        '/login_page': (context) => const LoginPage(),
        '/register_device_page': (context) => const RegisterDevicePage(),
        '/set_thresholds_page': (context) => const SetThresholdsPage(),
        '/user_preferences_page': (context) => const UserPreferences(),
        '/account_page': (context) => const AccountPage(),
        '/ownership_page': (context) => const OwnershipPage(),
      },
    ));
  }
}
