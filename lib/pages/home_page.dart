import 'dart:convert';
import 'dart:io';

import 'package:bus_warbler/constants/bus_routes.dart';
import 'package:bus_warbler/models/parse_html_page.dart';
import 'package:bus_warbler/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<String> _fetchRoutePage(BusRouteUrlParts urlParts) async {
// https://www.kanachu.co.jp/dia/diagram/send?cs=0000800324-12&nid=00126844&chk=all&dts=1613761200
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

Future<void> _fetchAll() async {
  var stops = <ExtendedScheduleStop>[];
  for (var entry in busRoutes.entries) {
    final route = entry.value;

    for (var part in route.parts) {
      final resp = await _fetchRoutePage(part);
      print(route.nickname);
      final someStops = SerialHtml(resp).stops();
      print(someStops.length);
      stops.addAll(someStops);
    }
  }
  print("Done: ${stops.length}stops");
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  void _fetchAndParse(AppState appState) {
    if (appState.loading) {
      return;
    }

    appState.setLoading(true);

    _fetchAll().whenComplete(() {
      appState.setBody(DateTime.now().toIso8601String());
      appState.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Pre-MVP: Scrape Schedule Data'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            if (appState.loading)
              LinearProgressIndicator(
                minHeight: 20.0,
              ),
            Text(appState.body)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appState.loading ? Colors.grey : Colors.green,
        onPressed: () => _fetchAndParse(appState),
        tooltip: 'Increment',
        child: Icon(Icons.replay_outlined),
      ),
    );
  }
}
