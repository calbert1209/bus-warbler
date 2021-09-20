import 'package:bus_warbler/widgets/main_drawer.dart';
import 'package:bus_warbler/widgets/route_select_body.dart';
import 'package:flutter/material.dart';

final lightGrey = Colors.grey.shade700;
final textGreen = Colors.green.shade300;

class RouteSelectPage extends StatelessWidget {
  const RouteSelectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Pick a route',
          style: TextStyle(
            color: textGreen,
            fontFamily: 'MPlusRounded',
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            fontSize: 28.0,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: Colors.grey.shade900,
              size: 28,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: RouteSelectBody(),
      drawer: MainDrawer(),
      drawerEnableOpenDragGesture: false,
    );
  }
}
