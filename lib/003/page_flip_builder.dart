import 'dart:math' as math;
import 'package:flutter/material.dart';

class PageFlipBuilder extends StatefulWidget {
  final Widget frontWidget;
  final Widget backWidget;
  static const Duration animationDuration = Duration(milliseconds: 400);
  static const double dragSensitivity = 150.0;

  const PageFlipBuilder({
    super.key,
    required this.frontWidget,
    required this.backWidget,
  });

  @override
  PageFlipBuilderState createState() => PageFlipBuilderState();
}

class PageFlipBuilderState extends State<PageFlipBuilder>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController _controller;
  double currentAngle = 0;
  double endAngle = 1;
  bool isFrontVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PageFlipBuilder.animationDuration,
    );
    animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation(double endAngle, double finalDragAngle) {
    animation = Tween<double>(begin: 0, end: endAngle).animate(_controller);
    _controller.forward().then((value) {
      currentAngle = finalDragAngle;
      _controller.reset();
    });
  }

  double roundWithDecimalPlaces(double number, int decimalPlaces) {
    final multiplier = math.pow(10, decimalPlaces);
    return (number * multiplier).roundToDouble() / multiplier;
  }

  void flip() {
    if (!_controller.isAnimating) {
      setState(() {
        _controller.value = 0;
        if (isFrontVisible) {
          _startAnimation(1, 1);
        } else {
          _startAnimation(-1, 0);
        }
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_controller.isAnimating) {
      setState(() {
        currentAngle += details.delta.dx / 150 / math.pi;
      });
      endAngle = currentAngle - roundWithDecimalPlaces(currentAngle, 0);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_controller.isAnimating) {
      setState(() {
        _controller.value = 0;
        if (isFrontVisible) {
          _startAnimation(endAngle, 0);
        } else {
          _startAnimation(endAngle, 1);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double totalAngle = currentAngle - animation.value;
          bool showFront = totalAngle.abs() < 0.5 ||
              ((totalAngle.abs() - 0.5) ~/ 1) % 2 != 0;
          isFrontVisible = showFront;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY((currentAngle - animation.value) * math.pi),
            child: showFront
                ? widget.frontWidget
                : Transform(
              transform: Matrix4.rotationY(math.pi),
              alignment: Alignment.center,
              child: widget.backWidget,
            ),
          );
        },
      ),
    );
  }
}
