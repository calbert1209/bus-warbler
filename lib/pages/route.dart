import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/constants/db_consts.dart';
import 'package:bus_warbler/state/app_state.dart';
import 'package:bus_warbler/widgets/bottom_nav_text_bar.dart';
import 'package:bus_warbler/widgets/route_page_body.dart';

class RoutePage extends StatelessWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizedRouteNameFor(appState.route),
          style: TextStyle(
            color: Colors.green.shade300,
            fontFamily: 'MPlusRounded',
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
            fontSize: 28.0,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: 32,
          ),
          onPressed: () => appState.route = '',
          color: Colors.green.shade300,
        ),
        backgroundColor: Colors.grey.shade700,
      ),
      body: PageBody(),
      backgroundColor: Colors.grey.shade800,
      bottomNavigationBar: BottomNavTextBar(),
    );
  }
}
