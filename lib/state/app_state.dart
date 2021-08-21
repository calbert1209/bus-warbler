import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  AppState();

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
}
