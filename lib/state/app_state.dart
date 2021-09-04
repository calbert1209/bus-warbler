import 'dart:async';

import 'package:bus_warbler/constants/db_consts.dart';
import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/models/serial_html.dart';
import 'package:bus_warbler/services/db.dart';
import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  AppState(this._databaseService);

  final DatabaseService _databaseService;
  bool _loading = false;
  bool _hasStops = false;
  String _route = ''; //DBConsts.kanaiTotsuka;
  Map<String, Iterable<ScheduleStop>> _stopCache = {};

  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool get hasStops => _hasStops;
  set hasStops(bool value) {
    _hasStops = value;
    notifyListeners();
  }

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
    // if (!_stopCache.containsKey(tableName) || _stopCache[tableName] == null) {
    //   final results = await _databaseService.queryAll(tableName);
    //   _stopCache[tableName] = results;
    // }

    // // _stopCache[tableName] could never be null
    // return Future.value(_stopCache[tableName]!);
  }
}
