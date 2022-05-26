import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

ThemeData currentTheme = ThemeData(primarySwatch: Colors.blueGrey);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: currentTheme,
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
          // _currentColor = snapshot.data;
          currentTheme = snapshot.data;
        }
        return StyleAdjustmentWidget(
          themeData: ThemeData(
              primaryColor:
                  _currentColor != null ? _currentColor! : Colors.red),
          child: Builder(
            builder: (BuildContext innerContext) {
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
              );
            },
          ),
        );
      },
    );
  }
}

class StyleAdjustmentWidget extends InheritedWidget {
  StyleAdjustmentWidget(
      {Key? key, required this.child, required this.themeData})
      : super(key: key, child: child);

  final Widget child;
  final ThemeData themeData;
  // ThemeData themeData = ThemeData(primaryColor: color);

  static StyleAdjustmentWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StyleAdjustmentWidget>();
  }

  @override
  bool updateShouldNotify(StyleAdjustmentWidget oldWidget) {
    return true;
  }
}

class PageStyleCubit {
  final _themeColorStateController = StreamController<ThemeData>();

  Stream<ThemeData> get themeColorState => _themeColorStateController.stream;

  void themeColorEventHandler(MaterialColor color) {
    _themeColorStateController.add(ThemeData(primarySwatch: color));
    print('[PageStyleCubit themeColorEventHandler($color)]');
  }

  void dispose() {
    _themeColorStateController.close();
  }
}
