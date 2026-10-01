import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// A shot: one screenshot, link or text the user saved. v1 data lives only on the phone.
@DataClassName('ShotRow')
class Shots extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get source => text()(); // ShotSource.name
  TextColumn get imagePath => text().nullable()(); // app-owned compressed copy
  TextColumn get imageHash => text().nullable()(); // sha256 of the original bytes, for duplicates
  TextColumn get extractedText => text().withDefault(const Constant(''))();
  TextColumn get link => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  BoolColumn get categoryCorrected => boolean().withDefault(const Constant(false))();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get gist => text().withDefault(const Constant(''))();
  TextColumn get suggestedOutput => text().withDefault(const Constant('post'))();
  BoolColumn get expires => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()(); // "Why did you save this?"
  TextColumn get about => text().nullable()(); // answer to "What's this about?"
  BoolColumn get lowText => boolean().withDefault(const Constant(false))();
  BoolColumn get sensitive => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('newShot'))();
  DateTimeColumn get madeAt => dateTime().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drafts made for a shot. Only the latest per output is shown.
@DataClassName('DraftRow')
class Drafts extends Table {
  TextColumn get id => text()();
  TextColumn get shotId => text().references(Shots, #id, onDelete: KeyAction.cascade)();
  TextColumn get output => text()(); // OutputType.name
  TextColumn get body => text()();
  TextColumn get serverId => text().nullable()(); // for reporting
  IntColumn get regenerationsUsed => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Category corrections. Later these become examples for the classifier (SPEC).
@DataClassName('CorrectionRow')
class CategoryCorrections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get shotId => text()();
  TextColumn get fromCategory => text()();
  TextColumn get toCategory => text()();
  TextColumn get textSample => text()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Makes waiting for internet (SPEC edge case: "No internet during make: queue it").
@DataClassName('QueuedMakeRow')
class MakeQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get shotId => text().references(Shots, #id, onDelete: KeyAction.cascade)();
  TextColumn get output => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Shots, Drafts, CategoryCorrections, MakeQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'shotr'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
