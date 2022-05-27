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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

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
    // _currentColor = colorsMap.keys[0];

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
          // currentTheme = snapshot.data;
        }
        return StyleAdjustmentWidget(
          // themeData: ThemeData(
          //     primaryColor:
          //         _currentColor != null ? _currentColor! : Colors.red),
          buttonTheme: ButtonTheme(
            child: build(context),
          ),
          child: Builder(
            builder: (BuildContext innerContext) {
              // print(StyleAdjustmentWidget.of(context).themeData);
              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...colorsMap.keys.map(
                        (e) => ElevatedButton(
                          // style: StyleAdjustmentWidget.of(innerContext).themeData.elevatedButtonTheme,
                          // style: ButtonStyle(backgroundColor: ),
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
                      Container(
                        height: 100,
                        width: 100,
                        color: _currentColor,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('data'),
                        style: ElevatedButton.styleFrom(primary: _currentColor),
                      )
                    ],
                  ),
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
    // required this.themeData,
    required this.buttonTheme,
    Key? key,
  }) : super(key: key, child: child);

  final Widget child;
  // final ThemeData themeData;
  final ButtonTheme buttonTheme;
  // final Theme theme;
  // ThemeData themeData = ThemeData(primaryColor: color);

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
