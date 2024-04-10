import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        currentAngle -= details.delta.dx / 150 / math.pi;
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


class HomePage extends StatelessWidget {
  HomePage({Key? key});

  final pageFlipBuilderKey = GlobalKey<PageFlipBuilderState>();

  @override
  Widget build(BuildContext context) {
    // TODO: Create PageFlipBuilder widget that can be used to flip between
    // LightHomePage and DarkHomePage
    return PageFlipBuilder(
      key: pageFlipBuilderKey,
      frontWidget: LightHomePage(onFlip: () {
        pageFlipBuilderKey.currentState?.flip();
      }),
      backWidget: DarkHomePage(onFlip: () {
        pageFlipBuilderKey.currentState?.flip();
      }),
    );
  }
}

class LightHomePage extends StatelessWidget {
  const LightHomePage({Key? key, this.onFlip});

  final VoidCallback? onFlip;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
        textTheme: TextTheme(
          displaySmall: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 5),
          ),
          child: Column(
            children: [
              const ProfileHeader(prompt: 'Hello,\nsunshine!'),
              const Spacer(),
              SvgPicture.asset(
                'assets/forest-day.svg',
                semanticsLabel: 'Forest',
                width: 300,
                height: 300,
              ),
              const Spacer(),
              BottomFlipIconButton(onFlip: onFlip),
            ],
          ),
        ),
      ),
    );
  }
}

class DarkHomePage extends StatelessWidget {
  const DarkHomePage({Key? key, this.onFlip});

  final VoidCallback? onFlip;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          brightness: Brightness.dark,
          textTheme: TextTheme(
            displaySmall: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          )),
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 5),
          ),
          child: Column(
            children: [
              const ProfileHeader(prompt: 'Good night,\nsleep tight!'),
              const Spacer(),
              SvgPicture.asset(
                'assets/forest-night.svg',
                semanticsLabel: 'Forest',
                width: 300,
                height: 300,
              ),
              const Spacer(),
              BottomFlipIconButton(onFlip: onFlip),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key, required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Row(
        children: [
          Text(prompt, style: Theme.of(context).textTheme.displaySmall!),
          const Spacer(),
          SvgPicture.asset(
            'assets/man.svg',
            semanticsLabel: 'Profile',
            width: 50,
            height: 50,
          ),
        ],
      ),
    );
  }
}

class BottomFlipIconButton extends StatelessWidget {
  const BottomFlipIconButton({Key? key, this.onFlip});

  final VoidCallback? onFlip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onFlip,
          icon: const Icon(Icons.flip),
        )
      ],
    );
  }
}

