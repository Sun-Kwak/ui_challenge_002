import 'package:flutter/material.dart';
import 'package:ui_challenge_002/004/dash_board.dart'; // intl 패키지 추가

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
