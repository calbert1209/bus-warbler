import 'dart:convert';
import 'dart:io';

import 'package:bus_warbler/constants/bus_routes.dart';
import 'package:bus_warbler/constants/db_consts.dart';
import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/models/serial_html.dart';
import 'package:bus_warbler/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      appState.setBody(DateTime.now().toIso8601String());
      appState.loading = false;
      appState.hasStops = true;
    }
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
    return FutureBuilder<Iterable<ScheduleStop>>(
      future: appState.queryAll(DBConsts.kanaiOfuna),
      builder: (context, snapshot) {
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
                ...snapshot.data!
                    .where(
                      (item) => item.index > 9 * 60 && item.index <= 10 * 60,
                    )
                    .take(3)
                    .map(
                      (item) => Card(
                        child: Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: Flexible(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '${item.timeString}',
                                style: TextStyle(
                                  fontSize: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
              ],
            ),
          );
        }
      },
    );
  }
}
