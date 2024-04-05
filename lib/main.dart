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
  final animatedFlipBuilderKey = GlobalKey<_AnimatedFlipBuilderState>();

  void flip() {
    animatedFlipBuilderKey.currentState?.flip();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {},
      child: Transform(
        transform: Matrix4.identity()..setEntry(3, 2, 0.001),
        alignment: Alignment.center,
        child: AnimatedFlipBuilder(
          key: animatedFlipBuilderKey,
          frontWidget: widget.frontWidget,
          backWidget: widget.backWidget,
        ),
      ),
    );
  }
}

class AnimatedFlipBuilder extends StatefulWidget {
  final Widget frontWidget;
  final Widget backWidget;

  const AnimatedFlipBuilder(
      {required this.frontWidget, required this.backWidget, super.key});

  @override
  State<AnimatedFlipBuilder> createState() => _AnimatedFlipBuilderState();
}

class _AnimatedFlipBuilderState extends State<AnimatedFlipBuilder>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController _controller;
  double startAngle = 0;
  double dragAngle = 0;
  double endAngle = 1;
  bool isFrontVisible = true;
  double remainingAngle = 0;
  bool isFlip = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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

  double roundWithDecimalPlaces(double number, int decimalPlaces) {
    final multiplier = math.pow(10, decimalPlaces);
    return (number * multiplier).roundToDouble() / multiplier;
  }

  void flip() {
    setState(() {
      endAngle = 1;
      animation =
          Tween<double>(begin: startAngle, end: endAngle).animate(_controller);
      if (isFrontVisible) {
        _controller.forward().then((value) {
          // isFrontVisible = false;
          print('front');
        });
      } else {
        _controller.reverse().then((value) {
          // isFrontVisible = true;
          print('back');
        });
      }
    });
  }

  // bool showFront(){
  //   bool showFront = true;
  //   if(angle.abs() % 6 > 0.5){
  //     if (((angle.abs() - 0.5) ~/ 1) % 2 == 0) {
  //       showFront = isFrontVisible ? false : true;
  //     } else {
  //       showFront = isFrontVisible  ? true : false;
  //     }
  //   } else {
  //     showFront = isFrontVisible  ? true : false;
  //   }
  //   return showFront;
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        print('start : $dragAngle');
        print(animation.value);
        // _controller.reset();
      },
      onPanUpdate: (details) {
        setState(() {
          dragAngle += details.delta.dx / 150 / math.pi;
          // print('update : $dragAngle');
          // print(startAngle);
          // int roundedAngle = roundWithDecimalPlaces(startAngle, 0).toInt();
          // print(roundedAngle);
          // endAngel = startAngel - roundedAngle;
          // print(endAngel);
        });
        if (dragAngle.abs() % 6 > 0.5) {
          // print(angle.abs());
          if (((dragAngle.abs() - 0.5) ~/ 1) % 2 == 0) {
            endAngle = dragAngle - roundWithDecimalPlaces(dragAngle, 0);
          } else {
            endAngle = dragAngle - roundWithDecimalPlaces(dragAngle, 0);
          }
        } else {
          // print(angle.abs());
          endAngle = dragAngle - roundWithDecimalPlaces(dragAngle, 0);
        }
      },
      onPanEnd: (details) {
        setState(() {
          _controller.value = 0;
          animation = Tween<double>(begin: 0, end: endAngle)
              .animate(_controller);
          if (isFrontVisible) {
            _controller.forward().then((value) {
              dragAngle = 0;
              _controller.reset();
              print('1:$isFrontVisible : $dragAngle');
            });
          } else {
            _controller.forward().then((value) {
              dragAngle = 1;
              _controller.reset();
              print('2:$isFrontVisible : $dragAngle');
            });
          }
        });

      },
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double totalAngle = dragAngle - animation.value;

            bool showFront = totalAngle.abs() % 6 < 0.5
                ? ((totalAngle.abs() - 0.5) ~/ 1) % 2 == 0
                : totalAngle.abs() % 6 > 0.5
                    ? ((totalAngle.abs() - 0.5) ~/ 1) % 2 != 0
                    : totalAngle.abs() % 6 <= 0.5;
            isFrontVisible = showFront; // isFrontVisible 값 업데이트
            // print(animation.value);
            // print(totalAngle);
            // print(isFrontVisible);
            return Transform(
                alignment: Alignment.center,
                transform:
                    Matrix4.rotationY((dragAngle - animation.value) * math.pi),
                child: showFront
                    ? widget.frontWidget
                    : Transform(
                        transform: Matrix4.rotationY(math.pi),
                        alignment: Alignment.center,
                        child: widget.backWidget));
          }),
    );
  }
}
