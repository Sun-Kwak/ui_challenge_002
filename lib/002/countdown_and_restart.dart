import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Main demo UI (countdown + restart button)
class CountdownAndRestart extends StatefulWidget {
  const CountdownAndRestart({super.key});

  @override
  CountdownAndRestartState createState() => CountdownAndRestartState();
}

class CountdownAndRestartState extends State<CountdownAndRestart> with SingleTickerProviderStateMixin{
  static const maxWidth = 300.0;
  late Ticker _ticker;
  late AnimationController _controller;
  int _countdown = 10;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((elapsed) {
      setState(() {
        _countdown = 10 - elapsed.inSeconds;
        if (_countdown <= 0) {
          _countdown = 0;
          _ticker.stop(); // Stop ticker when countdown reaches 0
        }
      });
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _countdown),
    );
    _controller.addListener(() {
      setState(() {});
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void startCountdown() {
    _ticker.stop();
    _ticker.start();
    _controller.reset();
    _controller.forward();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: maxWidth,
          height: maxWidth,
          child: CustomPaint(
            painter: CustomCounterPainter(
              countdown: _countdown,
              progress: _controller.value,
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            startCountdown();
          }, // TODO: Implement
          child: const Text(
            'Restart',
            style: TextStyle(fontSize: 32),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class CustomCounterPainter extends CustomPainter {
  final int countdown;
  final double progress;

  CustomCounterPainter({required this.countdown, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20.0
      ..style = PaintingStyle.stroke;

    Offset center = size.center(Offset.zero);
    final radius = size.width / 2 - paint.strokeWidth / 2;

    // Draw background circle
    paint.color = Colors.deepPurple.withOpacity(0.7);
    canvas.drawCircle(center, radius, paint);


    Rect rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 20.0
      ..style = PaintingStyle.stroke;

    // Draw progress arc
    //rect : 호의 경계
    //startAngle : 호의 시작 각도
    //sweepAngle : 호의 각도
    //useCenter : 호의 중심을 사용할지 여부 (중심점과 연결됨)
    //paint : 그리기에 사용할 Paint 객체
    canvas.drawArc(rect, math.pi/2*3, progress == 0 ? 0 : math.pi * 2-(progress * math.pi * 2), false, progressPaint);
    //

    // Draw countdown text
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '$countdown',
        style: const TextStyle(fontSize: 100.0, fontWeight: FontWeight.w500, color: Colors.deepPurple),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(CustomCounterPainter oldDelegate) {
    return true;
  }
}

