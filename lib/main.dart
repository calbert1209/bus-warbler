import 'package:bus_warbler/services/db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/pages/home.dart';
import 'package:bus_warbler/state/app_state.dart';

final lightGrey = Colors.grey.shade700;
final darkGrey = Colors.grey.shade800;
final textGreen = Colors.green.shade300;

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
        primarySwatch: Colors.green,
        canvasColor: darkGrey,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith(
              (states) => lightGrey,
            ),
            foregroundColor: MaterialStateProperty.resolveWith(
              (states) => textGreen,
            ),
            elevation: MaterialStateProperty.resolveWith((states) => 1.0),
          ),
        ),
        textTheme: TextTheme(
          button: TextStyle(color: textGreen),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: lightGrey,
          elevation: 1.0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<AppState>(
        create: (context) => AppState(dbService),
        builder: (context, _) => HomePage(),
      ),
    );
  }
}
