import 'package:flutter/material.dart';
import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/widgets/current_time_display.dart';
import 'package:bus_warbler/widgets/stop_time_list_item.dart';
import 'package:bus_warbler/extensions/indexed_map.dart';

class StopTimeList extends StatelessWidget {
  const StopTimeList({Key? key, required this.stopTimes}) : super(key: key);

  final Iterable<ScheduleStop> stopTimes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CurrentTimeDisplay(),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: Colors.grey.shade500),
            ),
            child: Column(
              children: stopTimes.length > 0
                  ? [
                      ...stopTimes.indexedMap(
                        (item, index) => StopTimeListItem(
                          key: Key('$index-${item.timeString}'),
                          item: item,
                        ),
                      ),
                    ]
                  : [
                      NoStopsFoundMessage(),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}
