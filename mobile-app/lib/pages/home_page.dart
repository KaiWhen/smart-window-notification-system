import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_windows_app/api/sw_api.dart';
import 'package:smart_windows_app/assets/constants.dart' as constants;
import 'package:smart_windows_app/main.dart';
import 'package:smart_windows_app/pages/login_page.dart';
import 'package:smart_windows_app/util/helper.dart';
import 'package:smart_windows_app/widgets/account_widget.dart';
import 'package:smart_windows_app/widgets/line_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<HomePage> {
  int currentPageIndex = 0;
  int previousNotifTimestamp = 0;

  final TextEditingController deviceIdController = TextEditingController();
  Map? readings = {};
  Map indoorReadings = {};
  Map outdoorReadings = {};
  String windowState = "Unknown";

  Map? resultsHist = {};
  Map? indoorReadingsHist = {};
  Map? outdoorReadingsHist = {};

  bool chartLoading = true;

  String? readingTime;

  Timer? timer;
  int count = 0;

  final List<bool> _selectedEnv = <bool>[true, true];

  @override
  void initState() {
    super.initState();
    updateCurrentReadings();
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        if (await oauth.hasCachedAccountInformation) {
          updateCurrentReadings();
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      updateCurrentReadings();
    }
  }

  Future<void> updateCurrentReadings() async {
    if (!mounted) return;
    chartLoading = true;
    readings = await SmartWindowApi().getCurrentReadings();
    if (!mounted) return;
    await updateReadings();
    if (!mounted) return;
    setState(() {
      indoorReadings = readings?['indoor'] ?? {};
      outdoorReadings = readings?['outdoor'] ?? {};
      if (indoorReadings["Window State"]?['reading_value'] == 0) {
        windowState = "Closed";
      } else if (indoorReadings["Window State"]?['reading_value'] == 1) {
        windowState = "Open";
      }
      chartLoading = false;
    });
  }

  Future<void> updateReadings() async {
    if (!mounted) return;
    resultsHist = await SmartWindowApi().getReadingsHistorical();
    if (!mounted) return;
    if (resultsHist != null && resultsHist!.entries.isNotEmpty) {
      setState(() {
        indoorReadingsHist = resultsHist?['indoor'];
        outdoorReadingsHist = resultsHist?['outdoor'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final notification = ModalRoute.of(context)?.settings.arguments as Map?;
    setState(() {
      if (notification?['index'] != null &&
          notification?['timestamp'] != null &&
          previousNotifTimestamp != notification?['timestamp']) {
        previousNotifTimestamp = notification?['timestamp'];
        currentPageIndex = notification?['index'];
      }
    });
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
            updateCurrentReadings();
          });
        },
        indicatorColor: constants.dlrGreen,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home_outlined),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notifications_outlined),
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings_outlined),
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
          onRefresh: updateCurrentReadings,
          child: <Widget>[
            /// Home page
            Center(
              // shadowColor: Colors.transparent,
              // margin: const EdgeInsets.all(8.0),
              child: SizedBox.expand(
                  child: Column(children: [
                Container(
                  // width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height / 6,
                  padding: const EdgeInsets.fromLTRB(15, 40, 15, 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Window Status: $windowState',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      IntrinsicHeight(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.house_rounded,
                            color: Colors.grey[850],
                          ),
                          Flexible(
                            child: Text(
                              '${indoorReadings["Temperature"]?['reading_value'].toStringAsFixed(2) ?? '-'}°C',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.forest_rounded,
                            color: Colors.grey[850],
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Flexible(
                            child: Text(
                              '${outdoorReadings['Temperature']?['reading_value'].toStringAsFixed(2) ?? '-'}°C',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                ToggleButtons(
                  direction: Axis.horizontal,
                  onPressed: (int index) {
                    setState(() {
                      // The button that is tapped is set to true, and the others to false.
                      _selectedEnv[index] = !_selectedEnv[index];
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: const Color.fromARGB(255, 56, 142, 82),
                  selectedColor: Colors.white,
                  fillColor: const Color.fromARGB(255, 129, 199, 150),
                  color: const Color.fromARGB(255, 102, 187, 120),
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                    minWidth: 80.0,
                  ),
                  isSelected: _selectedEnv,
                  children: const [Text("Indoor"), Text("Outdoor")],
                ),
                Expanded(
                    child: !chartLoading
                        ? SingleChildScrollView(
                            child: Column(children: [
                            const SizedBox(height: 40),
                            LineChartWidget(
                                readings: indoorReadingsHist?['Temperature'] !=
                                            null &&
                                        _selectedEnv[0]
                                    ? List.from(
                                        indoorReadingsHist?['Temperature']
                                            .reversed)
                                    : const [],
                                outdoorReadings:
                                    outdoorReadingsHist?['Temperature'] !=
                                                null &&
                                            _selectedEnv[1]
                                        ? List.from(
                                            outdoorReadingsHist?['Temperature']
                                                .reversed)
                                        : const [],
                                sensorType: 'Temperature (°C)',
                                readingTime: notification?['data']
                                    ['reading_time']),
                            const SizedBox(
                              height: 20,
                            ),
                            LineChartWidget(
                                readings: indoorReadingsHist?['Humidity'] !=
                                            null &&
                                        _selectedEnv[0]
                                    ? List.from(indoorReadingsHist?['Humidity']
                                        .reversed)
                                    : const [],
                                outdoorReadings:
                                    outdoorReadingsHist?['Humidity'] != null &&
                                            _selectedEnv[1]
                                        ? List.from(
                                            outdoorReadingsHist?['Humidity']
                                                .reversed)
                                        : const [],
                                sensorType: 'Humidity (%)',
                                readingTime: notification?['data']
                                    ['reading_time']),
                            const SizedBox(
                              height: 20,
                            ),
                            LineChartWidget(
                                readings: indoorReadingsHist?['eCO2'] != null &&
                                        _selectedEnv[0]
                                    ? List.from(
                                        indoorReadingsHist?['eCO2'].reversed)
                                    : const [],
                                outdoorReadings: outdoorReadingsHist?['eCO2'] !=
                                            null &&
                                        _selectedEnv[1]
                                    ? List.from(
                                        outdoorReadingsHist?['eCO2'].reversed)
                                    : const [],
                                sensorType: 'eCO2 (ppm)',
                                readingTime: notification?['data']
                                    ['reading_time']),
                            const SizedBox(
                              height: 20,
                            ),
                            LineChartWidget(
                                readings: indoorReadingsHist?['TVOC'] != null &&
                                        _selectedEnv[0]
                                    ? List.from(
                                        indoorReadingsHist?['TVOC'].reversed)
                                    : const [],
                                outdoorReadings: outdoorReadingsHist?['TVOC'] !=
                                            null &&
                                        _selectedEnv[1]
                                    ? List.from(
                                        outdoorReadingsHist?['TVOC'].reversed)
                                    : const [],
                                sensorType: 'TVOC (ppb)',
                                readingTime: notification?['data']
                                    ['reading_time']),
                            const SizedBox(
                              height: 20,
                            ),
                            LineChartWidget(
                                readings: indoorReadingsHist?['PM2.5'] !=
                                            null &&
                                        _selectedEnv[0]
                                    ? List.from(
                                        indoorReadingsHist?['PM2.5'].reversed)
                                    : const [],
                                outdoorReadings:
                                    outdoorReadingsHist?['PM2.5'] != null &&
                                            _selectedEnv[1]
                                        ? List.from(
                                            outdoorReadingsHist?['PM2.5']
                                                .reversed)
                                        : const [],
                                sensorType: 'PM2.5 (μg/m\u00B3)',
                                readingTime: notification?['data']
                                    ['reading_time']),
                            const SizedBox(
                              height: 20,
                            ),
                            LineChartWidget(
                                readings: indoorReadingsHist?['PM1.0'] !=
                                            null &&
                                        _selectedEnv[0]
                                    ? List.from(
                                        indoorReadingsHist?['PM1.0'].reversed)
                                    : const [],
                                outdoorReadings:
                                    outdoorReadingsHist?['PM1.0'] != null &&
                                            _selectedEnv[1]
                                        ? List.from(
                                            outdoorReadingsHist?['PM1.0']
                                                .reversed)
                                        : const [],
                                sensorType: 'PM1.0 (μg/m\u00B3)',
                                readingTime: notification?['data']
                                    ['reading_time']),
                            const SizedBox(
                              height: 20,
                            ),
                            LineChartWidget(
                                readings: indoorReadingsHist?['PM10'] != null &&
                                        _selectedEnv[0]
                                    ? List.from(
                                        indoorReadingsHist?['PM10'].reversed)
                                    : const [],
                                outdoorReadings: outdoorReadingsHist?['PM10'] !=
                                            null &&
                                        _selectedEnv[1]
                                    ? List.from(
                                        outdoorReadingsHist?['PM10'].reversed)
                                    : const [],
                                sensorType: 'PM10 (μg/m\u00B3)',
                                readingTime: notification?['data']
                                    ['reading_time']),
                          ]))
                        : const Center(child: CircularProgressIndicator()))
              ])),
            ),

            /// Notifications page
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: notification?['notificationWidgets']?.length,
                    itemBuilder: (BuildContext context, int index) {
                      return notification?['notificationWidgets'][
                          notification['notificationWidgets'].length -
                              index -
                              1];
                    })),

            Padding(
                padding: const EdgeInsets.all(0),
                child: Column(children: [
                  const AccountWidget(),
                  Expanded(
                      child: ListView(
                    children: [
                      ListTile(
                        title: const Text('Notification Settings'),
                        onTap: () {
                          navigatorKey.currentState
                              ?.pushNamed('/user_preferences_page');
                        },
                      ),
                      Divider(
                        color: Colors.grey[200],
                      ),
                      ListTile(
                        title: const Text('Set Thresholds'),
                        onTap: () {
                          navigatorKey.currentState?.pushNamed(
                            '/set_thresholds_page',
                            arguments: false,
                          );
                        },
                      ),
                      Divider(
                        color: Colors.grey[200],
                      ),
                      ListTile(
                        title: const Text('Change Device IDs'),
                        onTap: () async {
                          final userId = await Helper.getUserId();
                          navigatorKey.currentState?.pushNamed(
                            '/register_device_page',
                            arguments: userId,
                          );
                        },
                      ),
                      Divider(
                        color: Colors.grey[200],
                      ),
                      ListTile(
                        title: const Text('About'),
                        onTap: () {
                          // Navigate to about page
                        },
                      ),
                      Divider(
                        color: Colors.grey[200],
                      ),
                    ],
                  )),
                ]))
          ][currentPageIndex]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
