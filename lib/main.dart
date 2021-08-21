import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/pages/home_page.dart';
import 'package:bus_warbler/state/app_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Warbler',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: ChangeNotifierProvider<AppState>(
        create: (context) => AppState(),
        builder: (context, _) => HomePage(),
      ),
    );
  }
}
