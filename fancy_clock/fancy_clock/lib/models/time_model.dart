import 'dart:async';

import 'package:flutter/material.dart';

///Time Model Provider which notifies its listeners when the time has changed
///When instantiated creates a [_timer] which update the [_current] DateTime reference every
///second and notifies the listeners
class TimeModel with ChangeNotifier {
  DateTime _current;
  Timer _timer;

  DateTime get current => _current;

  TimeModel() {
    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    _current = DateTime.now();

    _timer = Timer(
      Duration(seconds: 1) - Duration(milliseconds: _current.millisecond),
      _updateTime,
    );

    notifyListeners();
  }
}
