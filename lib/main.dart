import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

Future<void> preloadSVGs() async {
  final svgList = [
    'assets/forest-day.svg',
    'assets/forest-night.svg',
    'assets/man.svg',
  ];
  for (final asset in svgList) {
    final loader = SvgAssetLoader(asset);
    await svg.cache.putIfAbsent(
      loader.cacheKey(null),
          () => loader.loadBytes(null),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await preloadSVGs();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16.0),
          // Use Center as layout has unconstrained width (loose constraints),
          // together with SizedBox to specify the max width (tight constraints)
          // See this thread for more info:
          // https://twitter.com/biz84/status/1445400059894542337
          child: Center(
            child: SizedBox(
              width: 500, // max allowed width
              child: HomePage(),
            ),
          ),
        ),
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

class PageFlipBuilder extends StatefulWidget {
  final Widget frontWidget;
  final Widget backWidget;

  const PageFlipBuilder({
    super.key,
    required this.frontWidget,
    required this.backWidget,
  });

  @override
  PageFlipBuilderState createState() => PageFlipBuilderState();
}

class PageFlipBuilderState extends State<PageFlipBuilder>
    with TickerProviderStateMixin {
  final flipDuration = const Duration(milliseconds: 500);
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _animationController2;
  late Animation<double> _animation2;
  bool _isFrontVisible = true;
  double angle = 0;

  final animatedFlipBuilderKey = GlobalKey<_AnimatedFlipBuilderState>();

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: flipDuration);

    _animationController2 =
        AnimationController(vsync: this, duration: flipDuration);
    _animation = Tween<double>(begin: 0, end: 0.5).animate(_animationController)
      ..addListener(() {
        setState(() {
          if (_animationController.isCompleted ||
              _animationController.isDismissed) {
            animatedFlipBuilderKey.currentState?.changeSide();
          }
        });
      });
    _animation2 =
    Tween<double>(begin: 0, end: 0.5).animate(_animationController2)
      ..addListener(() {
        setState(() {
          // if(_animationController2.isCompleted || _animationController2.isDismissed){
          //   if(animatedFlipBuilderKey.currentState?.isFrontVisible == true){
          //
          //   }
          // }
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController2.dispose();
    super.dispose();
  }

  void flip() {
    if (animatedFlipBuilderKey.currentState?.isFrontVisible == true) {
      // _animationController.reset();
      _animationController
          .forward()
          .then((value) => _animationController2.forward());
    } else {
      // _animationController.reset();
      _animationController
          .reverse()
          .then((value) => _animationController2.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY((_animation.value + _animation2.value) * math.pi),
      alignment: Alignment.center,
      child: AnimatedFlipBuilder(
        key: animatedFlipBuilderKey,
        frontWidget: widget.frontWidget,
        backWidget: widget.backWidget,
      ),
    );
  }
}

class AnimatedFlipBuilder extends StatefulWidget {
  final Widget frontWidget;
  final Widget backWidget;
  // final double angle;

  const AnimatedFlipBuilder({
    // required this.angle,
    required this.frontWidget,
    required this.backWidget,
    super.key});

  @override
  State<AnimatedFlipBuilder> createState() => _AnimatedFlipBuilderState();
}

class _AnimatedFlipBuilderState extends State<AnimatedFlipBuilder>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController _controller;
  double angle= 0;
  bool isRotated = false;
  bool isFrontVisible = true;
  double remainingAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {

        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double roundWithDecimalPlaces(double number, int decimalPlaces) {
    final multiplier = math.pow(10, decimalPlaces);
    return (number * multiplier).roundToDouble() / multiplier;
  }

  void changeSide() {
    isFrontVisible = !isFrontVisible;
    // print(isFrontVisible);
  }

  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onPanStart: (details) {
        _controller.reset();

        // remainingAngle = 0;
        if(isFrontVisible){
          angle = 0;
          // isRotated = true;
        } else {
          angle = math.pi;
          // isRotated = false;
        }
      },
      onPanUpdate: (details) {
        setState(() {
          print(animation.value);
          angle += details.delta.dx / 150 / math.pi;
          int roundedAngle = roundWithDecimalPlaces(angle, 0).toInt();
          remainingAngle = angle - roundedAngle;

        });
        if(angle.abs() % 6 > 0.5){
          if (((angle.abs() - 0.5) ~/ 1) % 2 == 0) {
            isFrontVisible = false;
          } else {
            isFrontVisible = true;
          }
        } else {
          isFrontVisible = true;
        }

      },
      onPanEnd: (details) {


        _controller.forward();
        // angle = angle + (roundedAngel - angle) / animation.value == 0 ? 1 : animation.value;
      },
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY((angle - (remainingAngle) * animation.value) * math.pi),
              child: isFrontVisible
                  ? RotatedFlip(
                isRotated: isRotated,
                child: widget.frontWidget,
              )
                  : RotatedFlip(
                isRotated: !isRotated,
                child: widget.backWidget,
              ),
            );
          }),
    );
  }
}

class RotatedFlip extends StatelessWidget {
  final bool isRotated;
  final Widget child;

  const RotatedFlip({required this.child, required this.isRotated, super.key});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.rotationY(isRotated ? math.pi : 0),
      alignment: Alignment.center,
      child: child,
    );
  }
}