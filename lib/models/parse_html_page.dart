class SerialHtml {
  SerialHtml(this._html);

  final String _html;

  PageSchedules sections() {
    final trimmed = _html.split("<pre>")[1].split("</pre>")[0];
    final sections = trimmed.split("■");
    return PageSchedules.fromList(sections);
  }

  Iterable<ExtendedScheduleStop> stops() {
    final trimmed = _html.split("<pre>")[1].split("</pre>")[0];
    final sections = trimmed.split("■");
    final schedules = PageSchedules.fromList(sections);
    return schedules.stops.map((stop) => ExtendedScheduleStop(
          header: schedules.header,
          stop: stop,
        ));
  }
}

class PageSchedules {
  PageSchedules._({
    required this.header,
    required this.stops,
  });

  factory PageSchedules.fromList(List<String> list) {
    if (list.length <= 3) {
      throw ("list must have length > 3");
    }

    final weekday = ScheduleLines.fromSection(list[1]).toStops();
    final saturday = ScheduleLines.fromSection(list[2]).toStops();
    final holiday = ScheduleLines.fromSection(list[3]).toStops();

    return PageSchedules._(
        header: PageHeader.parse(list[0]),
        stops: [...weekday, ...saturday, ...holiday]);
  }

  final PageHeader header;
  final List<ScheduleStop> stops;
}

class PageHeader {
  PageHeader._({
    required this.name,
    required this.destination,
    required this.publishDate,
    required this.fetchDate,
  });

  final String name;
  final String destination;
  final DateTime publishDate;
  final DateTime fetchDate;

  static String _firstMatchFirstGroup(String pattern, String haystack) =>
      RegExp(pattern).firstMatch(haystack)!.group(1)!;

  factory PageHeader.parse(String text) {
    final name = _firstMatchFirstGroup(r"^ﾊﾞｽ停名：(.*)", text);
    final dest = _firstMatchFirstGroup(r"行先：(.*)\n", text);
    final publish =
        _firstMatchFirstGroup(r"改正日：([\d\/]*)", text).replaceAll(r"/", "-");
    final publishDate = DateTime.parse(publish);
    return PageHeader._(
      name: name,
      destination: dest,
      publishDate: publishDate,
      fetchDate: DateTime.now(),
    );
  }
}

class ScheduleLine {
  ScheduleLine._(this.hour, this.minutes);

  final int hour;
  final List<ScheduleMinute> minutes;

  factory ScheduleLine.fromLine(String line) {
    final split = line.split("時 ");
    final hour = int.parse(split[0]);
    final minutes =
        split[1].split(" . ").map((text) => ScheduleMinute.parse(text));
    return ScheduleLine._(hour, [...minutes]);
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

class ScheduleMinute {
  ScheduleMinute._(this.value, this.note);

  final int value;
  final String? note;

  factory ScheduleMinute.parse(String dirty) {
    final delimiter = ",";
    final split =
        dirty.replaceAll(RegExp(r"[\(\)]"), delimiter).split(delimiter);
    final note = split.length > 1 ? split[1] : null;
    return ScheduleMinute._(int.parse(split[0]), note);
  }
}

class ScheduleLines {
  ScheduleLines._(this.type, this.lines);

  final StopType type;
  final List<ScheduleLine> lines;

  factory ScheduleLines.fromSection(String section) {
    final hasMatch =
        (String pattern, String haystack) => RegExp(pattern).hasMatch(haystack);
    final split = section.split("\n");
    var lines = <ScheduleLine>[];
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
        lines.add(ScheduleLine.fromLine("$line $last"));
      } else {
        last = line;
      }
    }
    return ScheduleLines._(
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
}

class ExtendedScheduleStop {
  ExtendedScheduleStop({
    required this.header,
    required this.stop,
  });

  final PageHeader header;
  final ScheduleStop stop;
}
