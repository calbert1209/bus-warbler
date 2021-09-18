import 'package:bus_warbler/widgets/bottom_nav_text_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/state/app_state.dart';
import 'package:bus_warbler/extensions/indexed_map.dart';

class RoutePage extends StatelessWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final lightGrey = Colors.grey.shade600;
    final darkGrey = Colors.grey.shade700;
    final foregroundGreen = Colors.lightGreen.shade300;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appState.route,
          style: TextStyle(
            color: foregroundGreen,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => appState.route = '',
          color: foregroundGreen,
        ),
        backgroundColor: lightGrey,
      ),
      body: PageBody(),
      backgroundColor: darkGrey,
      bottomNavigationBar: BottomNavTextBar(),
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

  bool _isSelectedStopType(ScheduleStop stop, StopType current) {
    return stop.type == current;
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
          return LinearProgressIndicator();
        } else {
          print('${DateTime.now()}-":::: elements :::::}');
          final limited = snapshot.data!
              .where((stop) => _isSelectedStopType(stop, appState.stopType))
              .where(_isInTimeWindow)
              .take(5);
          limited.forEach((element) => print(element));
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.grey.shade600),
                ),
                child: Column(
                  children: [
                    ...snapshot.data!
                        .where((stop) =>
                            _isSelectedStopType(stop, appState.stopType))
                        .where(_isInTimeWindow)
                        .take(5)
                        .map((element) {
                      // print(element);
                      return element;
                    }).indexedMap(
                      (item, index) => StopTimeListItem(
                        key: Key('$index-${item.timeString}'),
                        item: item,
                      ),
                    ),
                  ],
                ),
              ),
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
                  color: Colors.lightGreen.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
