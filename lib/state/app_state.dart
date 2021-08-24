import 'dart:async';

import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/models/serial_html.dart';
import 'package:bus_warbler/services/db.dart';
import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  AppState(this._databaseService);

  final DatabaseService _databaseService;
  bool _loading = false;
  bool _hasStops = false;
  String body = "";
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

  void setBody(String value) {
    body = value;
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
}
