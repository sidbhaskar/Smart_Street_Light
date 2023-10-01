import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

//!       TEMPEARTURE GRAPH

class SecondGraph extends StatefulWidget {
  const SecondGraph({super.key});

  @override
  State<SecondGraph> createState() => _SecondGraphState();
}

class _SecondGraphState extends State<SecondGraph> {
  List<DataPoint> dataPoints = [];
  Timer? timer; // Declare a timer variable

  Future<Map<String, dynamic>> getDataFromFirebase() async {
    String url =
        "https://syncfusion-bc26a-default-rtdb.firebaseio.com/Street%20Light/Area%2001.json"; // Replace with your Firebase URL
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('Time') &&
          jsonResponse.containsKey('Temperature')) {
        final String time = jsonResponse['Time'].toString();
        final int temperature = jsonResponse['Temperature'] as int;
        return {
          'time': time,
          'temperature': temperature,
        };
      }
    }
    return {
      'time': '',
      'temperature': 0,
    }; // Return default values if data is missing or invalid
  }

  Future<void> loadDataPoints() async {
    final Map<String, dynamic> data = await getDataFromFirebase();

    setState(() {
      dataPoints.add(DataPoint(
        data['time'],
        data['temperatue'],
      ));
      if (dataPoints.length > 10) {
        dataPoints.removeAt(0); // Remove the oldest data point if more than 10
      }
    });
  }

  @override
  void initState() {
    // Set up a timer to refresh the data every second
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      loadDataPoints();
    });
    super.initState();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      // onChartTouchInteractionMove: (tapArgs) => dataPoints,

      title: ChartTitle(
        text: 'Temperature and Humidity Graph',
        alignment: ChartAlignment.near,
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      enableAxisAnimation: true,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          majorGridLines: const MajorGridLines(width: 0),
          // isVisible: false,
          // axisLine: AxisLine(color: Colors.black),
          minimum: 0,
          maximum: 110,
          interval: 20),
      series: <ChartSeries>[
        SplineAreaSeries<DataPoint, String>(
          markerSettings: const MarkerSettings(color: Colors.green),
          animationDuration: 100,
          dataSource: dataPoints,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(134, 236, 211, 1),
              Color.fromRGBO(134, 236, 211, 0)
            ],
          ),
          xValueMapper: (DataPoint data, _) => data.time,
          yValueMapper: (DataPoint data, _) => data.temperature,
        ),
      ],
    );
  }
}

class DataPoint {
  DataPoint(this.time, this.temperature);
  final String time;
  final int temperature;
}
