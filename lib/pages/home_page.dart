import 'dart:convert';
import 'dart:io';

import 'package:bus_warbler/constants/bus_routes.dart';
import 'package:bus_warbler/constants/db_consts.dart';
import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/models/serial_html.dart';
import 'package:bus_warbler/state/app_state.dart';
import 'package:flutter/foundation.dart';
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
      final someStops = SerialHtml(resp).stops();
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

  bool _isInTimeWindow(ScheduleStop stop) {
    var now = DateTime.now();
    if (now.hour > 22) {
      now = now.subtract(Duration(hours: 12));
    } else if (now.hour < 7) {
      now = now.add(Duration(hours: 10));
    }

    final indexNow = (now.hour * 60) + now.minute;

    return stop.index > indexNow && stop.index <= (indexNow + 60);
  }

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
          final _fakeTime = kDebugMode &&
              (DateTime.now().hour > 22 || DateTime.now().hour < 7);
          return Center(
            child: ListView(
              children: [
                ...snapshot.data!.where(_isInTimeWindow).take(3).map(
                      (item) => Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  '${_fakeTime ? '▵' : ''}${item.timeString}',
                                  style: TextStyle(
                                    fontSize: 48,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
