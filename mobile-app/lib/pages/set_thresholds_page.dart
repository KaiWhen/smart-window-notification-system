import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:smart_windows_app/api/sw_api.dart';
import 'package:smart_windows_app/assets/constants.dart' as constants;
import 'package:smart_windows_app/main.dart';
import 'package:smart_windows_app/util/helper.dart';

class SetThresholdsPage extends StatefulWidget {
  const SetThresholdsPage({super.key});

  @override
  State<SetThresholdsPage> createState() => _SetThresholdsPageState();
}

class _SetThresholdsPageState extends State<SetThresholdsPage> {
  Map? thresholds = {};
  Map? results = {};
  List<double> temperatureRange = [
    constants.temperatureLowDefault,
    constants.temperatureHighDefault
  ];
  List<double> humidityRange = [
    constants.humidityLowDefault,
    constants.humidityHighDefault
  ];
  List<double> tvocRange = [0, constants.tvocHighDefault];
  List<double> eco2Range = [0, constants.eco2HighDefault];
  List<double> pm1_0Range = [0, constants.pm1_0HighDefault];
  List<double> pm2_5Range = [0, constants.pm2_5HighDefault];
  List<double> pm10Range = [0, constants.pm10HighDefault];

  @override
  void initState() {
    super.initState();
    getThresholds();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   getThresholds();
  // }

  Future<void> getThresholds() async {
    results = await SmartWindowApi().getDeviceThresholds();
    if (results!.entries.isNotEmpty && results != null) {
      setState(() {
        thresholds = results;
        temperatureRange = [
          thresholds?['Temperature']?[0].toDouble(),
          thresholds?['Temperature']?[1].toDouble()
        ];
        humidityRange = [
          thresholds?['Humidity']?[0].toDouble(),
          thresholds?['Humidity']?[1].toDouble()
        ];
        tvocRange = [
          thresholds?['TVOC']?[0].toDouble(),
          thresholds?['TVOC']?[1].toDouble()
        ];
        eco2Range = [
          thresholds?['eCO2']?[0].toDouble(),
          thresholds?['eCO2']?[1].toDouble()
        ];
        pm1_0Range = [
          thresholds?['PM1.0']?[0].toDouble(),
          thresholds?['PM1.0']?[1].toDouble()
        ];
        pm2_5Range = [
          thresholds?['PM2.5']?[0].toDouble(),
          thresholds?['PM2.5']?[1].toDouble()
        ];
        pm10Range = [
          thresholds?['PM10']?[0].toDouble(),
          thresholds?['PM10']?[1].toDouble()
        ];
      });
    }
  }

  final double? textFontSize = 16;
  final double? sliderTextSize = 13;
  final int lowerFlex = 2;
  final int upperFlex = 3;

  @override
  Widget build(BuildContext context) {
    final reg = ModalRoute.of(context)?.settings.arguments as bool?;

    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: !reg!,
            title: const Text("Set thresholds")),
        body: Container(
            margin: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                Text("Temperature (°C)",
                    style: TextStyle(
                      fontSize: textFontSize,
                    )),
                Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  Expanded(
                    flex: lowerFlex,
                    child: Text("  ${temperatureRange[0].round()}",
                        style: TextStyle(
                          fontSize: sliderTextSize,
                        )),
                  ),
                  Expanded(
                      flex: 27,
                      child: FlutterSlider(
                        step: const FlutterSliderStep(
                          step: 1,
                        ),
                        values: temperatureRange,
                        hatchMark: FlutterSliderHatchMark(
                          density: 0.3,
                          labelsDistanceFromTrackBar: 50,
                          displayLines: true,
                          labels: [
                            FlutterSliderHatchMarkLabel(
                                percent: 0, label: const Text('0')),
                            FlutterSliderHatchMarkLabel(
                                percent: 100,
                                label: Text(constants.temperatureMax
                                    .round()
                                    .toString())),
                          ],
                        ),
                        rangeSlider: true,
                        max: constants.temperatureMax,
                        min: 0,
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            temperatureRange[0] = lowerValue;
                            temperatureRange[1] = upperValue;
                          });
                        },
                      )),
                  Expanded(
                    flex: upperFlex,
                    child: Text(temperatureRange[1].round().toString(),
                        style: TextStyle(
                          fontSize: sliderTextSize,
                        )),
                  )
                ]),
                const SizedBox(
                  height: 8,
                ),
                Divider(
                  color: Colors.grey[200],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text("Humidity (%)",
                    style: TextStyle(
                      fontSize: textFontSize,
                    )),
                Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  Expanded(
                    flex: lowerFlex,
                    child: Text("  ${humidityRange[0].round()}",
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color:
                              (humidityRange[0] >= constants.humidityLowDefault)
                                  ? constants.green
                                  : constants.red,
                        )),
                  ),
                  Expanded(
                      flex: 27,
                      child: FlutterSlider(
                        step: const FlutterSliderStep(
                            step: 5, isPercentRange: true),
                        hatchMark: FlutterSliderHatchMark(
                          density: 0.3,
                          labelsDistanceFromTrackBar: 50,
                          displayLines: true,
                          labels: [
                            FlutterSliderHatchMarkLabel(
                                percent: 0, label: const Text('0')),
                            FlutterSliderHatchMarkLabel(
                                percent: 100,
                                label: Text(
                                    constants.humidityMax.round().toString())),
                          ],
                        ),
                        values: humidityRange,
                        rangeSlider: true,
                        max: constants.humidityMax,
                        min: 0,
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            humidityRange[0] = lowerValue;
                            humidityRange[1] = upperValue;
                          });
                        },
                      )),
                  Expanded(
                    flex: upperFlex,
                    child: Text(humidityRange[1].round().toString(),
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (humidityRange[1] <=
                                  constants.humidityHighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  )
                ]),
                const SizedBox(
                  height: 8,
                ),
                Divider(
                  color: Colors.grey[200],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text("TVOC (ppb)",
                    style: TextStyle(
                      fontSize: textFontSize,
                    )),
                Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  Expanded(
                    flex: lowerFlex,
                    child: Text("  ${tvocRange[0].round()}",
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (tvocRange[0] <= constants.tvocHighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  ),
                  Expanded(
                      flex: 27,
                      child: FlutterSlider(
                        step: const FlutterSliderStep(
                            step: 10, isPercentRange: true),
                        hatchMark: FlutterSliderHatchMark(
                          density: 0.3,
                          labelsDistanceFromTrackBar: 50,
                          displayLines: true,
                          labels: [
                            FlutterSliderHatchMarkLabel(
                                percent: 0, label: const Text('0')),
                            FlutterSliderHatchMarkLabel(
                                percent: 100,
                                label:
                                    Text(constants.tvocMax.round().toString())),
                          ],
                        ),
                        values: tvocRange,
                        rangeSlider: true,
                        max: constants.tvocMax,
                        min: 0,
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            tvocRange[0] = lowerValue;
                            tvocRange[1] = upperValue;
                          });
                        },
                      )),
                  Expanded(
                    flex: upperFlex,
                    child: Text(tvocRange[1].round().toString(),
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (tvocRange[1] <= constants.tvocHighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  )
                ]),
                const SizedBox(
                  height: 8,
                ),
                Divider(
                  color: Colors.grey[200],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text("eCO2 (ppm)",
                    style: TextStyle(
                      fontSize: textFontSize,
                    )),
                Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  Expanded(
                    flex: lowerFlex,
                    child: Text("  ${eco2Range[0].round()}",
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (eco2Range[0] <= constants.eco2HighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  ),
                  Expanded(
                      flex: 27,
                      child: FlutterSlider(
                        step: const FlutterSliderStep(
                            step: 100, isPercentRange: true),
                        hatchMark: FlutterSliderHatchMark(
                          density: 0.3,
                          labelsDistanceFromTrackBar: 50,
                          displayLines: true,
                          labels: [
                            FlutterSliderHatchMarkLabel(
                                percent: 0, label: const Text('0')),
                            FlutterSliderHatchMarkLabel(
                                percent: 100,
                                label:
                                    Text(constants.eco2Max.round().toString())),
                          ],
                        ),
                        values: eco2Range,
                        rangeSlider: true,
                        max: constants.eco2Max,
                        min: 0,
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            eco2Range[0] = lowerValue;
                            eco2Range[1] = upperValue;
                          });
                        },
                      )),
                  Expanded(
                    flex: upperFlex,
                    child: Text(eco2Range[1].round().toString(),
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (eco2Range[1] <= constants.eco2HighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  )
                ]),
                const SizedBox(
                  height: 8,
                ),
                Divider(
                  color: Colors.grey[200],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text("PM1.0 (μg/m\u00B3)",
                    style: TextStyle(
                      fontSize: textFontSize,
                    )),
                Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  Expanded(
                    flex: lowerFlex,
                    child: Text(" ${pm1_0Range[0].round()}",
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (pm1_0Range[0] <= constants.pm1_0HighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  ),
                  Expanded(
                      flex: 27,
                      child: FlutterSlider(
                        step: const FlutterSliderStep(
                            step: 1, isPercentRange: true),
                        hatchMark: FlutterSliderHatchMark(
                          density: 0.3,
                          labelsDistanceFromTrackBar: 50,
                          displayLines: true,
                          labels: [
                            FlutterSliderHatchMarkLabel(
                                percent: 0, label: const Text('0')),
                            FlutterSliderHatchMarkLabel(
                                percent: 100,
                                label: Text(
                                    constants.pm1_0Max.round().toString())),
                          ],
                        ),
                        values: pm1_0Range,
                        rangeSlider: true,
                        max: constants.pm1_0Max,
                        min: 0,
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            pm1_0Range[0] = lowerValue;
                            pm1_0Range[1] = upperValue;
                          });
                        },
                      )),
                  Expanded(
                    flex: upperFlex,
                    child: Text(pm1_0Range[1].round().toString(),
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (pm1_0Range[1] <= constants.pm1_0HighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  )
                ]),
                const SizedBox(
                  height: 8,
                ),
                Divider(
                  color: Colors.grey[200],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text("PM2.5 (μg/m\u00B3)",
                    style: TextStyle(
                      fontSize: textFontSize,
                    )),
                Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  Expanded(
                    flex: lowerFlex,
                    child: Text(" ${pm2_5Range[0].round()}",
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (pm2_5Range[0] <= constants.pm2_5HighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  ),
                  Expanded(
                      flex: 27,
                      child: FlutterSlider(
                        step: const FlutterSliderStep(
                            step: 5, isPercentRange: true),
                        hatchMark: FlutterSliderHatchMark(
                          density: 0.3,
                          labelsDistanceFromTrackBar: 50,
                          displayLines: true,
                          labels: [
                            FlutterSliderHatchMarkLabel(
                                percent: 0, label: const Text('0')),
                            FlutterSliderHatchMarkLabel(
                                percent: 100,
                                label: Text(
                                    constants.pm2_5Max.round().toString())),
                          ],
                        ),
                        values: pm2_5Range,
                        rangeSlider: true,
                        max: constants.pm2_5Max,
                        min: 0,
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            pm2_5Range[0] = lowerValue;
                            pm2_5Range[1] = upperValue;
                          });
                        },
                      )),
                  Expanded(
                    flex: upperFlex,
                    child: Text(pm2_5Range[1].round().toString(),
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (pm2_5Range[1] <= constants.pm2_5HighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  )
                ]),
                const SizedBox(
                  height: 8,
                ),
                Divider(
                  color: Colors.grey[200],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text("PM10 (μg/m\u00B3)",
                    style: TextStyle(
                      fontSize: textFontSize,
                    )),
                Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  Expanded(
                    flex: lowerFlex,
                    child: Text(" ${pm10Range[0].round()}",
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (pm10Range[0] <= constants.pm10HighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  ),
                  Expanded(
                      flex: 27,
                      child: FlutterSlider(
                        step: const FlutterSliderStep(
                            step: 10, isPercentRange: true),
                        hatchMark: FlutterSliderHatchMark(
                          density: 0.3,
                          labelsDistanceFromTrackBar: 50,
                          displayLines: true,
                          labels: [
                            FlutterSliderHatchMarkLabel(
                                percent: 0, label: const Text('0')),
                            FlutterSliderHatchMarkLabel(
                                percent: 100,
                                label:
                                    Text(constants.pm10Max.round().toString())),
                          ],
                        ),
                        values: pm10Range,
                        rangeSlider: true,
                        max: constants.pm10Max,
                        min: 0,
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          setState(() {
                            pm10Range[0] = lowerValue;
                            pm10Range[1] = upperValue;
                          });
                        },
                      )),
                  Expanded(
                    flex: upperFlex,
                    child: Text(pm10Range[1].round().toString(),
                        style: TextStyle(
                          fontSize: sliderTextSize,
                          color: (pm10Range[1] <= constants.pm10HighDefault)
                              ? constants.green
                              : constants.red,
                        )),
                  )
                ]),
                const SizedBox(height: 10),
                Container(
                    alignment: Alignment.bottomCenter,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Submit'),
                      onPressed: () async {
                        if (!reg) {
                          bool? isOwner = await SmartWindowApi().isOwner();
                          if (!isOwner!) {
                            Helper.showToast(
                                "Only the owner can set thresholds");
                            return;
                          }
                        }
                        String? userId = await Helper.getUserId();
                        final thresholds = {
                          'user_id': userId,
                          'thresholds': [
                            {
                              'sensor_type': "Temperature",
                              'lower_thresh': temperatureRange[0].round(),
                              'upper_thresh': temperatureRange[1].round()
                            },
                            {
                              'sensor_type': "Humidity",
                              'lower_thresh': humidityRange[0].round(),
                              'upper_thresh': humidityRange[1].round()
                            },
                            {
                              'sensor_type': "TVOC",
                              'lower_thresh': tvocRange[0].round(),
                              'upper_thresh': tvocRange[1].round()
                            },
                            {
                              'sensor_type': "eCO2",
                              'lower_thresh': eco2Range[0].round(),
                              'upper_thresh': eco2Range[1].round()
                            },
                            {
                              'sensor_type': "PM1.0",
                              'lower_thresh': pm1_0Range[0].round(),
                              'upper_thresh': pm1_0Range[1].round()
                            },
                            {
                              'sensor_type': "PM2.5",
                              'lower_thresh': pm2_5Range[0].round(),
                              'upper_thresh': pm2_5Range[1].round()
                            },
                            {
                              'sensor_type': "PM10",
                              'lower_thresh': pm10Range[0].round(),
                              'upper_thresh': pm10Range[1].round()
                            },
                          ]
                        };
                        bool success = await SmartWindowApi()
                            .postThresholds(userId, thresholds);
                        if (success && reg) {
                          navigatorKey.currentState?.pushNamed('/');
                        } else if (success && !reg) {
                          navigatorKey.currentState?.pop();
                        } else if (!success && reg) {
                          navigatorKey.currentState?.pushNamed('/login_page');
                          Helper.showMessage(
                              "Error setting thresholds, please try again later.");
                        } else {
                          Helper.showToast(
                              "Error setting thresholds, please try again later");
                        }
                      },
                    )),
              ],
            )));
  }
}
