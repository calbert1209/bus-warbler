import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/constants/db_consts.dart';
import 'package:bus_warbler/state/app_state.dart';

class RouteSelectBody extends StatelessWidget {
  const RouteSelectBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return ListView(
      children: [
        ...DBConsts.tableNames.map((name) {
          return Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
            child: ElevatedButton(
              onPressed: () => appState.route = name,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  localizedRouteNameFor(name),
                  style: TextStyle(
                    fontFamily: 'MPlusRounded',
                    fontSize: 32.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
