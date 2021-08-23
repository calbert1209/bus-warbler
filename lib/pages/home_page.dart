import 'dart:convert';
import 'dart:io';

import 'package:bus_warbler/constants/bus_routes.dart';
import 'package:bus_warbler/models/parse_html_page.dart';
import 'package:bus_warbler/services/db.dart';
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

Future<List<ExtendedScheduleStop>> _fetchAll() async {
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
  return stops;
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  void _fetchAndParse(AppState appState) {
    if (appState.loading) {
      return;
    }

    appState.setLoading(true);

    _fetchAll().then((stops) {
      return appState.batchInsert(stops);
    }).whenComplete(() {
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
      body: PageBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appState.loading ? Colors.grey : Colors.green,
        onPressed: () => _fetchAndParse(appState),
        tooltip: 'Increment',
        child: Icon(Icons.replay_outlined),
      ),
    );
  }
}

class PageBody extends StatelessWidget {
  const PageBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return FutureBuilder(
      future: appState.queryAll(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error!.toString(),
            ),
          );
        } else if (!snapshot.hasData) {
          return Center(
            child: LinearProgressIndicator(
              minHeight: 20.0,
            ),
          );
        } else {
          print(snapshot.data!.toString());
          return Center(
            child: ListView(
              children: [
                ...snapshot.data!.map((item) {
                  final text = hasStopKeys(item)
                      ? '${item[DatabaseConstants.hour]} : ${item[DatabaseConstants.minute]}'
                      : 'no go bro!';
                  return Text(text);
                })
              ],
            ),
          );
        }
      },
    );
  }
}

bool hasStopKeys(Map<String, dynamic> item) {
  return [
    DatabaseConstants.mod,
    DatabaseConstants.hour,
    DatabaseConstants.minute,
    DatabaseConstants.type,
    DatabaseConstants.note,
  ].every((key) => item.containsKey(key));
}
