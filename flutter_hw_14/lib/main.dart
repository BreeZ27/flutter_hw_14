import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ThemeData currentTheme = ThemeData(primarySwatch: Colors.blueGrey);

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

class _MyHomePageState extends State<MyHomePage> {
  late final PageStyleCubit _pageStyleCubit;

  final Map<MaterialColor, String> colorsMap = {
    Colors.blueGrey: 'Серый',
    Colors.blue: 'Синий',
    Colors.green: 'Зелёный',
    Colors.deepPurple: 'Фиолетовый',
  };
  Color? _currentColor;

  @override
  void initState() {
    _currentColor = Colors.red;
    _pageStyleCubit = PageStyleCubit();
    super.initState();
  }

  @override
  void dispose() {
    _pageStyleCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: StyleAdjustmentWidget.of(innerContext)
                      .themeData
                      .appBarTheme
                      .backgroundColor,
                  title: Text(widget.title),
                ),
                body: Column(
                  children: [
                    Row(
                      children: [
                        CustomPaint(
                          painter: WeatherIconPainter(1),
                        ),
                      ],
                    ),
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
                            onPressed: () {},
                            icon: Icon(Icons.arrow_upward_rounded),
                            label: Text('Нашаманить'),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          ElevatedButton.icon(
                            style: StyleAdjustmentWidget.of(innerContext)
                                .themeData
                                .elevatedButtonTheme
                                .style,
                            onPressed: () {},
                            icon: Icon(Icons.arrow_downward_rounded),
                            label: Text('Раcшаманить'),
                          ),
                        ],
                      ),
                    )
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

  Stream<Color> get themeColorState => _themeColorStateController.stream;

  void themeColorEventHandler(Color color) {
    _themeColorStateController.add(color);
    print('[PageStyleCubit themeColorEventHandler($color)]');
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
    late double _sunOpacity;
    late double _cloudOpacity;
    late double _rainOpacity;

    if (rainProbability >= 0.5) {
      _rainOpacity = 1;
      _cloudOpacity = 1;
      if (rainProbability >= 0.8) {
        _sunOpacity = 0;
      } else {
        _sunOpacity = 0.75;
      }
    } else {
      _rainOpacity = 0;
      _sunOpacity = 1;
      if (rainProbability > 0.15) {
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
