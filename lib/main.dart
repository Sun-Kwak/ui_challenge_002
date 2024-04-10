import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // intl 패키지 추가

/// A type representing the various available data points
enum DataPoint {
  casesTotal('Total Cases', 'assets/count.png', Color(0xFFFFF492)),
  casesActive('Active Cases', 'assets/fever.png', Color(0xFFE99600)),
  deaths('Deaths', 'assets/death.png', Color(0xFFE40000)),
  recovered('Recovered', 'assets/patient.png', Color(0xFF70A901));

  const DataPoint(this.name, this.assetPath, this.color);
  final String name;
  final String assetPath;
  final Color color;
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('COVID-19 Tracker'),
        ),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          // Use Center as layout has unconstrained width (loose constraints),
          // together with SizedBox to specify the max width (tight constraints)
          // See this thread for more info:
          // https://twitter.com/biz84/status/1445400059894542337
          child: Center(
            child: SizedBox(
              width: 500, // max allowed width
              child: Dashboard(),
            ),
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Some random values
    final values = [
      9231249,
      123214,
      51245,
      7452340,
    ];
    // TODO: Implement UI
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          children: DataPoint.values
              .map(
                (dataPoint) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: DataCard(
                dataPoint: dataPoint,
                value: values[DataPoint.values.indexOf(dataPoint)],
              ),
            ),
          ).toList(),
        ),
      ),
    );
  }
}

class DataCard extends StatelessWidget {
  final DataPoint dataPoint;
  final int value;

  const DataCard({required this.dataPoint, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0'); // 숫자 포맷터 생성
    final formattedValue = formatter.format(value); // 값 포맷팅

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color(0xFF25232A),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dataPoint.name, style: TextStyle(color: dataPoint.color,fontSize: 25)),
                Image.asset(dataPoint.assetPath,color: dataPoint.color,),
              ],
            ),
            Text(formattedValue, style: TextStyle(color: dataPoint.color,fontSize: 26)),
          ],
        ),
      ),
    );
  }
}
