# This computer's working project

- UI: http://localhost:5173
- API: http://localhost:5001/api/health
- Database: college_submission
- MySQL endpoint: 127.0.0.1:3307
- Version verified: MySQL 26.7.0
- Workbench connection: CAMS Submission - MySQL 3307
- Database user: cams_submission
- Application administrator email: admin@college.edu

The generated database and application passwords are in server/credentials.local.json. The root password for the installed server on **3307** is in server/mysql-root-credentials.local.json. Both files are private, ignored by Git, and excluded from the submission ZIP.

The old MySQL 8.4 process on port 3306 and its data directory were preserved. Its old root password was not changed. The newer installer had removed that instance's binaries, so the submission uses the installed server on a separate port instead of stopping the old instance.

After a computer restart:

1. Double-click Start_MySQL.command. Enter your Mac login password if sudo asks.
2. Double-click Start_Demo.command.
3. Open the UI and sign in with the application credentials.
4. Reopen Workbench and select CAMS Submission - MySQL 3307. Enter the database account password manually; password storage was not enabled.

Do not rerun Reset_And_Setup.command or Setup_Database.command for the already configured database. The setup scripts refuse to overwrite existing tables or accounts.

For submission to another computer, use the SQL sources and standard README setup instructions with that computer's own MySQL credentials/port. The local service-management scripts are specific to this Mac.

The submission ZIP contains portable source and SQL. Privileged Mac service/reset helpers and private local credentials are deliberately excluded.
