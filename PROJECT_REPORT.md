# College Admission Management System

## Project report - RDBMS assignment

Student name: ____________________  
Roll number: ____________________  
Institution / department: ____________________  
Instructor: ____________________  
Submission date: ____________________

## 1. Abstract and problem statement

The College Admission Management System provides an administrative website for student registration, course applications, admission reviews, hostel bed allocation and bus passes. It connects a React interface to an Express REST API and a MySQL/InnoDB relational database. Admission cycles, announcements, status history and a manual payment ledger support the administrative workflow.

Paper forms and independent spreadsheets can duplicate records and make it difficult to identify available seats or follow an admission decision. The project centralizes these records, uses database keys to preserve relationships, and calculates statistics through SQL joins, aggregates and views.

## 2. Objectives and assignment requirements

- Prepare a project report describing the problem, design, implementation and verification (5 marks).
- Provide a working website interface for administrative operations.
- Create and connect a MySQL database.
- Demonstrate the complete UI-to-database flow live (15 marks), including persistence and SQL queries.
- Validate marks, dates and capacities; prevent duplicate active allocations and inconsistent multi-step writes.

## 3. Architecture and software requirements

React 18, React Router, Tailwind CSS and Recharts form the frontend. Vite builds and serves it. Express provides authenticated JSON endpoints. mysql2 uses a connection pool and parameterized SQL. MySQL stores persistent data in InnoDB tables. bcrypt hashes administrator passwords; signed JWT tokens authenticate API requests.

Flow: browser form -> REST request -> validation/authentication -> parameterized MySQL query or transaction -> JSON response -> refreshed UI.

Environment: Node.js 20.19+ or 22.12+, npm, MySQL 8.0.16+, and a modern browser. Standard ports: UI 5173, API 5001, MySQL 3307 for this local installation. MySQL credentials are configured locally in server/.env. The application does not substitute SQLite when MySQL fails.

## 4. Entity relationships and relational schema

The schema has 16 tables:

| Relation | Primary key | Purpose / important relationships |
|---|---|---|
| users | user_id | Optional applicant account records |
| admins | admin_id | Administrator credentials and roles |
| departments | department_id | Academic departments |
| courses | course_id | FK department_id; program capacity |
| tutors | tutor_id | FK department_id; faculty information |
| students | student_id | Optional FKs user_id, department_id; academic dossier |
| admission_cycles | cycle_id | Admission session dates and status |
| applications | application_id | FKs student_id, course_id, cycle_id; review state |
| application_status_history | history_id | FK application_id; decision timeline |
| hostels | hostel_id | Hostel information and bed capacity |
| hostel_allocations | allocation_id | FKs student_id, hostel_id; allocation history |
| buses | bus_id | Routes and passenger capacity |
| bus_allocations | allocation_id | FKs student_id, bus_id; pass history |
| announcements | announcement_id | Administrative announcements |
| payments | payment_id | FK application_id; manual fee ledger |
| audit_logs | log_id | Database state-change audit entries |

A department offers many courses and employs many tutors. A student may submit applications for different courses; applications resolve that many-to-many relationship and optionally reference an admission cycle. Each application has many history and payment records. Students and hostels/buses are linked through historical allocation tables. Business rules restrict each student to one active hostel allocation, one active bus allocation and one approved admission.

## 5. Normalization and integrity

First normal form: each field contains one scalar value; course lists and allocation histories are represented by rows. Second normal form: entity attributes depend on their entity key; relationship attributes such as allocation date belong to the bridge row. Third normal form: course department information is referenced rather than copied into each application, and faculty/facility data remains in its own relation. Counts and available seats are derived instead of stored as duplicate totals.

Primary keys identify rows. Foreign keys enforce valid references. Unique keys constrain emails, application references and transaction references. Generated conditional keys enforce one active/approved record per student. A generated cycle key converts NULL to a consistent value so the unique student/course/cycle rule also covers applications with no cycle.

CHECK constraints restrict marks, ages and positive capacities. API validation also rejects invalid calendar dates and payment amounts. Parameter binding avoids constructing SQL from form values.

## 6. Implementation and transaction behavior

The administrator registers a student, creates an application, reviews its dossier, and updates its status. Application creation writes the application and initial history together. Review updates the status, review fields and history in one transaction. Approval checks capacity and other approved admissions before assigning the department. Revocation or deletion synchronizes that assignment.

Allocation creation and reactivation lock the student and the relevant resource, check duplicate active records and remaining capacity, and write only if valid. Capacity edits lock the same resource and reject a reduction below occupancy. READ COMMITTED transactions ensure occupancy checks observe commits made while waiting for a lock. Failed operations roll back and release the pooled connection.

Only the admins relation provides portal login. Applicant users cannot enter the administrator portal. Payments represent manual administrative ledger entries; the project does not integrate a payment gateway or process actual payments.

## 7. SQL views, routines and examples

Views: view_department_stats, view_hostel_occupancy and view_bus_occupancy calculate live department counts and facility occupancy.

Routines: fn_calculate_merit_score combines entrance, 10th and 12th marks with weights 50%, 25%, 25%; availability functions calculate facility capacity. Procedures demonstrate approval, hostel allocation and department reporting. Triggers check allocation capacity on insert and audit application status changes. The routines/triggers SQL file must be imported separately.

```sql
SELECT s.name, c.course_name, d.department_name, a.status
FROM applications a
JOIN students s ON s.student_id = a.student_id
JOIN courses c ON c.course_id = a.course_id
JOIN departments d ON d.department_id = c.department_id
WHERE a.status = 'APPROVED';

SELECT * FROM view_hostel_occupancy;

SELECT department_id, COUNT(*) AS student_count
FROM students
GROUP BY department_id;
```

The viva runner executes demonstration SQL within read-only transactions and rejects multiple statements, modification statements and file-export operations. Metadata is read from information_schema to show only the objects actually installed.

## 8. Testing and demonstration

All 48 automated tests passed and the frontend production build passed. Live MySQL 26.7.0 verification passed for 16 tables, 12 SQL demonstrations and 16 workflow checks; Chrome login and connection diagnostics were verified. The detailed checks are recorded in docs/TESTING.md. These tests include controlled database mocks and must not be treated as proof of a live MySQL connection. A successful db:check command records real MySQL version, installed objects and executed SQL results in docs/MYSQL_VERIFICATION.json.

The live demonstration registers a fictional student in the UI, confirms the new row using SELECT in Workbench, submits and approves an application, shows its history, allocates hostel/bus seats, demonstrates duplicate rejection, exports a CSV and refreshes to show persistence. docs/DEMO_GUIDE.md gives the complete sequence.

## 9. Limitations and conclusion

The current interface is an administrator portal. Applicant self-service, payment gateway integration, deployment, backups and broader operational security are future work. Database setup requires a valid MySQL account and the installed schema/routines. Live verification evidence is included as JSON; screenshots may be attached from the working browser and Workbench.

The project combines a functional administrative interface with a relational schema, integrity constraints, transactions, joins, aggregates and views. Successful completion of the live MySQL checklist demonstrates the assignment's required UI and database integration.

## References

- MySQL reference manual: https://dev.mysql.com/doc/refman/8.4/en/
- MySQL locking reads: https://dev.mysql.com/doc/refman/8.4/en/innodb-locking-reads.html
- Express documentation: https://expressjs.com/
- React documentation: https://react.dev/
- Project SQL source: database/schema.sql and database/procedures_and_triggers.sql
