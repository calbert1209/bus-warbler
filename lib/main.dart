import 'package:bus_warbler/services/db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/pages/home_page.dart';
import 'package:bus_warbler/state/app_state.dart';

void main() {
  final dbService = DatabaseService();
  runApp(App(dbService));
}

class App extends StatelessWidget {
  App(this.dbService);

  final DatabaseService dbService;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Warbler',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: ChangeNotifierProvider<AppState>(
        create: (context) => AppState(dbService),
        builder: (context, _) => HomePage(),
      ),
    );
  }
}
