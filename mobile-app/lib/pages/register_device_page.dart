import 'package:flutter/material.dart';
import 'package:smart_windows_app/api/sw_api.dart';
import 'package:smart_windows_app/main.dart';
import 'package:smart_windows_app/util/helper.dart';

class RegisterDevicePage extends StatefulWidget {
  const RegisterDevicePage({super.key});

  @override
  State<RegisterDevicePage> createState() => _RegisterDevicePageState();
}

class _RegisterDevicePageState extends State<RegisterDevicePage> {
  TextEditingController indoorDeviceController = TextEditingController();
  TextEditingController outdoorDeviceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height / 4),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Enter the IDs of Smart Citizen Devices',
                      style: TextStyle(fontSize: 16),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: indoorDeviceController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (id) {
                      if (id!.isNotEmpty && !Helper.isNumeric(id)) {
                        return "ID should be a positive number";
                      } else if (id.isEmpty) {
                        return "An ID is required";
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Indoor Device ID',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextFormField(
                    controller: outdoorDeviceController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (id) {
                      if (id!.isNotEmpty && !Helper.isNumeric(id)) {
                        return "ID should be a positive number";
                      } else if (id.isEmpty) {
                        return "An ID is required";
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Outdoor Device ID',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                    height: 40,
                    padding: const EdgeInsets.fromLTRB(100, 0, 100, 0),
                    child: ElevatedButton(
                      child: const Text('Submit'),
                      onPressed: () async {
                        if (indoorDeviceController.text.isEmpty ||
                            outdoorDeviceController.text.isEmpty ||
                            !Helper.isInteger(
                                int.parse(indoorDeviceController.text)) ||
                            !Helper.isInteger(
                                int.parse(outdoorDeviceController.text))) {
                          Helper.showToast("Please enter valid IDs");
                        } else {
                          int? devicesReged = await SmartWindowApi().regDevices(
                            indoorDeviceController.text,
                            outdoorDeviceController.text,
                            userId,
                          );
                          if (devicesReged == 2) {
                            navigatorKey.currentState?.pushNamed(
                              '/set_thresholds_page',
                              arguments: true,
                            );
                            Helper.showMessage(
                                "Since there are no other users registered to the specified devices, you have been given the role of owner.");
                          } else if (devicesReged == 1) {
                            navigatorKey.currentState?.pushNamed('/');
                          } else {
                            Helper.showMessage(
                                "Failed to register device IDs, please try again.");
                            navigatorKey.currentState?.pushNamed(
                              '/login_page',
                            );
                          }
                        }
                      },
                    )),
              ],
            )));
  }

  String? validInput(String id) {
    if (id.isNotEmpty && !Helper.isInteger(int.parse(id))) {
      return "ID should be a positive number";
    } else if (id.isEmpty) {
      return "An ID is required";
    } else {
      return null;
    }
  }
}
