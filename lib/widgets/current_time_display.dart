import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/state/app_state.dart';

class CurrentTimeDisplay extends StatefulWidget {
  const CurrentTimeDisplay({Key? key}) : super(key: key);

  @override
  _CurrentTimeDisplayState createState() => _CurrentTimeDisplayState();
}

class _CurrentTimeDisplayState extends State<CurrentTimeDisplay> {
  _CurrentTimeDisplayState() {
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  // ignore: unused_field
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _doubleDigits(int i) => i < 10 ? '0' + i.toString() : i.toString();
    final appState = Provider.of<AppState>(context);
    var now = _currentTime;
    String prefix = '';
    if (appState.debugOffset != 0) {
      now = now.add(Duration(hours: appState.debugOffset));
      prefix = '▴';
    }

    print('${prefix}${now.hour}');
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
      child: Text(
        '${prefix}${_doubleDigits(now.hour)}:${_doubleDigits(now.minute)}',
        style: TextStyle(
          color: Colors.grey.shade300,
          fontFamily: 'MPlusRounded',
          fontSize: 48.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
