-- =====================================================================
-- College Admission Management System — Development Seed Data
-- Target RDBMS: MySQL 8.4.11 / 8.x
-- Notice: Admins are registered securely via 'npm run create-admin'.
-- =====================================================================

USE college_admission;

-- Disable FK checks for deterministic bulk insertions
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE payments;
TRUNCATE TABLE application_status_history;
TRUNCATE TABLE bus_allocations;
TRUNCATE TABLE hostel_allocations;
TRUNCATE TABLE applications;
TRUNCATE TABLE students;
TRUNCATE TABLE tutors;
TRUNCATE TABLE courses;
TRUNCATE TABLE admission_cycles;
TRUNCATE TABLE departments;
TRUNCATE TABLE hostels;
TRUNCATE TABLE buses;
TRUNCATE TABLE announcements;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- 1. Departments
-- ---------------------------------------------------------------------
INSERT INTO departments (department_id, department_name, code, description) VALUES
(1, 'Computer Science & Engineering', 'CSE', 'Focuses on software engineering, algorithms, AI, and systems programming.'),
(2, 'Electronics & Communication Engineering', 'ECE', 'Covers microelectronics, embedded systems, VLSI, and signal processing.'),
(3, 'Mechanical Engineering', 'MECH', 'Covers thermodynamics, robotics, mechanics, and industrial design.'),
(4, 'Civil Engineering', 'CIVIL', 'Focuses on structural engineering, geotechnics, and urban infrastructure.'),
(5, 'Information Technology', 'IT', 'Covers cloud computing, database systems, cybersecurity, and networking.');

-- ---------------------------------------------------------------------
-- 2. Admission Cycles
-- ---------------------------------------------------------------------
INSERT INTO admission_cycles (cycle_id, cycle_name, start_date, end_date, status, description) VALUES
(1, 'Academic Year 2026-27 (Fall Regular Intake)', '2026-04-01', '2026-08-31', 'ACTIVE', 'Main undergraduate entrance counseling and seat allocation window.'),
(2, 'Direct Lateral Entry 2026-27 (Diploma/Transfer)', '2026-05-15', '2026-09-15', 'UPCOMING', 'Admissions for diploma holders into the 2nd year of B.Tech programs.'),
(3, 'Academic Year 2025-26 (Archive)', '2025-04-01', '2025-08-31', 'CLOSED', 'Previous academic year completed admissions.');

-- ---------------------------------------------------------------------
-- 3. Courses
-- ---------------------------------------------------------------------
INSERT INTO courses (course_id, course_name, course_code, duration_years, department_id, intake_capacity, annual_fee, eligibility, is_active) VALUES
(1, 'B.Tech in Computer Science and Engineering', 'CSE-BT-01', 4, 1, 120, 85000.00, 'Min 60% in 12th PCM & valid entrance rank', TRUE),
(2, 'B.Tech in Artificial Intelligence & Machine Learning', 'CSE-AI-02', 4, 1, 60, 95000.00, 'Min 65% in 12th PCM & valid entrance rank', TRUE),
(3, 'B.Tech in Electronics & Communication', 'ECE-BT-01', 4, 2, 90, 75000.00, 'Min 55% in 12th PCM & valid entrance rank', TRUE),
(4, 'B.Tech in VLSI & Embedded Systems', 'ECE-ES-02', 4, 2, 45, 80000.00, 'Min 60% in 12th PCM & valid entrance rank', TRUE),
(5, 'B.Tech in Mechanical Engineering', 'ME-BT-01', 4, 3, 60, 65000.00, 'Min 50% in 12th PCM & valid entrance rank', TRUE),
(6, 'B.Tech in Mechatronics & Automation', 'ME-MT-02', 4, 3, 40, 75000.00, 'Min 55% in 12th PCM & valid entrance rank', TRUE),
(7, 'B.Tech in Civil & Infrastructure Engineering', 'CE-BT-01', 4, 4, 60, 60000.00, 'Min 50% in 12th PCM & valid entrance rank', TRUE),
(8, 'B.Tech in Information Technology', 'IT-BT-01', 4, 5, 60, 80000.00, 'Min 60% in 12th PCM & valid entrance rank', TRUE);

-- ---------------------------------------------------------------------
-- 4. Tutors (Faculty Counselors)
-- ---------------------------------------------------------------------
INSERT INTO tutors (tutor_id, tutor_name, email, phone, qualification, department_id) VALUES
(1, 'Dr. Rajesh Sharma', 'rajesh.sharma@college.edu', '+91 98765 43210', 'Ph.D in Machine Learning (IIT Delhi)', 1),
(2, 'Prof. Ananya Sen', 'ananya.sen@college.edu', '+91 98765 43211', 'M.Tech in Software Systems (BITS Pilani)', 1),
(3, 'Dr. Vikram Rao', 'vikram.rao@college.edu', '+91 98765 43212', 'Ph.D in Microelectronics (IIT Madras)', 2),
(4, 'Prof. Sneha Verma', 'sneha.verma@college.edu', '+91 98765 43213', 'M.Tech in VLSI Design', 2),
(5, 'Dr. Arindam Mukherjee', 'arindam.m@college.edu', '+91 98765 43214', 'Ph.D in Robotics (IIT Kharagpur)', 3),
(6, 'Prof. Ramesh Patel', 'ramesh.patel@college.edu', '+91 98765 43215', 'M.Tech in Structural Engineering', 4),
(7, 'Dr. Pooja Nair', 'pooja.nair@college.edu', '+91 98765 43216', 'Ph.D in Distributed Systems', 5);

-- ---------------------------------------------------------------------
-- 5. Students
-- ---------------------------------------------------------------------
INSERT INTO students (student_id, name, gender, age, address, phone, email, `rank`, marks, tenth_marks, twelfth_marks, department_id) VALUES
(1, 'Aarav Mehta', 'Male', 18, 'Flat 402, Green Glen Layout, Bellandur, Bengaluru', '+91 91234 56789', 'aarav.mehta@example.com', 142, 94.50, 96.20, 95.00, 1),
(2, 'Diya Iyer', 'Female', 19, '34 Lake View Road, Anna Nagar, Chennai', '+91 92345 67890', 'diya.iyer@example.com', 285, 91.25, 93.40, 92.50, 1),
(3, 'Rohan Kulkarni', 'Male', 18, 'B-12 Swapna Nagari, Kothrud, Pune', '+91 93456 78901', 'rohan.k@example.com', 510, 88.00, 89.50, 87.00, 2),
(4, 'Ananya Deshmukh', 'Female', 19, '108 Hill Crest, Banjara Hills, Hyderabad', '+91 94567 89012', 'ananya.d@example.com', 630, 86.50, 90.00, 85.50, 2),
(5, 'Kabir Kapoor', 'Male', 18, 'Sector 15, Vashi, Navi Mumbai', '+91 95678 90123', 'kabir.k@example.com', 820, 83.75, 85.00, 82.00, 3),
(6, 'Ishita Roy', 'Female', 18, '72 Salt Lake City, Sector 2, Kolkata', '+91 96789 01234', 'ishita.roy@example.com', 950, 81.20, 88.40, 80.50, 5),
(7, 'Siddharth Nair', 'Male', 20, '45 Jawahar Nagar, Kadavanthra, Kochi', '+91 97890 12345', 'sid.nair@example.com', 1140, 78.50, 82.00, 77.00, 4),
(8, 'Tanvi Bansal', 'Female', 18, 'C-4 Rajouri Garden, New Delhi', '+91 98901 23456', 'tanvi.b@example.com', 315, 90.40, 94.00, 91.00, 1),
(9, 'Aryan Singhania', 'Male', 19, 'Plot 88, Civil Lines, Jaipur', '+91 99012 34567', 'aryan.s@example.com', 1420, 74.00, 78.50, 73.00, 3),
(10, 'Meera Nambiar', 'Female', 18, '12 Golf Links, Trivandrum', '+91 90123 45678', 'meera.n@example.com', 480, 88.90, 91.50, 89.20, 5);

-- ---------------------------------------------------------------------
-- 6. Hostels
-- ---------------------------------------------------------------------
INSERT INTO hostels (hostel_id, name, type, address, number_of_seats) VALUES
(1, 'Aryabhata Bhavan (Boys Hostel A)', 'Boys', 'North Campus, Block 1, University Grounds', 150),
(2, 'Sarabhai Bhavan (Boys Hostel B)', 'Boys', 'North Campus, Block 2, University Grounds', 120),
(3, 'Kalpana Chawla Hall (Girls Hostel A)', 'Girls', 'South Campus, Block 4, University Grounds', 150),
(4, 'Gargi Hall (Girls Hostel B)', 'Girls', 'South Campus, Block 5, University Grounds', 100);

-- ---------------------------------------------------------------------
-- 7. Buses
-- ---------------------------------------------------------------------
INSERT INTO buses (bus_id, bus_number, route, destination, capacity) VALUES
(1, 'BUS-01', 'Route 1: Electronic City -> Silk Board -> HSR Layout', 'University Campus Gate 1', 45),
(2, 'BUS-02', 'Route 2: Whitefield -> Marathahalli -> HAL', 'University Campus Gate 1', 50),
(3, 'BUS-03', 'Route 3: Yelahanka -> Hebbal -> RT Nagar', 'University Campus Gate 2', 45),
(4, 'BUS-04', 'Route 4: Rajajinagar -> Malleshwaram -> Majestic', 'University Campus Gate 2', 50),
(5, 'BUS-05', 'Route 5: Bannerghatta Road -> JP Nagar -> Jayanagar', 'University Campus Gate 3', 40);

-- ---------------------------------------------------------------------
-- 8. Applications
-- ---------------------------------------------------------------------
INSERT INTO applications (application_id, application_number, student_id, course_id, cycle_id, application_date, status, marks_obtained, maximum_marks, remarks, admin_remarks) VALUES
(1, 'APP-2026-0001', 1, 1, 1, '2026-06-01', 'APPROVED', 94.50, 100.00, 'Merit rank 142.', 'Verified and approved under Round 1 counseling.'),
(2, 'APP-2026-0002', 2, 2, 1, '2026-06-02', 'APPROVED', 91.25, 100.00, 'Merit rank 285.', 'Accepted seat in Artificial Intelligence.'),
(3, 'APP-2026-0003', 3, 3, 1, '2026-06-03', 'APPROVED', 88.00, 100.00, 'Counseling confirmed.', 'ECE seat confirmed.'),
(4, 'APP-2026-0004', 4, 4, 1, '2026-06-03', 'UNDER_REVIEW', 86.50, 100.00, 'Documents submitted.', 'Verification in progress with state board.'),
(5, 'APP-2026-0005', 5, 5, 1, '2026-06-04', 'APPROVED', 83.75, 100.00, 'Admitted to Mechanical.', 'Confirmed.'),
(6, 'APP-2026-0006', 6, 8, 1, '2026-06-04', 'WAITLISTED', 81.20, 100.00, 'Waitlist #14.', 'Awaiting vacancy in IT degree program.'),
(7, 'APP-2026-0007', 7, 7, 1, '2026-06-05', 'DOCUMENTS_REQUIRED', 78.50, 100.00, 'Missing 12th marksheet copy.', 'Requested upload of original passing certificate.'),
(8, 'APP-2026-0008', 8, 1, 1, '2026-06-05', 'APPROVED', 90.40, 100.00, 'Rank 315.', 'Approved.'),
(9, 'APP-2026-0009', 9, 6, 1, '2026-06-06', 'REJECTED', 74.00, 100.00, 'Below cutoff score.', 'Cutoff score not met for Mechatronics.'),
(10, 'APP-2026-0010', 10, 8, 1, '2026-06-06', 'APPROVED', 88.90, 100.00, 'Merit quota confirmed.', 'Confirmed seat in IT department.');

-- ---------------------------------------------------------------------
-- 9. Application Status History (Audit Trail)
-- ---------------------------------------------------------------------
INSERT INTO application_status_history (history_id, application_id, old_status, new_status, changed_by, remarks, changed_at) VALUES
(1, 1, 'SUBMITTED', 'APPROVED', 'Admission Officer', 'Documents verified and merit confirmed.', '2026-06-02 10:30:00'),
(2, 2, 'SUBMITTED', 'APPROVED', 'Admission Officer', 'Seat confirmed in AI & ML.', '2026-06-03 11:15:00'),
(3, 4, 'SUBMITTED', 'UNDER_REVIEW', 'Counselor', 'Sent to state verification board.', '2026-06-04 09:45:00'),
(4, 6, 'SUBMITTED', 'WAITLISTED', 'Admission Officer', 'Waitlist assigned due to high demand.', '2026-06-05 14:00:00'),
(5, 7, 'SUBMITTED', 'DOCUMENTS_REQUIRED', 'Verification Officer', 'Original mark sheet verification needed.', '2026-06-06 16:20:00'),
(6, 9, 'SUBMITTED', 'REJECTED', 'Admission Officer', 'Cutoff score requirement not met.', '2026-06-07 12:10:00');

-- ---------------------------------------------------------------------
-- 10. Hostel Allocations
-- ---------------------------------------------------------------------
INSERT INTO hostel_allocations (allocation_id, student_id, hostel_id, room_number, allocation_date, status) VALUES
(1, 1, 1, 'Room 101', '2026-06-15', 'Active'),
(2, 2, 3, 'Room 204', '2026-06-15', 'Active'),
(3, 3, 1, 'Room 102', '2026-06-16', 'Active'),
(4, 5, 2, 'Room 305', '2026-06-16', 'Active'),
(5, 8, 3, 'Room 205', '2026-06-17', 'Active'),
(6, 10, 4, 'Room 112', '2026-06-18', 'Active');

-- ---------------------------------------------------------------------
-- 11. Bus Allocations
-- ---------------------------------------------------------------------
INSERT INTO bus_allocations (allocation_id, student_id, bus_id, allocation_date, status) VALUES
(1, 4, 1, '2026-06-20', 'Active'),
(2, 6, 2, '2026-06-20', 'Active'),
(3, 7, 3, '2026-06-21', 'Active');

-- ---------------------------------------------------------------------
-- 12. Announcements
-- ---------------------------------------------------------------------
INSERT INTO announcements (announcement_id, title, content, published_by, is_published, published_at) VALUES
(1, 'Counseling Round 1 Document Verification Schedule', 'All candidates allocated seats in Round 1 are required to present original 10th and 12th board certificates at the Administrative Auditorium between 9:00 AM and 4:00 PM.', 'Dean of Academic Admissions', TRUE, '2026-06-01 09:00:00'),
(2, 'Hostel Allotment Guidelines for Academic Session 2026-27', 'Hostel accommodation check-ins for first-year admitted scholars commence on July 10, 2026. Please complete parent declaration forms before check-in.', 'Chief Warden', TRUE, '2026-06-05 11:30:00'),
(3, 'Campus Transit Fleet Bus Pass Registration Open', 'Commuter passes for University Bus Routes 1 through 5 are now open for online issuance through the transportation logistics desk.', 'Transport Coordinator', TRUE, '2026-06-10 14:00:00');

-- ---------------------------------------------------------------------
-- 13. Payments (Fee Records Ledger - Clearly Labeled)
-- ---------------------------------------------------------------------
INSERT INTO payments (payment_id, application_id, amount, currency, transaction_reference, status, paid_at) VALUES
(1, 1, 85000.00, 'INR', 'TXN-2026-CSE-89412', 'SUCCESS', '2026-06-02 11:00:00'),
(2, 2, 95000.00, 'INR', 'TXN-2026-AIML-91204', 'SUCCESS', '2026-06-03 12:30:00'),
(3, 3, 75000.00, 'INR', 'TXN-2026-ECE-48192', 'SUCCESS', '2026-06-04 15:45:00');

-- Keep enrollment assignments consistent with approved admissions.
UPDATE students s
LEFT JOIN applications a ON a.student_id = s.student_id AND a.status = 'APPROVED'
LEFT JOIN courses c ON c.course_id = a.course_id
SET s.department_id = c.department_id;
