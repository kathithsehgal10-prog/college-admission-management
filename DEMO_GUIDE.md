# Live demonstration checklist (15 marks)

## Before the demonstration

1. Start MySQL. Confirm the dedicated Workbench connection opens.
2. Start the API and UI in separate terminals with `npm run dev:server` and `npm run dev:client`.
3. Run `npm run db:check`. Confirm a successful real MySQL connection and all required objects.
4. Open http://localhost:5173. Have your administrator email and application password ready.
5. Open the project report and Workbench SQL editor beside the UI.

## Demonstrate the complete flow

1. Sign in; show Settings, the MySQL connection status, and dashboard counts.
2. Show departments, courses, tutors and admission cycles.
3. Register a new fictional student with a unique email and valid marks.
4. In Workbench, run `SELECT student_id, name, email FROM students ORDER BY student_id DESC LIMIT 5;` to show the UI insert persisted in MySQL.
5. Create an application for that student. Show the unique application number and initial history entry.
6. Approve it. Show the changed status, review history and assigned department in the student details.
7. Run the following query, replacing the placeholder with the student's ID:

```sql
SELECT s.student_id, s.name, d.department_name, c.course_name, a.status
FROM students s
JOIN applications a ON a.student_id = s.student_id
JOIN courses c ON c.course_id = a.course_id
LEFT JOIN departments d ON d.department_id = s.department_id
WHERE s.student_id = YOUR_STUDENT_ID;
```

8. Allocate a hostel bed and bus pass. Show occupancy before/after. Attempt a duplicate active allocation and explain the rejection.
9. Vacate/cancel an allocation. Explain that reactivation checks capacity again.
10. Show application payment records and announcements. The payment screen records administrative ledger entries; it does not charge money.
11. Export a CSV report and execute a JOIN, aggregate, subquery and view query in Viva Lab.
12. Refresh the browser and show the same data again, demonstrating database persistence.

## Explain the database design

- 16 tables; PKs identify rows; FKs enforce parent-child references.
- Applications bridge students and courses; allocations represent historical facility assignments.
- Transactions keep status, history and enrollment changes atomic.
- Views calculate counts/occupancy instead of storing derived totals.
- Generated unique keys enforce one active allocation per student.
- Stored routines and triggers are imported separately and shown only if installed.

## Report (5 marks)

Include the problem, objectives, architecture, ER model, relational schema, normalization, implementation, SQL examples, testing evidence, limitations and conclusion. Fill in the personal details on the cover. Add screenshots of the successful MySQL demo after completing it.
