import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_windows_app/assets/constants.dart' as constants;
import 'package:smart_windows_app/presentation/resources/app_resources.dart';

class LineChartWidget extends StatefulWidget {
  final List? readings;
  final List? outdoorReadings;
  final String sensorType;
  final String? readingTime;

  const LineChartWidget({
    Key? key,
    required this.readings,
    required this.outdoorReadings,
    required this.sensorType,
    this.readingTime,
  }) : super(key: key);

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<Color> gradientColors = [
    constants.dlrBlue,
    constants.dlrBlue,
  ];

  String sensorType = "";
  List<FlSpot> indoorSpots = [];
  List<FlSpot> outdoorSpots = [];
  double maxY = 0;
  double minY = 99999;
  int minYElement = 0;
  int maxYElement = 0;
  int midYElement = 0;
  int minYElementOutdoor = 0;
  int maxYElementOutdoor = 0;
  int midYElementOutdoor = 0;
  int notifX = 0;

  bool loading = true;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    sensorType = widget.sensorType;
    // timer = Timer.periodic(
    //   const Duration(seconds: 5),
    //   (timer) {
    //     if (widget.readings!.isNotEmpty) {
    //       makeSpots();
    //     }
    //   },
    // );
    // dev.log("${widget.readings}");
  }

  @override
  void didUpdateWidget(LineChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    makeSpots();
  }

  void makeSpots() {
    if (widget.readings != null && widget.readings!.isNotEmpty) {
      loading = true;
      int i = 0;

      List<double> indoorValues = [];

      setState(() {
        indoorSpots = [];
        outdoorSpots = [];
        maxY = 0;
        minY = 99999;
        minYElement = 0;
        maxYElement = 0;
        midYElement = 0;
        for (Map reading in widget.readings!) {
          indoorValues.add(reading['reading_value']);
          indoorSpots.add(
              FlSpot(reading['count'].toDouble(), reading['reading_value']));
          if (reading['reading_value'] > maxY) {
            maxY = reading['reading_value'];
            maxYElement = i;
          }
          if (reading['reading_value'] < minY) {
            minY = reading['reading_value'];
            minYElement = i;
          }
          if (widget.readingTime != null) {
            if (widget.readingTime == reading['reading_time']) {
              notifX = i;
            }
          }

          i++;
        }
      });
    }
    if (widget.outdoorReadings != null && widget.outdoorReadings!.isNotEmpty) {
      setState(() {
        List<double> outdoorValues = [];
        int k = 0;
        for (Map reading in widget.outdoorReadings!) {
          outdoorValues.add(reading['reading_value']);
          outdoorSpots.add(
              FlSpot(reading['count'].toDouble(), reading['reading_value']));
          if (reading['reading_value'] > maxY) {
            maxY = reading['reading_value'];
            maxYElementOutdoor = k;
          }
          if (reading['reading_value'] < minY) {
            minY = reading['reading_value'];
            minYElementOutdoor = k;
          }

          k++;
        }
      });
    }

    // double midDiff = double.infinity;
    // double midValue = minY + ((maxY - minY) / 2);
    // int j = 0;
    // double indoorAvg = indoorValues.average;
    // double outdoorAvg = outdoorValues.average;
    // for (Map reading in (indoorAvg >= outdoorAvg
    //     ? widget.readings!
    //     : widget.outdoorReadings!)) {
    //   double tempMidDiff =
    //       min(midDiff, (reading['reading_value'] - midValue).abs());
    //   if (tempMidDiff < midDiff) {
    //     setState(() {
    //       midYElement = j;
    //     });
    //     midDiff = tempMidDiff;
    //   }
    //   j++;
    // }
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Align(
        alignment: const Alignment(-0.8, 0),
        child: Text(
          sensorType,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      // (widget.readings != null && widget.readings!.isNotEmpty && !loading) ||
      //         (widget.outdoorReadings != null &&
      //             widget.outdoorReadings!.isNotEmpty &&
      //             !loading) ?
      Container(
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            color: constants.bgColour,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.01),
                blurRadius: 1,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.70,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 18,
                    left: 12,
                    top: 24,
                    bottom: 12,
                  ),
                  child: LineChart(
                    mainData(),
                  ),
                ),
              ),
            ],
          ))
    ]);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    text = Container();

    if (widget.readings!.isNotEmpty) {
      if (value.toInt() == 0) {
        text = Text("${widget.readings?[0]['reading_time']}", style: style);
      } else if (value.toInt() == widget.readings!.length ~/ 3) {
        text = Text(
            "${widget.readings?[widget.readings!.length ~/ 3]['reading_time']}",
            style: style);
      } else if (value.toInt() == widget.readings!.length ~/ 1.5) {
        text = Text(
            "${widget.readings?[widget.readings!.length ~/ 1.5]['reading_time']}",
            style: style);
      } else if (value.toInt() == widget.readings!.length - 1) {
        text = Text(
            "${widget.readings?[widget.readings!.length - 1]['reading_time']}",
            style: style);
      }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    if (widget.readings != null &&
        widget.outdoorReadings != null &&
        value == (minY - 1).round().toDouble() &&
        minY.toInt() != 0) {
      text = "${minY.toInt()}";
    } else if (widget.readings != null &&
        widget.outdoorReadings != null &&
        value.toInt() == (minY + ((maxY - minY) / 2)).round()) {
      text = "${value.toInt()}";
    } else if (widget.readings != null &&
        widget.outdoorReadings != null &&
        value == (maxY + 1).round().toDouble()) {
      text = "${value.toInt()}";
    } else {
      return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    final lineChartData = [
      LineChartBarData(
        spots: (indoorSpots.isNotEmpty && widget.readings!.isNotEmpty)
            ? indoorSpots
            : const [FlSpot(-50, -50)],
        isCurved: false,
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: false,
          gradient: LinearGradient(
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ),
      LineChartBarData(
        spots: (outdoorSpots.isNotEmpty && widget.outdoorReadings!.isNotEmpty)
            ? outdoorSpots
            : const [FlSpot(-50, -50)],
        isCurved: false,
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 112, 34),
            Color.fromARGB(255, 0, 112, 34)
          ],
        ),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: false,
          gradient: LinearGradient(
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ),
    ];
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      // showingTooltipIndicators: [ShowingTooltipIndicators(LineBarSpot(bar, barIndex, spot))],
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // reservedSize: widget.readings != null
            //     ? (widget.readings!.length - 1).toDouble()
            //     : 1,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: widget.readings != null
          ? widget.readings!.length.toDouble() - 1
          : 1, //range of x data
      minY: (minY - 1).toDouble(),
      maxY: (maxY + 1).round().toDouble(), //range of y data
      lineBarsData: lineChartData,
      lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: const Color.fromARGB(255, 94, 114, 230),
            tooltipRoundedRadius: 20.0,
            showOnTopOfTheChartBoxArea: false,
            fitInsideHorizontally: true,
            tooltipMargin: 10,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map(
                (LineBarSpot touchedSpot) {
                  const textStyle = TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  );
                  String tooltipText;
                  if (touchedSpot.barIndex == 0) {
                    tooltipText = indoorSpots.isNotEmpty
                        ? indoorSpots[touchedSpot.spotIndex]
                            .y
                            .toStringAsFixed(2)
                        : "";
                  } else {
                    tooltipText = outdoorSpots.isNotEmpty
                        ? outdoorSpots[touchedSpot.spotIndex]
                            .y
                            .toStringAsFixed(2)
                        : "";
                  }
                  return LineTooltipItem(
                    tooltipText,
                    textStyle,
                  );
                },
              ).toList();
            },
          ),
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> indicators) {
            return indicators.map(
              (int index) {
                const line = FlLine(
                    color: Colors.grey, strokeWidth: 1, dashArray: [2, 4]);
                return const TouchedSpotIndicatorData(
                  line,
                  FlDotData(show: false),
                );
              },
            ).toList();
          },
          getTouchLineEnd: (_, __) => double.infinity),
      extraLinesData: ExtraLinesData(
        verticalLines: [
          VerticalLine(
            x: (widget.readingTime != null) ? notifX.toDouble() : -50,
            strokeWidth: 1,
            color: Colors.red[400],
            dashArray: [2, 4],
          ),
        ],
      ),
    );
  }
}
