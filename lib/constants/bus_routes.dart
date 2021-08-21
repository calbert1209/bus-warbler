class StopName {
  StopName._(this.value);
  final String value;

  static final StopName kanai = StopName._("金井(横浜市栄区)");
  static final StopName totsuka = StopName._("戸塚バスセンター");
  static final StopName ofuna = StopName._("大船駅西口");
}

class BusRouteUrlParts {
  BusRouteUrlParts({
    required this.cs,
    required this.nid,
  });

  final String cs;
  final String nid;

  int get _dateTimeStamp {
    final ms = DateTime.now().millisecondsSinceEpoch;
    return ms ~/ 1000;
  }

  Map<String, String> toMap() => {
        "cs": cs,
        "nid": nid,
        "dts": _dateTimeStamp.toString(),
        "chk": "all",
      };
}

class BusRoute {
  BusRoute({
    required this.nickname,
    required this.parts,
    required this.name,
    required this.destination,
  });

  final String nickname;
  final StopName name;
  final StopName destination;
  final List<BusRouteUrlParts> parts;
}

final Map<String, BusRoute> busRoutes = {
  "kanai-totsuka": BusRoute(
    nickname: "kanai-totsuka",
    parts: [
      BusRouteUrlParts(
        cs: "0000800324-12",
        nid: "00126844",
      ),
    ],
    name: StopName.kanai,
    destination: StopName.totsuka,
  ),
  "totsuka-kanai": BusRoute(
    nickname: "totsuka-kanai",
    parts: [
      BusRouteUrlParts(
        cs: "0000800754-1",
        nid: "00126775",
      ),
      BusRouteUrlParts(
        cs: "0000800673-1",
        nid: "00126775",
      ),
    ],
    name: StopName.kanai,
    destination: StopName.totsuka,
  ),
  // between Kanai and Ofuna
  "kanai-ofuna": BusRoute(
    nickname: "kanai-ofuna",
    parts: [
      BusRouteUrlParts(
        cs: "0000800419-10",
        nid: "00126844",
      ),
    ],
    name: StopName.kanai,
    destination: StopName.ofuna,
  ),
  "ofuna-kanai": BusRoute(
    nickname: "kanai-ofuna",
    parts: [
      BusRouteUrlParts(
        cs: "0000800324-1",
        nid: "00126855",
      ),
    ],
    name: StopName.ofuna,
    destination: StopName.kanai,
  ),
};
