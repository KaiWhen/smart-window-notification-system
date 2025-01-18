import 'package:flutter/material.dart';
import 'package:smart_windows_app/main.dart';
import 'package:smart_windows_app/pages/login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final isOwner = ModalRoute.of(context)?.settings.arguments as bool?;
    return Scaffold(
        appBar: AppBar(title: const Text("Account Settings")),
        body: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(children: [
              Expanded(
                  child: ListView(
                children: [
                  isOwner!
                      ? ListTile(
                          title: const Text('Release Ownership'),
                          onTap: () {
                            navigatorKey.currentState
                                ?.pushNamed('/ownership_page');
                          },
                        )
                      : Container(),
                  Divider(
                    color: Colors.grey[200],
                  ),
                  ListTile(
                    title: const Text('Logout'),
                    onTap: () {
                      oauth.logout();
                      navigatorKey.currentState?.pushNamed(
                        '/login_page',
                      );
                    },
                  ),
                  Divider(
                    color: Colors.grey[200],
                  ),
                ],
              )),
            ])));
  }
}
