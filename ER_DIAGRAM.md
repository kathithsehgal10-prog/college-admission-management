# ER diagram

```mermaid
erDiagram
    USERS |o--o{ STUDENTS : optional_account
    DEPARTMENTS ||--o{ COURSES : offers
    DEPARTMENTS ||--o{ TUTORS : employs
    DEPARTMENTS |o--o{ STUDENTS : assigned_department
    STUDENTS ||--o{ APPLICATIONS : submits
    COURSES ||--o{ APPLICATIONS : receives
    ADMISSION_CYCLES |o--o{ APPLICATIONS : session
    APPLICATIONS ||--o{ APPLICATION_STATUS_HISTORY : has_history
    APPLICATIONS ||--o{ PAYMENTS : ledger
    STUDENTS ||--o{ HOSTEL_ALLOCATIONS : historical_beds
    HOSTELS ||--o{ HOSTEL_ALLOCATIONS : houses
    STUDENTS ||--o{ BUS_ALLOCATIONS : historical_passes
    BUSES ||--o{ BUS_ALLOCATIONS : transports
```

Admins, announcements and audit_logs support the portal independently. Optional foreign keys may be NULL. Historical allocations permit multiple rows over time; generated unique keys permit only one active row per student for each facility type. Applications permit one approved admission per student.
