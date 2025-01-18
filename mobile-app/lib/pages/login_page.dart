import 'dart:developer';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:smart_windows_app/api/firebase_api.dart';
import 'package:smart_windows_app/api/sw_api.dart';
import 'package:smart_windows_app/main.dart';
import 'package:smart_windows_app/pages/home_page.dart';
import 'package:smart_windows_app/util/helper.dart';

final Config config = Config(
  tenant: "62852a7c-bc0f-46bb-b30a-d4c48a19d19e",
  clientId: "526a0ec9-e940-471f-a771-775669f8a975",
  scope: "openid profile offline_access",
  // redirectUri: "https://login.live.com/oauth20_desktop.srf",
  redirectUri: "https://login.microsoftonline.com/common/oauth2/nativeclient",
  navigatorKey: navigatorKey,
  webUseRedirect: true,
  loader: const Center(child: CircularProgressIndicator()),
);

final AadOAuth oauth = AadOAuth(config);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loginLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'En',
                    style: TextStyle(color: Colors.green),
                  ),
                  TextSpan(
                    text: 'Mon',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
            Text("A smart environment monitor for your\nSmart Citizen Device",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[800],
                )),
            const SizedBox(height: 20.0),
            loginLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox(),
            // Add your login form or other login related widgets here
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 50,
        margin: const EdgeInsets.all(70),
        child: SignInButton(
          Buttons.microsoft,
          onPressed: () async {
            setState(() {
              loginLoading = true;
            });
            await login(false);
            setState(() {
              loginLoading = false;
            });
          },
        ),
      ),
    );
  }

  Future<void> login(bool redirect) async {
    config.webUseRedirect = redirect;
    final result = await oauth.login();
    result.fold(
      (failure) => Helper.showToast("Log in failed"),
      (token) => log('Logged in successfully'),
    );
    var accessToken = await oauth.getAccessToken();
    if (accessToken != null) {
      // ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();
      // ScaffoldMessenger.of(navigatorKey.currentContext!)
      //     .showSnackBar(SnackBar(content: Text(accessToken)));
      log("Access token: $accessToken");
      // var response = await http.get(userProfileBaseUrl,
      //     headers: {"Authorization": 'Bearer $accessToken'});
      // log(response.body);
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      log(decodedToken['email']);
      String puid = decodedToken['puid'];
      String email = decodedToken['email'];
      int registered = await SmartWindowApi().registerUserId(puid, email);
      if (registered == 1) {
        Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(
                builder: (BuildContext context) => const HomePage()));
      } else if (registered == 2) {
        String? fcmToken = await FirebaseApi().getFcmToken();
        await SmartWindowApi().postFcmToken(fcmToken, puid);
        navigatorKey.currentState
            ?.pushNamed('/register_device_page', arguments: puid);
      } else {
        Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(
                builder: (BuildContext context) => const LoginPage()));
        Helper.showMessage("Server unavailable, please try again later.");
        // logout();
      }
    }
  }

  void logout() async {
    await oauth.logout();
    Helper.showToast('Logged out');
  }
}
