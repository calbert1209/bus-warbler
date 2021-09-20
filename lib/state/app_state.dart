import 'dart:async';

import 'package:bus_warbler/constants/db_consts.dart';
import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/models/serial_html.dart';
import 'package:bus_warbler/services/db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

StopType currentDateToStopType([int? dayOfWeek]) {
  final weekday = dayOfWeek ?? DateTime.now().weekday;
  if (weekday == DateTime.sunday) {
    return StopType.Holiday;
  } else if (weekday == DateTime.saturday) {
    return StopType.Saturday;
  } else {
    return StopType.Weekday;
  }
}

class AppState with ChangeNotifier {
  AppState(this._databaseService);

  final DatabaseService _databaseService;
  Map<String, Iterable<ScheduleStop>> _stopCache = {};

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _hasStops = false;
  bool get hasStops => _hasStops;
  set hasStops(bool value) {
    _hasStops = value;
    notifyListeners();
  }

  bool get debugMode => kDebugMode;

  int _debugOffset = 0;
  int get debugOffset => _debugOffset;
  set debugOffset(int value) {
    _debugOffset = value;
    notifyListeners();
  }

  String _route = '';
  String get route => _route;

  /// Sets route to [value] of type [String] or [null].
  ///
  /// (!) Will throw assertion error if [value] is not constant value from [DBConsts]
  set route(String value) {
    if (value != '') {
      DBConsts.assertTableName(value);
    }

    _route = value;
    notifyListeners();
  }

  StopType _stopType = currentDateToStopType();
  StopType get stopType => _stopType;
  set stopType(StopType value) {
    _stopType = value;
    print('stop type set to ${value.index}');
    notifyListeners();
  }

  Future<List<Object?>> batchInsert(Iterable<ExtendedScheduleStop> stops) {
    return _databaseService.batchInsert(stops);
  }

  Future<Iterable<ScheduleStop>> queryAll(String tableName) async {
    if (!_stopCache.containsKey(tableName) || _stopCache[tableName] == null) {
      final results = await _databaseService.queryAll(tableName);
      _stopCache[tableName] = results;
    }

    // _stopCache[tableName] could never be null
    return Future.value(_stopCache[tableName]!);
  }

  Future<Iterable<ScheduleStop>> queryAllForCurrentRoute() async {
    assert(this._route != '', '_route should not be an empty string');

    return this.queryAll(this._route);
  }
}
