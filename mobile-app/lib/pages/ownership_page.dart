import 'package:flutter/material.dart';
import 'package:smart_windows_app/api/sw_api.dart';
import 'package:smart_windows_app/main.dart';
import 'package:smart_windows_app/util/helper.dart';

class OwnershipPage extends StatefulWidget {
  const OwnershipPage({super.key});

  @override
  State<OwnershipPage> createState() => _OwnershipPageState();
}

class _OwnershipPageState extends State<OwnershipPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Release Ownership")),
        body: Padding(
            padding: const EdgeInsets.all(0),
            child: ListView(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height / 4),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'Enter the email of the user you wish to transfer ownership to.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    )),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) {
                      final bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(email!);
                      if (emailValid) {
                        return "Enter a valid email address";
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                    height: 40,
                    padding: const EdgeInsets.fromLTRB(120, 0, 120, 0),
                    child: ElevatedButton(
                      child: const Text('Submit'),
                      onPressed: () async {
                        final bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(_emailController.text);
                        if (!emailValid) {
                          Helper.showToast(
                              "Please enter a valid email address");
                        } else {
                          bool? success = await SmartWindowApi()
                              .transferOwnership(_emailController.text);
                          if (success!) {
                            navigatorKey.currentState?.pop();
                            Helper.showToast(
                                "Ownership transferred to ${_emailController.text}");
                          } else {
                            Helper.showToast("No user found with this email");
                          }
                        }
                      },
                    )),
              ],
            )));
  }
}
