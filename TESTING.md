# Validation evidence

## Automated checks

On 12 October 2026, `node --test server/tests/*.test.js` passed **48 tests, 0 failures**. The tests cover JWT authentication, input boundaries, cycle dates, controller response contracts, SQL runner restrictions, capacity/duplicate admission rules, allocation reactivation, rollback/release, and refusal to fall back to SQLite.

Database-dependent controller tests use controlled mocked responses. They are not evidence of a MySQL installation or live CRUD persistence.

The current frontend production build passed: Vite 6.4.4, 2,315 modules. It reports a non-fatal large-bundle warning; there are no compiler errors.

Run from the project root:

```bash
npm test
npm run build:client
npm run db:check
```

## Live MySQL verification

Verified on 12 October 2026 against **MySQL 26.7.0** at **127.0.0.1:3307**, database **college_submission**.

- 16 base tables and 12 curated SQL demonstrations passed `db:check`.
- 16 live workflow checks passed: authentication, all UI data endpoints, student insertion confirmed by a direct MySQL SELECT, approval/history/enrollment, capacity/duplicate admission rejection, revocation, hostel/bus reactivation, payment ledger, CSV and SQL read-only protection.
- Fictional business records were removed after verification; audit events intentionally preserve the tested changes.
- Chrome UI login, student registration/persistence and Settings were verified; the interface displays the actual MySQL version and configured port.
- Saved Workbench connection ID 2: CAMS Submission - MySQL 3307. Its endpoint/schema were verified with Workbench's bundled MySQL Shell. The password is entered manually when opening it.

The standalone viva command passed, and all 17 queries in database/viva_queries.sql passed on MySQL.

Evidence: MYSQL_VERIFICATION.json, LIVE_DEMO_VERIFICATION.json, UI_VERIFICATION.json and ROUTINE_VERIFICATION.json. Stored procedures also passed approval/history/audit, hostel allocation and duplicate rejection checks.

Re-run `npm run demo:check` while the API is running. It uses the locally generated demo credentials or DEMO_ADMIN_EMAIL/DEMO_ADMIN_PASSWORD and creates/cleans up only its fictional test fixtures.

## Live checklist

| Scenario | Required evidence |
|---|---|
| Sign in | Valid admin credentials return JWT; wrong credentials return 401 |
| Student creation | New student visible in UI and SELECT query in MySQL |
| Application creation | Unique reference; initial history row saved |
| Approval | Status, history, department change committed together |
| Duplicate/full admission | Request rejected and no partial writes |
| Hostel/bus allocation | Occupancy increases; duplicates/full capacity rejected |
| Reactivation | Rejected if resource is full or another active allocation exists |
| Capacity reduction | Rejected below current occupancy |
| Reports and SQL runner | CSV opens; read-only demonstrations return actual rows |
| Persistence | Data remains after refresh/restart |
