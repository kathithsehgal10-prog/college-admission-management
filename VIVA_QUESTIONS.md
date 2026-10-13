# B.Tech Computer Science & Engineering — RDBMS Viva Examination Guide

Comprehensive Viva Examination Q&A for the **College Admission Management System** project. Designed for academic viva preparation, external examiner evaluations, and database lab tests.

---

## Part 1: Relational Database Foundations & ACID Compliance

### Q1: What is a Relational Database Management System (RDBMS)?
**Answer**: An RDBMS is a database management system based on E.F. Codd's relational model. Data is stored in structured two-dimensional tables (relations) comprising rows (tuples) and columns (attributes). Relationships between relations are enforced mathematically through keys (Primary Keys and Foreign Keys) rather than physical pointer linkages.

### Q2: What are the ACID properties, and where are they demonstrated in this project?
**Answer**:
- **Atomicity ("All or Nothing")**: A transaction executes in its entirety or not at all.
  - *Project Example*: In `sp_approve_application` or `applicationController.js:updateApplicationStatus`, approving an application involves: (1) verifying course intake capacity, (2) changing application status from `'Pending'` to `'Approved'`, and (3) assigning the student to the course's `department_id`. If any query fails, `ROLLBACK` reverts all modifications.
- **Consistency**: The database transitions from one valid state to another, preserving all schema integrity constraints (CHECK, UNIQUE, FOREIGN KEY, NOT NULL).
- **Isolation**: Concurrent transactions execute without interfering with one another. We enforce row-level locking via `SELECT ... FOR UPDATE` on applications and allocations so two administrators cannot allocate the last seat simultaneously.
- **Durability**: Once a transaction is committed (`COMMIT`), changes are permanently persisted to non-volatile disk via the InnoDB Write-Ahead Log (WAL / redo log).

### Q3: What is the difference between DDL, DML, DCL, and TCL?
**Answer**:
- **DDL (Data Definition Language)**: Defines and modifies schema structure (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`). In our project: `database/schema.sql`.
- **DML (Data Manipulation Language)**: Modifies table row data (`INSERT`, `UPDATE`, `DELETE`).
- **DQL (Data Query Language)**: Reads and retrieves records (`SELECT`).
- **DCL (Data Control Language)**: Manages permissions (`GRANT`, `REVOKE`).
- **TCL (Transaction Control Language)**: Manages transactional scopes (`START TRANSACTION`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`).

---

## Part 2: Relational Normalization (1NF, 2NF, 3NF, BCNF)

### Q4: What is First Normal Form (1NF)?
**Answer**: A relation is in 1NF if:
1. Every attribute holds only **atomic (indivisible) values**.
2. There are no repeating groups or multivalued columns (e.g., student phone numbers or enrolled courses stored as comma-separated strings).
3. Each row is uniquely identified by a Primary Key.

*How our project satisfies 1NF*: All tables use atomic columns. Multi-valued assignments (like student course applications or bus routes) are modeled in distinct relation tables (`applications`, `bus_allocations`).

### Q5: What is Second Normal Form (2NF)?
**Answer**: A relation is in 2NF if:
1. It is already in 1NF.
2. It contains **no partial functional dependencies**—no non-prime attribute depends on a proper subset of any candidate composite key.

*How our project satisfies 2NF*: In bridge entities like `applications(application_id, student_id, course_id, application_date, status)` and `hostel_allocations`, we assign a surrogate integer primary key (`application_id`, `allocation_id`). All non-key attributes (`status`, `allocation_date`, `remarks`) depend entirely on the surrogate primary key, eliminating partial key dependencies.

### Q6: What is Third Normal Form (3NF)?
**Answer**: A relation is in 3NF if:
1. It is in 2NF.
2. It contains **no transitive functional dependencies** ($X \rightarrow Y$ and $Y \rightarrow Z$, where $Z$ is transitively dependent on $X$).

*How our project satisfies 3NF*: Non-key attributes depend only on the primary key, directly and non-transitively. For example:
- `students` stores `department_id`, but does NOT store `department_name` or `department_code` (which belong strictly in `departments`).
- Calculated counts (e.g., total enrolled students, available beds) are **never stored as static table columns**, which would introduce update anomalies. Instead, they are dynamically aggregated via SQL queries and Database Views (`view_department_stats`, `view_hostel_occupancy`).

### Q7: What is Boyce-Codd Normal Form (BCNF)?
**Answer**: BCNF is a stricter version of 3NF. A relation is in BCNF if for every non-trivial functional dependency $X \rightarrow Y$, the determinant $X$ must be a **superkey**. Since our tables use single-column surrogate primary keys without overlapping composite candidate keys, every determinant is a superkey, fulfilling BCNF.

---

## Part 3: Keys, Integrity Constraints & Referential Actions

### Q8: What are Candidate Keys, Primary Keys, Super Keys, and Alternate Keys?
**Answer**:
- **Super Key**: Any set of attributes that uniquely identifies a row in a relation.
- **Candidate Key**: A minimal super key (no redundant attributes).
- **Primary Key**: The candidate key chosen by the database designer as the principal row identifier (e.g., `student_id`). It is strictly `NOT NULL` and `UNIQUE`.
- **Alternate Key**: Candidate keys not chosen as the Primary Key (e.g., `email` in `students`).

### Q9: Explain Referential Integrity and Foreign Key Deletion Actions in this project.
**Answer**: Referential integrity guarantees that a foreign key value must either reference an existing valid primary key in the referenced parent relation or be `NULL`.
- **`ON DELETE RESTRICT`**: Prevents parent deletion if child rows exist.
  - *Used in*: `departments -> courses`, `departments -> tutors`. You cannot delete a department while degree courses or tutors are assigned to it.
- **`ON DELETE CASCADE`**: Automatically purges child rows when the parent record is deleted.
  - *Used in*: `students -> applications`, `students -> hostel_allocations`. If an applicant dossier is purged, their applications and residential allocations are cleaned up automatically.
- **`ON DELETE SET NULL`**: Sets the foreign key column to `NULL` upon parent deletion.
  - *Used in*: `departments -> students`. If a department is reorganized, enrolled student profiles remain intact with unassigned status.

---

## Part 4: Advanced SQL & Procedural Database Programming

### Q10: What is the difference between a Stored Procedure and a Stored Function?
**Answer**:
| Characteristic | Stored Procedure (`sp_`) | Stored Function (`fn_`) |
| :--- | :--- | :--- |
| **Return Value** | Returns 0 or more result sets; uses `OUT` params | Must return a single scalar value via `RETURNS` |
| **Invocation** | Called using `CALL procedure_name(...)` | Called directly in SQL queries (`SELECT fn_name(...)`) |
| **Transactions** | Can manage transactions (`START TRANSACTION`, `COMMIT`) | Cannot execute transaction control statements |
| **Side Effects** | Can modify tables via `INSERT`/`UPDATE`/`DELETE` | Typically deterministic and read-only |

### Q11: What are Database Triggers, and how do BEFORE vs AFTER triggers differ?
**Answer**: A Trigger is a procedural block executed automatically when an `INSERT`, `UPDATE`, or `DELETE` event occurs on a table.
- **BEFORE Trigger** (e.g., `trg_check_hostel_capacity_before_insert`): Executes prior to row insertion. Used for data validation and aborting transactions via `SIGNAL SQLSTATE '45000'` if capacity is full.
- **AFTER Trigger** (e.g., `trg_audit_application_status_change`): Executes after successful mutation. Used for non-interfering audit logging into `audit_logs`.

### Q12: What is a Database View, and what are its advantages?
**Answer**: A View (`CREATE VIEW view_name AS SELECT ...`) is a stored virtual relation defined by an underlying SQL query. Advantages:
1. **Zero Redundancy**: Computed statistics (e.g., `view_hostel_occupancy`) are calculated live, eliminating synchronization lag and disk bloat.
2. **Security & Abstraction**: Exposes business metrics to reporting dashboards without granting direct access to raw sensitive tables.
3. **Query Simplification**: Encapsulates complex multi-table `LEFT JOIN` and `GROUP BY` logic into a simple `SELECT * FROM view_name`.

### Q13: What is the difference between `WHERE` and `HAVING` clauses?
**Answer**:
- `WHERE`: Filters individual candidate rows **before** aggregation and grouping occur. Cannot contain aggregate functions (`AVG`, `SUM`, `COUNT`).
- `HAVING`: Filters grouped summary rows **after** `GROUP BY` aggregation has completed.
- *Project Example*:
  ```sql
  SELECT d.department_name, AVG(s.marks) AS avg_marks
  FROM departments d JOIN students s ON d.department_id = s.department_id
  WHERE s.marks >= 60.00          -- Filter rows before grouping
  GROUP BY d.department_name
  HAVING AVG(s.marks) > 85.00;    -- Filter groups after aggregation
  ```

---

## Part 5: Storage Engines, Indexing & Query Optimization

### Q14: Why did we select MySQL InnoDB over MyISAM?
**Answer**:
1. **ACID Transaction Support**: InnoDB provides full transactional support with `COMMIT` and `ROLLBACK`, whereas MyISAM has zero transaction capability.
2. **Row-Level Locking**: InnoDB supports row-level locking (`SELECT ... FOR UPDATE`), enabling high concurrent throughput. MyISAM locks entire tables.
3. **Foreign Key Constraints**: InnoDB enforces relational foreign key integrity. MyISAM parses foreign key syntax but ignores referential enforcement.
4. **Crash Recovery**: InnoDB uses Write-Ahead Logging (WAL) and doublewrite buffers to recover automatically after power interruptions.

### Q15: What is a B+ Tree Index, and how does it speed up queries?
**Answer**: InnoDB organizes table storage and secondary indexes as balanced B+ Trees:
- All data records are stored at the leaf node level, kept sorted in sequential order.
- Search, insertion, and deletion complexity is $O(\log N)$ instead of a full table scan of $O(N)$.
- We created indexes on all foreign keys (`idx_applications_student`, `idx_courses_department`) to optimize relational joins, and on searchable attributes (`idx_students_email`, `idx_students_marks`).

---

## MySQL connection and demonstration

**Q: Why is MySQL mandatory?** The assignment explicitly requires it. The submission API reports a disconnected database when MySQL fails rather than substituting a different engine.

**Q: How do you prove UI-to-database integration?** Create a fictional student in the UI and show its row with SELECT in Workbench, then refresh the UI. Run db:check for MySQL version, schema and query evidence.

**Q: What is the difference between the logins?** The MySQL account authenticates the API/Workbench to the database. The application administrator account signs into the web portal and has a bcrypt password hash.
