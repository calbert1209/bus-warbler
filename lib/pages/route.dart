import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/state/app_state.dart';

class RoutePage extends StatelessWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.route),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => appState.route = '',
        ),
      ),
      body: PageBody(),
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
      future: appState.queryAllForCurrentRoute(),
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
          return Center(
            child: ListView(
              children: [
                ...snapshot.data!.where(_isInTimeWindow).take(3).map(
                      (item) => StopTimeListItem(
                        key: Key(item.timeString),
                        item: item,
                      ),
                    ),
              ],
            ),
          );
        }
      },
    );
  }
}

class StopTimeListItem extends StatelessWidget {
  const StopTimeListItem({Key? key, required this.item}) : super(key: key);

  final ScheduleStop item;

  @override
  Widget build(BuildContext context) {
    final _fakeTime =
        kDebugMode && (DateTime.now().hour > 22 || DateTime.now().hour < 7);
    return Padding(
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
    );
  }
}
