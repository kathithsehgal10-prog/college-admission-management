# Submission review and corrections

- Removed automatic SQLite fallback. MySQL failure now gives an honest disconnected state and HTTP 503 for database requests.
- Aligned API defaults and frontend configuration on port 5001. Protected the UI against malformed stored session JSON.
- Removed duplicate MySQL ENUM application statuses that differed only in capitalization; API normalizes legacy aliases to uppercase.
- Replaced COUNT-based application references with UUID-based references so deletion/concurrent requests do not reuse a reference.
- Application creation, review, history writes and enrollment synchronization use one transaction. Failures roll back and release the connection.
- Approval validates course capacity and prevents a second approved admission for the same student. Revocation/deletion synchronizes the student's department.
- Allocation creation and reactivation validate duplicate active allocations and remaining capacity. Student/resource locks serialize conflicting writes.
- Capacity edits use the same resource locks, reject capacity below current occupancy, and reject changing an enrolled course's department.
- Added MySQL conditional unique keys for one approved admission / active allocation per student; nullable cycle IDs use a generated key to enforce duplicate applications.
- Removed duplicated hostel capacity/name fields from the fresh schema and aligned dashboard/views with the canonical columns.
- Viva queries run inside read-only transactions. The runner rejects multiple statements, mutation keywords, comments and file exports.
- Viva metadata reads actual MySQL tables/views/routines/triggers rather than claiming uninstalled objects exist.
- Restricted administrator authentication to the admins table; student users cannot sign into the administration portal.
- Calendar dates and positive payment amounts are validated. CSV formula-like text is escaped for spreadsheet exports.
- Added database setup/check commands. Setup refuses to overwrite existing tables, and the viva command returns failure if queries fail.

Tests use mocked database responses where appropriate. MySQL integration is recorded separately in MYSQL_VERIFICATION.json only after a successful live check.

- MySQL conditional unique columns are virtual so the foreign keys retain their cascade behavior. The final DDL imported successfully on the live server.
- Stored-procedure approval records history once and relies on the audit trigger once; hostel procedure locks resources, rolls back errors and rejects duplicates. Both were verified live.
