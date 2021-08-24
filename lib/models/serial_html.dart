import 'package:bus_warbler/constants/db_consts.dart';
import 'package:bus_warbler/models/schedule_stop.dart';

class SerialHtml {
  SerialHtml(this._html);

  final String _html;

  _PageSchedules sections() {
    final trimmed = _html.split("<pre>")[1].split("</pre>")[0];
    final sections = trimmed.split("■");
    return _PageSchedules.fromList(sections);
  }

  Iterable<ExtendedScheduleStop> stops() {
    final trimmed = _html.split("<pre>")[1].split("</pre>")[0];
    final sections = trimmed.split("■");
    final schedules = _PageSchedules.fromList(sections);
    return schedules.stops.map((stop) => ExtendedScheduleStop(
          header: schedules.header,
          stop: stop,
        ));
  }
}

class _PageSchedules {
  _PageSchedules._({
    required this.header,
    required this.stops,
  });

  factory _PageSchedules.fromList(List<String> list) {
    if (list.length <= 3) {
      throw ("list must have length > 3");
    }

    final weekday = _ScheduleLines.fromSection(list[1]).toStops();
    final saturday = _ScheduleLines.fromSection(list[2]).toStops();
    final holiday = _ScheduleLines.fromSection(list[3]).toStops();

    return _PageSchedules._(
        header: _PageHeader.parse(list[0]),
        stops: [...weekday, ...saturday, ...holiday]);
  }

  final _PageHeader header;
  final List<ScheduleStop> stops;
}

enum Route {
  kanaiTotsuka,
  totsukaKanai,
  kanaiOfuna,
  ofunaKanai,
}

String _tryToRomanizeRoutePoint(String text) {
  if (text.contains('金井')) {
    return 'kanai';
  } else if (text.contains('戸塚')) {
    return 'totsuka';
  } else if (text.contains('大船')) {
    return 'ofuna';
  } else {
    throw RangeError('"$text" out of range');
  }
}

Route routeFromPoints(String start, String destination) {
  final romanStart = _tryToRomanizeRoutePoint(start);
  final romanDest = _tryToRomanizeRoutePoint(destination);
  final routeString = '${romanStart}_$romanDest';
  switch (routeString) {
    case 'kanai_totsuka':
      return Route.kanaiTotsuka;
    case 'totsuka_ofuna':
      return Route.totsukaKanai;
    case 'totsuka_totsuka':
      // 戸塚バスセンター -> 戸塚台循環
      return start.contains('バスセンター') ? Route.totsukaKanai : Route.kanaiTotsuka;
    case 'kanai_ofuna':
      return Route.kanaiOfuna;
    case 'ofuna_totsuka':
      return Route.ofunaKanai;
    default:
      throw RangeError('$start -> $destination not valid as Route');
  }
}

class _PageHeader {
  _PageHeader._({
    required this.name,
    required this.destination,
    required this.route,
    required this.publishDate,
    required this.fetchDate,
  });

  final String name;
  final String destination;
  final Route route;
  final DateTime publishDate;
  final DateTime fetchDate;

  static String _firstMatchFirstGroup(String pattern, String haystack) =>
      RegExp(pattern).firstMatch(haystack)!.group(1)!;

  factory _PageHeader.parse(String text) {
    final name = _firstMatchFirstGroup(r"^ﾊﾞｽ停名：(.*)", text);
    final dest = _firstMatchFirstGroup(r"行先：(.*)\n", text);
    final publish =
        _firstMatchFirstGroup(r"改正日：([\d\/]*)", text).replaceAll(r"/", "-");
    final publishDate = DateTime.parse(publish);
    return _PageHeader._(
      name: name,
      destination: dest,
      route: routeFromPoints(name, dest),
      publishDate: publishDate,
      fetchDate: DateTime.now(),
    );
  }
}

class _ScheduleLine {
  _ScheduleLine._(this.hour, this.minutes);

  final int hour;
  final List<_ScheduleMinute> minutes;

  factory _ScheduleLine.fromLine(String line) {
    final split = line.split("時 ");
    final hour = int.parse(split[0]);
    final minutes =
        split[1].split(" . ").map((text) => _ScheduleMinute.parse(text));
    return _ScheduleLine._(hour, [...minutes]);
  }

  Iterable<ScheduleStop> toStops(StopType type) {
    return minutes.map((minute) => ScheduleStop(
          hour: hour,
          minute: minute.value,
          note: minute.note,
          type: type,
        ));
  }
}

class _ScheduleMinute {
  _ScheduleMinute._(this.value, this.note);

  final int value;
  final String? note;

  factory _ScheduleMinute.parse(String dirty) {
    final delimiter = ",";
    final split =
        dirty.replaceAll(RegExp(r"[\(\)]"), delimiter).split(delimiter);
    final note = split.length > 1 ? split[1] : null;
    return _ScheduleMinute._(int.parse(split[0]), note);
  }
}

class _ScheduleLines {
  _ScheduleLines._(this.type, this.lines);

  final StopType type;
  final List<_ScheduleLine> lines;

  factory _ScheduleLines.fromSection(String section) {
    final hasMatch =
        (String pattern, String haystack) => RegExp(pattern).hasMatch(haystack);
    final split = section.split("\n");
    var lines = <_ScheduleLine>[];
    var last = "";
    for (var i = split.length - 2; i >= 0; i--) {
      final line = split[i];

      // some lines are empty
      if (!hasMatch(r"^\d", line)) {
        continue;
      }

      // some lines have an hour but no stops
      if (hasMatch(r"^\d+時\s$", line)) {
        continue;
      }

      // Most lines have minutes. Just in case, we'll include any orphans.
      if (hasMatch(r"^\d+時\s", line)) {
        lines.add(_ScheduleLine.fromLine("$line $last"));
      } else {
        last = line;
      }
    }
    return _ScheduleLines._(
      parseStopType(split[0]),
      [...lines.reversed],
    );
  }

  List<ScheduleStop> toStops() {
    List<ScheduleStop> stops = [];
    for (var line in lines) {
      stops.addAll(line.toStops(type));
    }

    return stops;
  }
}

class ExtendedScheduleStop {
  ExtendedScheduleStop({
    required this.header,
    required this.stop,
  });

  final _PageHeader header;
  final ScheduleStop stop;

  Map<String, dynamic> toEntityMap() => {
        '${DBConsts.mod}': (stop.hour * 60) + stop.minute,
        '${DBConsts.hour}': stop.hour,
        '${DBConsts.minute}': stop.minute,
        '${DBConsts.type}': stop.type.index,
        '${DBConsts.note}': stop.note,
      };
}
