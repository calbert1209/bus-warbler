import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/pages/route.dart';
import 'package:bus_warbler/pages/route_select.dart';
import 'package:bus_warbler/state/app_state.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    if (appState.route != '') {
      return RoutePage();
    } else {
      return RouteSelectPage();
    }
  }
}
