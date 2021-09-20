import 'package:flutter/material.dart';
import 'package:bus_warbler/models/schedule_stop.dart';

class StopTimeListItem extends StatelessWidget {
  const StopTimeListItem({Key? key, required this.item}) : super(key: key);

  final ScheduleStop item;

  @override
  Widget build(BuildContext context) {
    final noteText = item.note == null ? '' : ' (${item.note})';
    return Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            flex: 1,
            child: Center(
              child: Row(
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Text(
                    item.timeString,
                    style: TextStyle(
                      fontFamily: 'MPlusRounded',
                      letterSpacing: -3.0,
                      fontWeight: FontWeight.w500,
                      fontSize: 48,
                      color: Colors.green.shade300,
                    ),
                  ),
                  Text(
                    noteText,
                    style: TextStyle(
                      fontFamily: 'MPlusRounded',
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: Colors.green.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoStopsFoundMessage extends StatelessWidget {
  const NoStopsFoundMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            flex: 1,
            child: Center(
              child: Row(
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Text(
                    'No stops found...',
                    style: TextStyle(
                      fontFamily: 'MPlusRounded',
                      letterSpacing: -1.0,
                      fontWeight: FontWeight.w300,
                      fontSize: 28,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
