# REST API Specification & Endpoint Catalog

Base URL: `http://localhost:5000/api`  
Authentication: HTTP Bearer Token (`Authorization: Bearer <jwt_token>`)

---

## 1. System Health & Diagnostics

### `GET /health`
Returns server operational state and real-time MySQL connectivity diagnostics.
- **Authentication:** Public
- **Response `200 OK`:**
```json
{
  "success": true,
  "status": "healthy",
  "timestamp": "2026-10-12T13:30:00.000Z",
  "database": {
    "connected": true,
    "message": "Successfully connected to MySQL database.",
    "name": "college_admission",
    "host": "localhost",
    "port": 3306
  }
}
```

---

## 2. Administrator Authentication

### `POST /auth/login`
Authenticates an administrator and returns a signed JWT.
- **Authentication:** Public
- **Request Body:**
```json
{
  "email": "admin@college.edu",
  "password": "AdminSecurePassword123!"
}
```
- **Response `200 OK`:**
```json
{
  "success": true,
  "message": "Authentication successful.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "admin": {
      "admin_id": 1,
      "admin_name": "Admission Officer",
      "email": "admin@college.edu",
      "role": "admin"
    }
  }
}
```

### `GET /auth/me`
Fetches active administrator session profile.
- **Authentication:** Required (`Bearer`)
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "admin_id": 1,
    "admin_name": "Admission Officer",
    "email": "admin@college.edu",
    "role": "admin",
    "last_login": "2026-10-12T12:00:00.000Z"
  }
}
```

---

## 3. Dashboard Analytics

### `GET /dashboard/stats`
Returns aggregated count KPIs.
- **Authentication:** Required
- **Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "totalStudents": 10,
    "totalDepartments": 5,
    "totalCourses": 8,
    "totalTutors": 7,
    "pendingApplications": 3,
    "approvedApplications": 6,
    "hostel": { "capacity": 520, "occupied": 5 },
    "transportation": { "capacity": 235, "occupied": 4 }
  }
}
```

### `GET /dashboard/charts`
Returns chart datasets for application status, department distribution, timeline, and occupancy.
- **Authentication:** Required

### `GET /dashboard/recent-activity`
Returns the 5 most recent student registrations and admission applications.
- **Authentication:** Required

---

## 4. Student Management

### `GET /students`
Query Parameters:
- `page` (default 1)
- `limit` (default 10, max 100)
- `search` (searches name, email, phone, ID)
- `department_id` (filter by department)
- `gender` ('Male' | 'Female' | 'Other')

### `GET /students/:id`
Returns full student record joined with department details, course applications, active hostel room, and bus pass.

### `POST /students`
Creates a new student applicant.
- **Request Body:**
```json
{
  "name": "Aarav Mehta",
  "gender": "Male",
  "age": 18,
  "address": "Flat 402, Green Glen Layout, Bengaluru",
  "phone": "+91 91234 56789",
  "email": "aarav.mehta@example.com",
  "rank": 142,
  "marks": 94.50,
  "tenth_marks": 96.20,
  "twelfth_marks": 95.00,
  "department_id": 1
}
```

### `PUT /students/:id`
Updates updatable fields of a student.

### `DELETE /students/:id`
Removes student record from database. Related applications, hostel, and bus assignments are cascadingly cleaned.

---

## 5. Department Management

### `GET /departments`
Query Parameters: `search` (name or code).  
Returns departments with dynamic `total_courses`, `total_tutors`, and `total_students` calculated directly via SQL joins.

### `GET /departments/:id`
Returns department profile with lists of related courses, faculty tutors, and top enrolled students.

### `POST /departments`
- **Request Body:** `{ "department_name": "Aerospace Engineering", "code": "AERO", "description": "..." }`

### `PUT /departments/:id`
Updates department fields.

### `DELETE /departments/:id`
Safely checks if child courses, tutors, or students exist. If found, returns `409 Conflict` with conflict details.

---

## 6. Course Management

### `GET /courses`
Query Parameters: `search`, `department_id`.  
Returns courses joined with department titles, `total_applications`, and `approved_applications`.

### `POST /courses`
- **Request Body:**
```json
{
  "course_name": "B.Tech in Artificial Intelligence",
  "course_code": "CSE-AI-02",
  "duration_years": 4,
  "department_id": 1,
  "intake_capacity": 60
}
```

### `PUT /courses/:id`
Updates course program.

### `DELETE /courses/:id`
Deletes course (restricted if applications exist).

---

## 7. Tutor Management

### `GET /tutors`
Query Parameters: `search`, `department_id`.  
Returns faculty mentors with department details.

### `POST /tutors`
- **Request Body:**
```json
{
  "tutor_name": "Dr. Rajesh Sharma",
  "email": "rajesh.sharma@college.edu",
  "phone": "+91 98765 43210",
  "qualification": "Ph.D in Machine Learning (IIT Delhi)",
  "department_id": 1
}
```

### `PUT /tutors/:id`
Updates tutor record.

### `DELETE /tutors/:id`
Deletes tutor record.

---

## 8. Admission Applications

### `GET /applications`
Query Parameters: `search`, `status`, `course_id`, `department_id`, `cycle_id`, `page`, `limit`.

### `GET /applications/:id`
Returns full student application dossier including academic marks, course details, admission cycle, and `history` status transitions.

### `GET /applications/:id/history`
Returns chronological status audit trail from `application_status_history` table.

### `POST /applications`
Submits course enrollment application.
- **Request Body:**
```json
{
  "student_id": 1,
  "course_id": 2,
  "cycle_id": 1,
  "application_date": "2026-06-01",
  "status": "SUBMITTED",
  "remarks": "Merit rank verification in progress."
}
```

### `PATCH /applications/:id/status`
Updates status with multi-table ACID transaction safety.
- **Request Body:**
```json
{
  "status": "APPROVED",
  "remarks": "Document verification completed.",
  "admin_remarks": "Eligible under merit quota."
}
```
*Note:* When an application is approved, the student's `department_id` is automatically set to the course's department in MySQL, and an entry is logged in `application_status_history`.

---

## 9. Admission Cycles

### `GET /admission-cycles`
Returns admission terms and intake windows with counts of submitted applications.

### `POST /admission-cycles`
Creates a new admission intake cycle.
- **Request Body:**
```json
{
  "cycle_name": "Academic Intake 2026-2027",
  "start_date": "2026-06-01",
  "end_date": "2026-08-31",
  "status": "ACTIVE",
  "description": "General undergraduate admissions"
}
```

### `PUT /admission-cycles/:id`
Updates cycle details or closes an intake term.

### `DELETE /admission-cycles/:id`
Removes cycle if no active applications are tied to it.

---

## 10. Announcements & Campus Circulars

### `GET /announcements`
Returns published or all administrative notices. Query Parameters: `search`, `is_published`.

### `POST /announcements`
Publishes an official admission notice or counseling update.
- **Request Body:**
```json
{
  "title": "Counseling Schedule Round 1 Released",
  "content": "All merit rank holders up to rank 500 must report to the Main Auditorium on July 10th.",
  "published_by": "Admission Directorate",
  "is_published": true
}
```

### `PUT /announcements/:id`
Updates announcement headline or body.

### `DELETE /announcements/:id`
Deletes an announcement.

---

## 11. Application Payments (Financial Ledger)

### `GET /payments`
Returns application counseling and seat-acceptance payment transactions.

### `POST /payments`
Records counseling or seat confirmation fee payment.
- **Request Body:**
```json
{
  "application_id": 1,
  "amount": 75000.00,
  "currency": "INR",
  "transaction_reference": "TXN-2026-CSE-10291",
  "status": "SUCCESS"
}
```

### `DELETE /applications/:id`
Removes an application record.

---

## 9. Hostel & Allocations

### `GET /hostels`
Returns hostels with real-time `total_capacity`, `occupied_seats`, and `available_seats`.

### `POST /hostels`
- **Request Body:** `{ "name": "Aryabhata Bhavan", "type": "Boys", "address": "...", "number_of_seats": 150 }`

### `GET /hostel-allocations`
Query Parameters: `search`, `hostel_id`, `status`.

### `POST /hostel-allocations`
Uses MySQL transactions and `SELECT ... FOR UPDATE` row locks to enforce seat capacity and prevent double-allocations.
- **Request Body:**
```json
{
  "student_id": 1,
  "hostel_id": 1,
  "room_number": "A-204",
  "allocation_date": "2026-07-01",
  "status": "Active"
}
```

### `PATCH /hostel-allocations/:id`
- **Request Body:** `{ "status": "Vacated", "room_number": "..." }`

---

## 10. Bus Transportation & Allocations

### `GET /buses`
Returns transit fleet with route trajectories and seat occupancies.

### `POST /buses`
- **Request Body:** `{ "bus_number": "BUS-01", "route": "...", "destination": "...", "capacity": 50 }`

### `GET /bus-allocations`
Query Parameters: `search`, `bus_id`, `status`.

### `POST /bus-allocations`
Enforces bus seat capacity limits and unique active pass per student with transaction locks.
- **Request Body:**
```json
{
  "student_id": 4,
  "bus_id": 1,
  "allocation_date": "2026-07-05",
  "status": "Active"
}
```

### `PATCH /bus-allocations/:id`
- **Request Body:** `{ "status": "Cancelled" }`

---

## 11. Relational Reports & CSV Export

### `GET /reports/summary`
Returns multi-dimensional aggregation datasets (Department metrics, application acceptance rates, merit scores, housing utilization, transportation quota).

### `GET /reports/export/:type`
Exports database tables directly to CSV format.
Supported types:
- `students`
- `applications`
- `courses`
- `hostel-allocations`
- `bus-allocations`

---

## 12. RDBMS Viva Demonstration & Schema Explorer

### `GET /viva/queries`
Returns the curated catalog of academic SQL demonstration queries (4-Table INNER JOINs, LEFT JOIN aggregations, correlated subqueries, NOT IN queries, GROUP BY with HAVING, Set Operations, Database Views).

### `POST /viva/execute`
Safely executes read-only SQL queries and returns execution time, row count, column definitions, and formatted rows.
- **Request Body (Preset Query):**
```json
{
  "queryId": "join-4-table"
}
```
- **Request Body (Custom Query):**
```json
{
  "sql": "SELECT s.name, s.marks, c.course_name FROM students s JOIN applications a ON s.student_id = a.student_id JOIN courses c ON a.course_id = c.course_id WHERE a.status = 'Approved'"
}
```

### `GET /viva/schema`
Returns full schema data dictionary metadata, including all 11 tables, live row counts, primary keys, foreign key relationships, views, stored procedures, and triggers.

