-- =====================================================================
-- College Admission Management System — Viva & Demonstration Queries
-- Academic Reference: B.Tech RDBMS Laboratory Examination
-- Database: college_admission (MySQL 8.x / InnoDB)
-- =====================================================================

-- Select the project database in Workbench before running these examples.

-- =====================================================================
-- CATEGORY 1: MULTI-TABLE JOINS (INNER, LEFT, RIGHT, FULL EMULATION)
-- =====================================================================

-- Query 1.1: 4-Table INNER JOIN
-- Retrieve admitted applicants with course details, department name, and entrance merit score
SELECT 
    s.student_id,
    s.name AS student_name,
    s.gender,
    s.marks AS entrance_score,
    s.rank AS merit_rank,
    c.course_name,
    c.course_code,
    d.department_name,
    a.application_date,
    a.status AS admission_status
FROM applications a
INNER JOIN students s ON a.student_id = s.student_id
INNER JOIN courses c ON a.course_id = c.course_id
INNER JOIN departments d ON c.department_id = d.department_id
WHERE UPPER(a.status) = 'APPROVED'
ORDER BY s.marks DESC;

-- Query 1.2: LEFT OUTER JOIN with Aggregation
-- List ALL departments including those without courses or students
SELECT 
    d.department_id,
    d.department_name,
    COUNT(DISTINCT c.course_id) AS total_courses,
    COUNT(DISTINCT t.tutor_id) AS total_faculty_mentors,
    COUNT(DISTINCT s.student_id) AS enrolled_students,
    COALESCE(ROUND(AVG(s.marks), 2), 0.00) AS avg_student_score
FROM departments d
LEFT JOIN courses c ON d.department_id = c.department_id
LEFT JOIN tutors t ON d.department_id = t.department_id
LEFT JOIN students s ON d.department_id = s.department_id
GROUP BY d.department_id, d.department_name
ORDER BY enrolled_students DESC;

-- Query 1.3: Complex Multi-Join with Housing & Transportation Allocation
-- Find students who have been allocated BOTH hostel residence and bus transit pass
SELECT 
    s.student_id,
    s.name AS student_name,
    h.name AS hostel_name,
    ha.room_number,
    b.bus_number,
    b.route AS transit_route
FROM students s
INNER JOIN hostel_allocations ha ON s.student_id = ha.student_id AND ha.status = 'Active'
INNER JOIN hostels h ON ha.hostel_id = h.hostel_id
INNER JOIN bus_allocations ba ON s.student_id = ba.student_id AND ba.status = 'Active'
INNER JOIN buses b ON ba.bus_id = b.bus_id;

-- Query 1.4: Self-Join (Pairwise Comparison)
-- Find pairs of students who scored identical entrance exam marks
SELECT 
    s1.student_id AS student_1_id,
    s1.name AS student_1_name,
    s2.student_id AS student_2_id,
    s2.name AS student_2_name,
    s1.marks AS shared_marks
FROM students s1
INNER JOIN students s2 ON s1.marks = s2.marks AND s1.student_id < s2.student_id;

-- =====================================================================
-- CATEGORY 2: SUBQUERIES (NESTED, CORRELATED, IN, EXISTS)
-- =====================================================================

-- Query 2.1: Subquery with IN Operator
-- Find applicants who have NOT submitted any course application yet
SELECT 
    student_id, 
    name, 
    email, 
    phone, 
    marks, 
    `rank`
FROM students
WHERE student_id NOT IN (
    SELECT DISTINCT student_id 
    FROM applications
);

-- Query 2.2: Correlated Subquery with EXISTS
-- Find courses that have at least one 'Pending' verification application
SELECT 
    c.course_id,
    c.course_name,
    c.course_code,
    c.intake_capacity
FROM courses c
WHERE EXISTS (
    SELECT 1 
    FROM applications a 
    WHERE a.course_id = c.course_id AND a.status = 'Pending'
);

-- Query 2.3: Correlated Subquery for Capacity Calculation
-- Dynamically compute available vacant seats in hostels without views
SELECT 
    h.hostel_id,
    h.name AS hostel_name,
    h.type,
    h.number_of_seats AS total_capacity,
    (
        SELECT COUNT(*) 
        FROM hostel_allocations ha 
        WHERE ha.hostel_id = h.hostel_id AND ha.status = 'Active'
    ) AS occupied_seats,
    (
        h.number_of_seats - (
            SELECT COUNT(*) 
            FROM hostel_allocations ha 
            WHERE ha.hostel_id = h.hostel_id AND ha.status = 'Active'
        )
    ) AS available_beds
FROM hostels h;

-- Query 2.4: Subquery in FROM clause (Derived Table)
-- Calculate the percentile ranking of courses by applicant interest
SELECT 
    d.department_name,
    derived.course_name,
    derived.total_applicants,
    derived.approved_applicants
FROM (
    SELECT 
        c.department_id,
        c.course_name,
        COUNT(a.application_id) AS total_applicants,
        COUNT(CASE WHEN UPPER(a.status) = 'APPROVED' THEN 1 END) AS approved_applicants
    FROM courses c
    LEFT JOIN applications a ON c.course_id = a.course_id
    GROUP BY c.course_id, c.department_id, c.course_name
) AS derived
JOIN departments d ON derived.department_id = d.department_id
ORDER BY derived.total_applicants DESC;

-- =====================================================================
-- CATEGORY 3: AGGREGATIONS WITH GROUP BY & HAVING
-- =====================================================================

-- Query 3.1: GROUP BY with HAVING clause
-- Find departments where the average entrance score exceeds 85.00
SELECT 
    d.department_name,
    COUNT(s.student_id) AS total_students,
    ROUND(AVG(s.marks), 2) AS avg_marks,
    MAX(s.marks) AS top_score,
    MIN(s.marks) AS lowest_score
FROM departments d
JOIN students s ON d.department_id = s.department_id
GROUP BY d.department_id, d.department_name
HAVING AVG(s.marks) > 85.00
ORDER BY avg_marks DESC;

-- Query 3.2: Gender Diversity Metrics Across Admissions
SELECT 
    s.gender,
    COUNT(s.student_id) AS student_count,
    ROUND(COUNT(s.student_id) * 100.0 / (SELECT COUNT(*) FROM students), 2) AS percentage,
    ROUND(AVG(s.marks), 2) AS avg_marks
FROM students s
GROUP BY s.gender;

-- =====================================================================
-- CATEGORY 4: SET OPERATIONS (UNION, INTERSECT / EXCEPT EMULATION)
-- =====================================================================

-- Query 4.1: UNION Operator
-- Combine all campus email contacts (Students, Tutors, Admins) into a unified directory
SELECT student_id AS id, name AS contact_name, email, 'Student' AS contact_role FROM students
UNION
SELECT tutor_id AS id, tutor_name AS contact_name, email, 'Faculty Tutor' AS contact_role FROM tutors
UNION
SELECT admin_id AS id, admin_name AS contact_name, email, 'System Admin' AS contact_role FROM admins
ORDER BY contact_role, contact_name;

-- =====================================================================
-- CATEGORY 5: WINDOW FUNCTIONS (MySQL 8.x)
-- =====================================================================

-- Query 5.1: RANK() and DENSE_RANK() by entrance score
SELECT 
    student_id,
    name,
    marks,
    RANK() OVER (ORDER BY marks DESC) AS dense_calculated_rank,
    AVG(marks) OVER () AS overall_cohort_average,
    ROUND(marks - AVG(marks) OVER (), 2) AS score_deviation
FROM students
ORDER BY marks DESC;

-- =====================================================================
-- CATEGORY 6: DATABASE VIEWS VERIFICATION
-- =====================================================================

-- Query 6.1: Real-time Department Statistics View
SELECT * FROM view_department_stats ORDER BY total_students DESC;

-- Query 6.2: Hostel Occupancy View
SELECT * FROM view_hostel_occupancy WHERE available_seats > 0;

-- Query 6.3: Bus Transit Occupancy View
SELECT * FROM view_bus_occupancy;

-- =====================================================================
-- CATEGORY 7: STORED PROCEDURES & FUNCTIONS INVOCATION
-- =====================================================================

-- Query 7.1: Call Stored Function fn_calculate_merit_score
SELECT 
    student_id,
    name,
    marks AS entrance,
    tenth_marks AS board_10th,
    twelfth_marks AS board_12th,
    fn_calculate_merit_score(marks, tenth_marks, twelfth_marks) AS weighted_merit
FROM students
ORDER BY weighted_merit DESC;

-- Query 7.2: Call Stored Function fn_hostel_available_beds
SELECT hostel_id, name, fn_hostel_available_beds(hostel_id) AS available_beds FROM hostels;

-- Query 7.3: Call Stored Procedure sp_department_enrollment_report
-- CALL sp_department_enrollment_report(1);
