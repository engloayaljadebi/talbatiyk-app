import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Restores the v12 ownership-column boundary in a temporary test fixture.
///
/// The fixture is initially constructed with the current schema.
/// Before pretending it was installed under an earlier user_version,
/// remove the v13 additions so the real migration must add them.
///
/// Never use this helper against an application or production database.
void removeV13OwnershipColumnsFromLegacyFixture(sqlite.Database database) {
  for (final table in const ['order_records', 'sync_operations']) {
    final columns = database.select("PRAGMA table_info('$table');");

    final hasOwnerColumn = columns.any((row) => row['name'] == 'owner_user_id');

    if (!hasOwnerColumn) {
      throw StateError('Fixture expected owner_user_id in $table.');
    }

    database.execute('ALTER TABLE "$table" DROP COLUMN "owner_user_id";');
  }
}
