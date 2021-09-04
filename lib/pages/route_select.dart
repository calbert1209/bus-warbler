import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/constants/bus_routes.dart';
import 'package:bus_warbler/constants/db_consts.dart';
import 'package:bus_warbler/models/serial_html.dart';
import 'package:bus_warbler/state/app_state.dart';

Future<String> _fetchRoutePage(BusRouteUrlParts urlParts) async {
  final url = Uri.https(
    "www.kanachu.co.jp",
    "/dia/diagram/send",
    urlParts.toMap(),
  );
  final client = HttpClient();
  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
  final request = await client.getUrl(url);
  HttpClientResponse response = await request.close();
  return response.transform(utf8.decoder).join();
}

Future<List<ExtendedScheduleStop>> _fetchAll() async {
  var stops = <ExtendedScheduleStop>[];
  for (var entry in busRoutes.entries) {
    final route = entry.value;

    for (var part in route.parts) {
      final resp = await _fetchRoutePage(part);
      final someStops = SerialHtml(resp).stops();
      stops.addAll(someStops);
    }
  }
  print("Done: ${stops.length}stops");
  return stops;
}

void _fetchAndParse(AppState appState) async {
  if (appState.loading) {
    return;
  }

  if (appState.hasStops) {
    return;
  }

  appState.loading = true;

  try {
    final stops = await _fetchAll();
    await appState.batchInsert(stops);
  } finally {
    appState.loading = false;
    appState.hasStops = true;
  }
}

class RouteSelectPage extends StatelessWidget {
  const RouteSelectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final lightGrey = Colors.grey.shade600;
    final darkGrey = Colors.grey.shade700;
    final foregroundGreen = Colors.lightGreen.shade300;
    return Scaffold(
      backgroundColor: darkGrey,
      appBar: AppBar(
        backgroundColor: lightGrey,
        title: Text('Pick a route',
            style: TextStyle(
              color: foregroundGreen,
            )),
      ),
      body: ListView(
        children: [
          ...DBConsts.tableNames.map((name) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  print('$name pressed');
                  appState.route = name;
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.resolveWith((states) => 0.5),
                  padding: MaterialStateProperty.resolveWith(
                      (states) => EdgeInsets.all(16.0)),
                  backgroundColor:
                      MaterialStateColor.resolveWith((states) => lightGrey),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: foregroundGreen,
                    fontSize: 32.0,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2.0,
        backgroundColor: appState.loading ? Colors.grey : foregroundGreen,
        onPressed: () => _fetchAndParse(appState),
        child: Icon(
          Icons.replay_outlined,
          color: darkGrey,
        ),
      ),
    );
  }
}
