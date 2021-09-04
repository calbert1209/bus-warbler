import 'package:bus_warbler/models/serial_html.dart';

class DBConsts {
  static String dbName = 'bus_warbler.db';

  static String kanaiOfuna = 'kanai_ofuna';
  static String ofunaKanai = 'ofuna_kanai';
  static String kanaiTotsuka = 'kanai_totsuka';
  static String totsukaKanai = 'totsuka_kanai';

  static Iterable<String> tableNames = [
    kanaiOfuna,
    ofunaKanai,
    kanaiTotsuka,
    totsukaKanai
  ];

  static Iterable<String> tableCreationQueries =
      tableNames.map(_tableCreationSql);

  static bool isTableName(String name) => tableNames.toSet().contains(name);

  static assertTableName(String name) {
    assert(isTableName(name), '$name is not a valid table name');
  }

  static const _id = '_id';
  static const mod = 'minutes_of_day';
  static const hour = 'hour';
  static const minute = 'minute';
  static const type = 'schedule_type';
  static const note = 'note';

  static String _tableCreationSql(String tableName) {
    return '''
create table $tableName (
  $_id integer primary key autoincrement,
  $mod integer not null,
  $hour integer not null,
  $minute integer not null,
  $type integer not null,
  $note text)
''';
  }

  static String toTableName(Route route) {
    switch (route) {
      case Route.kanaiOfuna:
        return kanaiOfuna;
      case Route.ofunaKanai:
        return ofunaKanai;
      case Route.kanaiTotsuka:
        return kanaiTotsuka;
      case Route.totsukaKanai:
        return totsukaKanai;
      default:
        throw RangeError('route: ${route.toString()}');
    }
  }

  static bool hasStopKeys(Map<String, dynamic> item) {
    return [mod, hour, minute, type, note]
        .every((key) => item.containsKey(key));
  }
}
