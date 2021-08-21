import 'dart:convert';
import 'dart:io';

import 'package:bus_warbler/models/parse_html_page.dart';
import 'package:flutter/material.dart';

import 'constants/bus_routes.dart';

void main() {
  runApp(MyApp());
}

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loading = false;
  String _body = "";

  void _incrementCounter() {
    if (_loading) {
      return;
    }
    setState(() {
      _loading = true;
    });

    _fetchAll().whenComplete(() => setState(() {
          _body = DateTime.now().toIso8601String();
          _loading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            if (_loading)
              LinearProgressIndicator(
                minHeight: 20.0,
              ),
            Text(_body)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _loading ? Colors.grey : Colors.green,
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.replay_outlined),
      ),
    );
  }
}
