import 'dart:io';

import 'package:bus_warbler/constants/db_consts.dart';
import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/models/serial_html.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

  Future<List<Object?>> dropTables(Iterable<ExtendedScheduleStop> stops) async {
    var dropped = Set<String>();
    var batch = _database.batch();
    for (var stop in stops) {
      final table = DBConsts.toTableName(stop.header.route);
      if (dropped.contains(table)) {
        continue;
      }

      batch.execute('DROP TABLE IF EXISTS $table;');
      dropped.add(table);
    }

    return batch.commit(continueOnError: true);
  }
}
