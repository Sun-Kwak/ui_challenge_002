import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui_challenge_002/main.dart';

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
