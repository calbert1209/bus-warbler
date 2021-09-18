import 'package:bus_warbler/constants/db_consts.dart';

enum StopType { Weekday, Saturday, Holiday }

StopType parseStopType(String text) {
  if (text[0] == "平") {
    return StopType.Weekday;
  } else if (text[0] == "土") {
    return StopType.Saturday;
  } else if (text[0] == "休") {
    return StopType.Holiday;
  } else {
    throw ("could not parse: ${text.substring(0, 8)}...");
  }
}

class ScheduleStop {
  ScheduleStop({
    required this.hour,
    required this.minute,
    required this.note,
    required this.type,
  });

  final int hour;
  final int minute;
  final String? note;
  final StopType type;

  int get index => (hour * 60) + minute;
  String _doubleDigits(int i) => i < 10 ? '0' + i.toString() : i.toString();
  String get timeString => '${_doubleDigits(hour)}:${_doubleDigits(minute)}';

  String toString() {
    return {
      'index': index,
      'time': timeString,
      'note': note,
      'type': type.index,
    }.toString();
  }

  factory ScheduleStop.fromMap(Map<String, dynamic> map) {
    assert(
      DBConsts.hasStopKeys(map),
      "map should have keys needed to create stop",
    );
    return ScheduleStop(
      hour: map[DBConsts.hour],
      minute: map[DBConsts.minute],
      type: StopType.values[map[DBConsts.type]],
      note: map[DBConsts.note],
    );
  }
}
