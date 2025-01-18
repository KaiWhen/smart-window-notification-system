import 'dart:core';

import 'package:flutter/material.dart';
import 'package:smart_windows_app/api/sw_api.dart';
import 'package:smart_windows_app/main.dart';
import 'package:smart_windows_app/util/helper.dart';

class AccountWidget extends StatefulWidget {
  const AccountWidget({super.key});

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  String name = '';
  String email = '';
  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    String? nameRes = await Helper.getName();
    if (!mounted) return;
    String? emailRes = await Helper.getEmail();
    if (!mounted) return;
    bool? ownerRes = await SmartWindowApi().isOwner();
    if (!mounted) return;
    setState(() {
      name = nameRes!;
      email = emailRes!;
      isOwner = ownerRes!;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        bool? isOwner = await SmartWindowApi().isOwner();
        navigatorKey.currentState
            ?.pushNamed('/account_page', arguments: isOwner);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[100],
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              // backgroundImage: AssetImage(
              //     '/assets/images/default_profile.png'), // You can replace this with your own image
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                isOwner
                    ? const Text(
                        "Owner",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
