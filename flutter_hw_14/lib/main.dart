import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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
      upperBound: 2,
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
    print('_controller.value: ${_controller.value}');
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
                  return CustomPaint(
                    painter: WeatherIconPainter(rainStateNumber),
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
                      ],
                    ),
                    // Container(
                    //   child: BackdropFilter(
                    //     filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.black.withOpacity(0.1),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    AnimatedBuilder(
                      animation: _controller,
                      child: _animatedWeatherWidget,
                      builder: (BuildContext context, Widget? child) {
                        return Transform.scale(
                          scale: _controller.value,
                          child: child,
                        );
                      },
                    ),

                    // StreamBuilder(
                    //   stream: _pageStyleCubit.rainState,
                    //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                    //     if (snapshot.hasData) {
                    //       rainStateNumber = snapshot.data;
                    //     }
                    //     return CustomPaint(
                    //       painter: WeatherIconPainter(rainStateNumber),
                    //     );
                    //   },
                    // ),
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

  Stream<Color> get themeColorState => _themeColorStateController.stream;
  Stream<double> get rainState => _rainStateController.stream;

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
    print(rainProbability);

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
