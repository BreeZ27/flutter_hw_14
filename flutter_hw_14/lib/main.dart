import 'dart:async';
import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

double rainStateNumber = 0;

enum RainStateEvent { increment, decrement }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final PageStyleCubit _pageStyleCubit;

  late AnimationController _controller;

  final Map<MaterialColor, String> colorsMap = {
    Colors.blueGrey: 'Серый',
    Colors.blue: 'Синий',
    Colors.green: 'Зелёный',
    Colors.deepPurple: 'Фиолетовый',
  };
  Color? _currentColor;

  @override
  void initState() {
    _controller = AnimationController(
      lowerBound: 1,
      upperBound: 1.5,
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _currentColor = Colors.red;
    _pageStyleCubit = PageStyleCubit();
    super.initState();
  }

  @override
  void dispose() {
    _pageStyleCubit.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('_controller.value: ${_controller.value}');
    return StreamBuilder(
      stream: _pageStyleCubit.themeColorState,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _currentColor = snapshot.data;
        }

        return StyleAdjustmentWidget(
          themeData: ThemeData(
            primaryColor: _currentColor != null ? _currentColor! : Colors.red,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(_currentColor!),
              ),
            ),
            appBarTheme: AppBarTheme(backgroundColor: _currentColor),
          ),
          child: Builder(
            builder: (BuildContext innerContext) {
              //
              Widget _animatedWeatherWidget = StreamBuilder(
                stream: _pageStyleCubit.rainState,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    rainStateNumber = snapshot.data;
                  }
                  _controller.addListener(() {
                    _pageStyleCubit.textOpacityValueHandler(_controller.value);
                  });

                  return GestureDetector(
                    onTap: () {
                      if (_controller.value == 1) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                    },
                    child: SizedBox(
                      height: 155,
                      width: 100,
                      child: Column(
                        children: [
                          CustomPaint(
                              size: Size(100, 120),
                              painter: WeatherIconPainter(rainStateNumber)),
                          StreamBuilder(
                            stream: _pageStyleCubit.textOpacityState,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              double _opacity = 0;
                              if (snapshot.hasData) {
                                // print('[snapshot.data: ${snapshot.data}]');
                                _opacity = snapshot.data;
                              }
                              return Opacity(
                                opacity: _opacity,
                                child: Text('Облачно 15°С'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              return Scaffold(
                appBar: AppBar(
                  backgroundColor: StyleAdjustmentWidget.of(innerContext)
                      .themeData
                      .appBarTheme
                      .backgroundColor,
                  title: Text(widget.title),
                ),
                body: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...colorsMap.keys.map(
                                (e) => ElevatedButton(
                                  style: StyleAdjustmentWidget.of(innerContext)
                                      .themeData
                                      .elevatedButtonTheme
                                      .style,
                                  onPressed: () {
                                    if (e == _currentColor) {
                                      _pageStyleCubit
                                          .themeColorEventHandler(Colors.red);
                                    } else {
                                      _pageStyleCubit.themeColorEventHandler(e);
                                    }
                                  },
                                  child: Text('${colorsMap[e]}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                style: StyleAdjustmentWidget.of(innerContext)
                                    .themeData
                                    .elevatedButtonTheme
                                    .style,
                                onPressed: () {
                                  _pageStyleCubit.rainEventHandler(
                                      RainStateEvent.increment);
                                },
                                icon: const Icon(Icons.arrow_upward_rounded),
                                label: const Text('Нашаманить'),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              ElevatedButton.icon(
                                style: StyleAdjustmentWidget.of(innerContext)
                                    .themeData
                                    .elevatedButtonTheme
                                    .style,
                                onPressed: () {
                                  _pageStyleCubit.rainEventHandler(
                                      RainStateEvent.decrement);
                                },
                                icon: Icon(Icons.arrow_downward_rounded),
                                label: Text('Раcшаманить'),
                              ),
                            ],
                          ),
                        ),
                        MyCustomText(
                          child: Container(
                            width: 350,
                            height: 110,
                            decoration: BoxDecoration(
                              color: _currentColor!.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Text(
                                'Make data',
                                style: TextStyle(
                                  letterSpacing: -12,
                                  fontFamily: 'Helvetica',
                                  fontSize: 90,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          blur: 5,
                          color: _currentColor!,
                        ),
                      ],
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      child: _animatedWeatherWidget,
                      builder: (BuildContext context, Widget? child) {
                        return Transform.scale(
                          origin: const Offset(-60, -70),
                          scale: _controller.value,
                          child: child,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class StyleAdjustmentWidget extends InheritedWidget {
  const StyleAdjustmentWidget({
    required this.child,
    required this.themeData,
    Key? key,
  }) : super(key: key, child: child);

  final Widget child;
  final ThemeData themeData;

  static StyleAdjustmentWidget of(BuildContext context) {
    final _res =
        context.dependOnInheritedWidgetOfExactType<StyleAdjustmentWidget>();
    assert(_res != null, '[No _res]');
    return _res!;
  }

  @override
  bool updateShouldNotify(StyleAdjustmentWidget oldWidget) {
    return true;
  }
}

class PageStyleCubit {
  final _themeColorStateController = StreamController<Color>();
  final _rainStateController = StreamController<double>();
  final _textOpacityController = StreamController<double>();

  Stream<Color> get themeColorState => _themeColorStateController.stream;
  Stream<double> get rainState => _rainStateController.stream;
  Stream<double> get textOpacityState => _textOpacityController.stream;

  void textOpacityValueHandler(double value) {
    _textOpacityController.add(value - 1);
    print('[PageStyleCubit textOpacityValueHandler($value)]');
  }

  void themeColorEventHandler(Color color) {
    _themeColorStateController.add(color);
    print('[PageStyleCubit themeColorEventHandler($color)]');
  }

  void rainEventHandler(RainStateEvent event) {
    if (event == RainStateEvent.increment) {
      if (rainStateNumber < 1) {
        _rainStateController.add(rainStateNumber + 0.1);
      }
    } else {
      if (rainStateNumber > 0) {
        _rainStateController.add(rainStateNumber - 0.1);
      }
    }
  }

  void dispose() {
    _themeColorStateController.close();
  }
}

class WeatherIconPainter extends CustomPainter {
  final double rainProbability;
  WeatherIconPainter(this.rainProbability);

  @override
  void paint(Canvas canvas, Size size) {
    double _sunOpacity = 1;
    double _cloudOpacity = 1;
    double _rainOpacity = 1;
    // print(rainProbability);

    if (rainProbability >= 0.5) {
      _rainOpacity = 1;
      _cloudOpacity = 1;
      if (rainProbability >= 0.85) {
        _sunOpacity = 0;
      } else {
        _sunOpacity = 1.5 - rainProbability;
      }
    } else {
      _rainOpacity = 0;
      _sunOpacity = 1;
      if (rainProbability > 0.15) {
        _cloudOpacity = 2 * rainProbability;
      } else {
        _cloudOpacity = 0;
      }
    }

    final sunPainter = Paint()
      ..color = Colors.amberAccent.withOpacity(_sunOpacity)
      ..style = PaintingStyle.fill;

    final cloudPainter = Paint()
      ..color = Colors.grey.withOpacity(_cloudOpacity)
      ..style = PaintingStyle.fill;

    final rainPainter = Paint()
      ..color = Colors.blue.withOpacity(_rainOpacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(50, 50), 30, sunPainter);

    canvas.drawLine(Offset(70, 20), Offset(50, 10), cloudPainter);

    var cloud = Path()
      ..moveTo(10, 100)
      ..addOval(Rect.fromLTWH(20, 50, 30, 30))
      ..addOval(Rect.fromLTWH(40, 40, 40, 40))
      ..addOval(Rect.fromLTWH(10, 60, 30, 30))
      ..addOval(Rect.fromLTWH(60, 60, 30, 30))
      ..addRect(Rect.fromLTWH(25, 60, 50, 30))
      ..close();

    canvas.drawPath(cloud, cloudPainter);

    var droplet1 = Path()
      ..addOval(Rect.fromCircle(center: Offset(25, 110), radius: 4))
      ..close();

    canvas.drawPath(droplet1, rainPainter);

    var droplet2 = Path()
      ..addOval(Rect.fromCircle(center: Offset(70, 105), radius: 4))
      ..close();

    canvas.drawPath(droplet2, rainPainter);

    var droplet3 = Path()
      ..addOval(Rect.fromCircle(center: Offset(40, 100), radius: 4))
      ..close();

    canvas.drawPath(droplet3, rainPainter);

    var droplet4 = Path()
      ..addOval(Rect.fromCircle(center: Offset(55, 115), radius: 4))
      ..close();

    canvas.drawPath(droplet4, rainPainter);
  }

  @override
  bool shouldRepaint(WeatherIconPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(WeatherIconPainter oldDelegate) => false;
}

class MyCustomText extends SingleChildRenderObjectWidget {
  const MyCustomText({
    Key? key,
    this.blur = 10,
    this.color = Colors.black38,
    this.offset = const Offset(10, 10),
    required Widget child,
  }) : super(key: key, child: child);

  final double blur;
  final Color color;
  final Offset offset;

  @override
  RenderMyText createRenderObject(BuildContext context) {
    print('[MyCustomText createRenderObject()]');
    final RenderMyText renderObject =
        RenderMyText(blur, color, offset.dx, offset.dy);
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, RenderMyText renderObject) {
    print('[MyCustomText updateRenderObject()]');
    renderObject
      ..color = color
      ..blur = blur
      ..dx = offset.dx
      ..dy = offset.dy;
  }
}

class RenderMyText extends RenderProxyBox {
  double blur;
  Color color;
  double dx;
  double dy;

  RenderMyText(this.blur, this.color, this.dx, this.dy, {RenderBox? child})
      : super(child);

  @override
  void paint(PaintingContext context, Offset offset) {
    print('[RenderMyText paint]');
    if (child == null) {
      return;
    }
    final Rect rectOuter = offset & size;
    final Rect rectInner = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width - dx,
      size.width - dy,
    );
    final Canvas canvas = context.canvas..saveLayer(rectOuter, Paint());

    context.paintChild(child!, offset);

    final Paint shadowPaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur)
      ..colorFilter = ColorFilter.mode(color, BlendMode.srcOut);

    canvas
      ..saveLayer(rectOuter, shadowPaint)
      ..saveLayer(rectInner, Paint())
      ..translate(dx, dy);
    context.paintChild(child!, offset);
    context.canvas
      ..restore()
      ..restore()
      ..restore();
  }
}
