import 'dart:io';

import 'package:bus_warbler/models/parse_html_page.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBConsts {
  static String dbName = 'bus_warbler.db';

  static String kanaiOfuna = 'kanai_ofuna';
  static String ofunaKanai = 'ofuna_kanai';
  static String kanaiTotsuka = 'kanai_totsuka';
  static String totsukaKanai = 'totsuka_kanai';

  static Iterable<String> tableCreationQueries = [
    kanaiOfuna,
    ofunaKanai,
    kanaiTotsuka,
    totsukaKanai
  ].map(_tableCreationSql);

  static bool isTableName(String name) => [
        kanaiOfuna,
        ofunaKanai,
        kanaiTotsuka,
        totsukaKanai,
      ].toSet().contains(name);

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

class DatabaseService {
  late Database _database;
  bool _isOpen = false;

  static _onCreate(Database db, int version) async {
    final batch = db.batch();
    for (var query in DBConsts.tableCreationQueries) {
      batch.execute(query);
    }

    await batch.commit(continueOnError: false);
  }

  Future<void> _ensureOpened() {
    if (_isOpen) {
      return Future.value();
    }

    return _lazyInitialize();
  }

  Future<void> _lazyInitialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DBConsts.dbName);

    try {
      await Directory(dbPath).create(recursive: true);

      final database = await openDatabase(
        path,
        onCreate: _onCreate,
        onOpen: (db) {
          print('db opened');
        },
        version: 1,
      );

      print('created db at: $path');

      _database = database;
      _isOpen = true;
    } catch (e) {
      print(e);
    }
  }

  Future<Iterable<ScheduleStop>> queryAll(String tableName) async {
    DBConsts.assertTableName(tableName);

    await _ensureOpened();
    final results = await this._database.query(tableName);
    return results
        .where(DBConsts.hasStopKeys)
        .map((item) => ScheduleStop.fromMap(item));
  }

  Future<int> insert(String table, ExtendedScheduleStop stop) async {
    DBConsts.assertTableName(table);

    await _ensureOpened();
    return _database.insert(table, stop.toEntityMap());
  }

  Future<List<Object?>> batchInsert(
      Iterable<ExtendedScheduleStop> stops) async {
    await _ensureOpened();
    var batch = _database.batch();
    for (var stop in stops) {
      final table = DBConsts.toTableName(stop.header.route);
      batch.insert(table, stop.toEntityMap());
    }

    return batch.commit(continueOnError: true);
  }
}
