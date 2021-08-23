import 'package:bus_warbler/models/parse_html_page.dart';
import 'package:bus_warbler/services/db.dart';
import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  AppState(this._databaseService);

  final DatabaseService _databaseService;
  bool loading = false;
  String body = "";

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void setBody(String value) {
    body = value;
    notifyListeners();
  }

  Future<List<Object?>> batchInsert(Iterable<ExtendedScheduleStop> stops) {
    return _databaseService.batchInsert(stops);
  }

  Future<List<Map<String, dynamic>>> queryAll() {
    return _databaseService.queryAll(DatabaseConstants.kanaiOfuna);
  }
}
