# College Admission Management System

RDBMS assignment: React UI + Express API + **MySQL/InnoDB database** + project report and live demonstration.

## Quick local setup

Double-click `Setup_Database.command`, enter the existing MySQL root password, and let it create the new `college_submission` database and dedicated account. It prints the generated database and application passwords, configures the project, and checks MySQL. Existing databases are preserved. Then double-click `Start_Demo.command`.

If setup reports an existing submission database/account, do not rerun destructive schema scripts; use the existing configuration and `db:check`.

## Run the project

Requires Node.js 20.19+ (or 22.12+), npm, and MySQL 8.0.16+.

```bash
npm run install:all
cp server/.env.example server/.env
cp client/.env.example client/.env
```

Edit `server/.env` with the actual MySQL account and database. This computer uses API **5001**, UI **5173**, and MySQL **3307**. The connected MySQL version is **26.7.0**; the older instance on 3306 is preserved. See docs/LOCAL_DEMO.md.

### Create a new database

Set `DB_NAME` to a new database name, and use a MySQL account allowed to create it:

```bash
npm run db:setup
npm run create-admin
npm run db:check
```

`db:setup` refuses to overwrite a database that already contains tables. It imports the schema, demonstration seed data, functions, procedures, and triggers. The raw schema/seed SQL files recreate tables; do not run them against a database you need to preserve.

### Start the UI and API

In separate terminals, from this folder:

```bash
npm run dev:server
```

```bash
npm run dev:client
```

Open http://localhost:5173 and sign in with the administrator account created above. Application login is separate from the MySQL/Workbench login.

## Verify and demonstrate

```bash
npm test
npm run build:client
npm run db:check
npm run demo:check
npm run viva
```

`db:check` connects to real MySQL, checks all 16 tables, runs the curated SQL demonstrations, and saves `docs/MYSQL_VERIFICATION.json`. There is **no SQLite fallback**. The API reports `degraded` when MySQL cannot connect.

Use `docs/DEMO_GUIDE.md` for the live demonstration. The report source is `docs/PROJECT_REPORT.md`; the printable report is under `output/pdf/`.

## Features

- Administrator sign-in with bcrypt password hashes and JWT tokens.
- Departments, courses, tutors, students, admission cycles and announcements.
- Applications with unique reference numbers, review history, approval and enrollment.
- Capacity checks for courses, hostel beds and bus passes, including reactivation.
- Manual payment ledger and CSV exports (no payment gateway or money transfer).
- Dashboard, database views, SQL viva queries and actual database object metadata.

## Fixes and validation

See `docs/FIXES.md` and `docs/TESTING.md`. Passing unit/controller tests and a frontend build do not establish live MySQL connectivity; use `db:check` and the live demo checklist for that evidence.

## Submission

Submit the source code, `database/` SQL scripts, and project report. Fill in your name, roll number, institution and instructor on the report cover. Keep `.env`, passwords, local database files, and `node_modules` out of the submission ZIP.
