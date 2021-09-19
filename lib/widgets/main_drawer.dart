import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/constants/bus_routes.dart';
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

Future<void> _fetchAndParse(AppState appState) async {
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

class MainDrawer extends Drawer {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final lightGrey = Colors.grey.shade800;
    final textGreen = Colors.green.shade300;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings & Utilities',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(color: lightGrey),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(8.0),
            leading: Icon(
              Icons.replay_outlined,
              color: textGreen,
            ),
            title: Text(
              'load data',
              style: TextStyle(color: textGreen, fontSize: 24.0),
            ),
            onTap: () {
              _fetchAndParse(appState)
                  .whenComplete(() => Navigator.pop(context));
            },
          )
        ],
      ),
    );
  }
}
