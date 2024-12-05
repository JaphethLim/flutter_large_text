import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _text = "Your text here";
  String _textColorName = "Auto";
  String _backgroundColorName = "White";
  Color _textColor = Colors.black;
  Color _backgroundColor = Colors.white;
  int _textSizeAdjustment = 0;
  bool _editMode = false;
  bool _fullScreen = false;

  final _colorNames = ["Auto", "White", "Black", "Red", "Green", "Blue", "Purple", "Brown", "Yellow"];

  @override
  void initState() {
    super.initState();
    // set initial colors
    _changeTextColor(_textColorName);
    _changeBackgroundColor(_backgroundColorName);
  }

  Color _parseColor(String? color, Color otherColor) {
    if (color == "Auto") {
      return _autoColor(otherColor);
    } else if (color == "White") {
      return Colors.white;
    } else if (color == "Black") {
      return Colors.black;
    } else if (color == "Red") {
      return Colors.red;
    } else if (color == "Green") {
      return Colors.green;
    } else if (color == "Blue") {
      return Colors.blue;
    } else if (color == "Purple") {
      return Colors.purple;
    } else if (color == "Brown") {
      return Colors.brown;
    } else if (color == "Yellow") {
      return Colors.yellow;
    }
    // should never get here
    return Colors.black;
  }

  Color _autoColor(Color color) {
    // convert to hsv
    final hsv = HSVColor.fromColor(color);
    // shift hue a little bit
    final newHue = (hsv.hue - 30) % 360;
    // invert value
    final newValue = clampDouble((hsv.value > 0.5 ? hsv.value/4 : 1-(1-hsv.value)/4), 0.0, 1.0);
    // convert back to color
    return HSVColor.fromAHSV(1, newHue, hsv.saturation, newValue).toColor();
  }

  void _changeTextColor(String? color) {
    if (color == "Auto" && _backgroundColorName == "Auto") {
      return; // don't change both to auto
    }
    setState(() {
      _textColor = _parseColor(color, _backgroundColor);
      _textColorName = color!;
    });
    if (_backgroundColorName == "Auto") {
      setState(() {
        _backgroundColor = _autoColor(_textColor);
      });
    }
  }
  void _changeBackgroundColor(String? color) {
    if (color == "Auto" && _textColorName == "Auto") {
      return; // don't change both to auto
    }
    setState(() {
      _backgroundColor = _parseColor(color, _textColor);
      _backgroundColorName = color!;
    });
    if (_textColorName == "Auto") {
      setState(() {
        _textColor = _autoColor(_backgroundColor);
      });
    }
  }

  void _startEdit() {
    setState(() {
      _editMode = true;
      _endFullscreen(); // just in case
    });
  }
  void _endEdit() {
    setState(() {
      _editMode = false;
    });
  }
  void _toggleEdit() {
    if (_editMode) {
      _endEdit();
    } else {
      _startEdit();
    }
  }

  void _startFullscreen() {
    if (!_fullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
    setState(() {
      _fullScreen = true;
    });
  }
  void _endFullscreen() {
    if(_fullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    setState(() {
      _fullScreen = false;
    });
  }
  void _toggleFullscreen() {
    if (_fullScreen) {
      _endFullscreen();
    } else {
      _startFullscreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final dropdownItems = _colorNames.map((
        String color) {
      return DropdownMenuItem<String>(
        value: color,
        child: Text(color),
      );
    }).toList();

    final theme = Theme.of(context);
    var targetTextWidth = MediaQuery.sizeOf(context).width * 2 / max(1, _text.runes.length);
    var targetTextHeight = MediaQuery.sizeOf(context).height / 2;
    var fontSize = min(targetTextWidth, targetTextHeight);
    if (fontSize <= 0) {
      fontSize = theme.textTheme.displayLarge?.fontSize ?? 24;
    }
    final textStyle = theme.textTheme.displayLarge!.copyWith(
      color: _textColor,
      fontSize: fontSize * pow(1.1, _textSizeAdjustment),
    );

    Widget textWidget;
    if (_editMode) {
      textWidget = EditableText(
        onSubmitted: (text) {
          setState(() {
            _text = text;
          });
          _endEdit();
        },
        controller: TextEditingController(text: _text),
        style: textStyle,
        cursorColor: _textColor,
        backgroundCursorColor: _textColor,
        selectionColor: _backgroundColor,
        maxLines: null,
        expands: true,
        showCursor: true,
        focusNode: FocusNode(),
        textInputAction: TextInputAction.done,
      );
    } else {
      // wrap in clickable box
      textWidget = GestureDetector(
        onTap: () {
          _toggleFullscreen();
        },
        child: Text(
          _text,
          style: textStyle,
        ),
      );
    }

    Widget? editBar;
    if (!_fullScreen) {
      editBar = Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // color dropdowns
            DropdownButton(items: dropdownItems, onChanged: _changeTextColor, value: _textColorName),
            const Text(' on '),
            DropdownButton(items: dropdownItems, onChanged: _changeBackgroundColor, value: _backgroundColorName),
            const SizedBox(width: 5),
            // text size + and -
            FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _textSizeAdjustment += 1;
                });
              },
            ),
            FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  _textSizeAdjustment -= 1;
                });
              },
            ),
            // toggle edit
            if (!_editMode)
              FloatingActionButton(
                child: const Icon(Icons.edit),
                onPressed: () {
                  _toggleEdit();
                },
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        color: _backgroundColor,
        padding: const EdgeInsets.all(5),
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: textWidget,
                ),
              ),
              if (editBar != null) editBar,
            ],
          ),
        ),
      ),
    );
  }
}
