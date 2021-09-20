import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/widgets/stop_time_list.dart';
import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/state/app_state.dart';

class PageBody extends StatelessWidget {
  const PageBody({Key? key}) : super(key: key);

  bool _isSelectedStopType(ScheduleStop stop, StopType current) {
    return stop.type == current;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    var now = DateTime.now();
    if (appState.debugMode) {
      now = now.add(Duration(hours: appState.debugOffset));
    }

    bool _isInTimeWindow(ScheduleStop stop) {
      final indexNow = (now.hour * 60) + now.minute;

      return stop.index > indexNow && stop.index <= (indexNow + 60);
    }

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
          return LinearProgressIndicator();
        } else {
          final inWindow = snapshot.data!
              .where((stop) => _isSelectedStopType(stop, appState.stopType))
              .where(_isInTimeWindow)
              .toList();
          inWindow.sort((a, b) => a.index.compareTo(b.index));
          final limited = inWindow.take(3);
          return StopTimeList(stopTimes: limited);
        }
      },
    );
  }
}
