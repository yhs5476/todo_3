import 'package:drift/drift.dart';

// Define the Tasks table
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isCompleted => boolean().nullable().withDefault(const Constant(false))();
  TextColumn get date => text().nullable()(); // Storing as text for now, can be DateTimeColumn
  TextColumn get startTime => text().nullable()();
  TextColumn get endTime => text().nullable()();
  IntColumn get color => integer().nullable()();
  IntColumn get remind => integer().nullable()(); // Or BoolColumn if it's just a flag
  TextColumn get repeat => text().nullable()();

  // If you want to enforce title is not null, you can remove .nullable()
  // TextColumn get title => text()();
}
