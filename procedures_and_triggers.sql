-- =====================================================================
-- College Admission Management System — Stored Procedures, Functions & Triggers
-- Target RDBMS: MySQL 8.x (InnoDB Engine)
-- Academic Reference: B.Tech Computer Science & Engineering RDBMS Lab Project
-- =====================================================================

USE college_admission;

-- =====================================================================
-- 1. AUDIT LOGGING TABLE
-- Captures state transitions and system events for database accountability
-- =====================================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    record_id INT NOT NULL,
    details TEXT NULL,
    changed_by VARCHAR(100) DEFAULT 'system_admin',
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- 2. STORED FUNCTIONS
-- =====================================================================

DELIMITER $$

-- ---------------------------------------------------------------------
-- Function 1: fn_calculate_merit_score
-- Calculates weighted composite merit score:
-- 50% Entrance Marks + 25% 10th Marks + 25% 12th Marks
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_calculate_merit_score$$
CREATE FUNCTION fn_calculate_merit_score(
    p_marks DECIMAL(5,2),
    p_tenth DECIMAL(5,2),
    p_twelfth DECIMAL(5,2)
) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_composite DECIMAL(5,2);
    SET v_composite = (p_marks * 0.50) + (p_tenth * 0.25) + (p_twelfth * 0.25);
    RETURN ROUND(v_composite, 2);
END$$

-- ---------------------------------------------------------------------
-- Function 2: fn_hostel_available_beds
-- Calculates remaining available beds in a designated hostel
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_hostel_available_beds$$
CREATE FUNCTION fn_hostel_available_beds(p_hostel_id INT) 
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total_capacity INT DEFAULT 0;
    DECLARE v_occupied INT DEFAULT 0;
    
    SELECT number_of_seats INTO v_total_capacity
    FROM hostels
    WHERE hostel_id = p_hostel_id;
    
    SELECT COUNT(*) INTO v_occupied
    FROM hostel_allocations
    WHERE hostel_id = p_hostel_id AND status = 'Active';
    
    RETURN (v_total_capacity - v_occupied);
END$$

-- ---------------------------------------------------------------------
-- Function 3: fn_bus_available_seats
-- Calculates remaining available passenger seats in a transit bus
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_bus_available_seats$$
CREATE FUNCTION fn_bus_available_seats(p_bus_id INT) 
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total_capacity INT DEFAULT 0;
    DECLARE v_occupied INT DEFAULT 0;
    
    SELECT capacity INTO v_total_capacity
    FROM buses
    WHERE bus_id = p_bus_id;
    
    SELECT COUNT(*) INTO v_occupied
    FROM bus_allocations
    WHERE bus_id = p_bus_id AND status = 'Active';
    
    RETURN (v_total_capacity - v_occupied);
END$$

-- =====================================================================
-- 3. STORED PROCEDURES
-- =====================================================================

-- ---------------------------------------------------------------------
-- Procedure 1: sp_approve_application
-- Atomically validates and approves a student admission application:
-- 1. Checks current status
-- 2. Checks course intake capacity
-- 3. Transitions status to 'Approved'
-- 4. Enrolls applicant student into the degree department
-- 5. Emits transaction commit or rollback on exception
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_approve_application$$
CREATE PROCEDURE sp_approve_application(
    IN p_application_id INT,
    IN p_remarks TEXT,
    OUT p_result_status VARCHAR(50)
)
BEGIN
    DECLARE v_student_id INT;
    DECLARE v_course_id INT;
    DECLARE v_dept_id INT;
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_approved_count INT;
    DECLARE v_capacity INT;

    -- Error handler: rollback transaction on SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_status = 'ERROR: Transaction rolled back due to SQL exception';
    END;

    START TRANSACTION;

    -- Retrieve application details with row lock
    SELECT a.student_id, a.course_id, a.status, c.department_id, c.intake_capacity
    INTO v_student_id, v_course_id, v_current_status, v_dept_id, v_capacity
    FROM applications a
    JOIN courses c ON a.course_id = c.course_id
    WHERE a.application_id = p_application_id
    FOR UPDATE;

    IF v_student_id IS NULL THEN
        SET p_result_status = 'NOT_FOUND';
        ROLLBACK;
    ELSEIF v_current_status = 'APPROVED' THEN
        SET p_result_status = 'ALREADY_APPROVED';
        ROLLBACK;
    ELSE
        -- Verify course capacity has not been breached
        SELECT COUNT(*) INTO v_approved_count
        FROM applications
        WHERE course_id = v_course_id AND status = 'APPROVED';

        IF v_approved_count >= v_capacity THEN
            SET p_result_status = 'CAPACITY_FULL';
            ROLLBACK;
        ELSE
            -- Approve application
            UPDATE applications 
            SET status = 'APPROVED', 
                remarks = COALESCE(p_remarks, remarks),
                updated_at = CURRENT_TIMESTAMP
            WHERE application_id = p_application_id;

            -- Assign department to student
            UPDATE students
            SET department_id = v_dept_id,
                updated_at = CURRENT_TIMESTAMP
            WHERE student_id = v_student_id;

            -- The status trigger writes audit_logs; write the application timeline once.
            INSERT INTO application_status_history (application_id, old_status, new_status, changed_by, remarks)
            VALUES (p_application_id, v_current_status, 'APPROVED', CURRENT_USER(), COALESCE(p_remarks, 'Approved by stored procedure'));

            COMMIT;
            SET p_result_status = 'SUCCESS';
        END IF;
    END IF;
END$$

-- ---------------------------------------------------------------------
-- Procedure 2: sp_allocate_hostel
-- Atomically allocates a bed to an applicant if vacancy permits
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_allocate_hostel$$
CREATE PROCEDURE sp_allocate_hostel(
    IN p_student_id INT,
    IN p_hostel_id INT,
    IN p_room_number VARCHAR(20),
    OUT p_result VARCHAR(100)
)
BEGIN
    DECLARE v_available INT;
    DECLARE v_active_count INT;
    DECLARE v_student_id INT DEFAULT NULL;
    DECLARE v_capacity INT DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'ERROR: Transaction rolled back';
    END;

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;
    SELECT student_id INTO v_student_id FROM students
    WHERE student_id = p_student_id FOR UPDATE;
    SELECT number_of_seats INTO v_capacity FROM hostels
    WHERE hostel_id = p_hostel_id FOR UPDATE;

    IF v_student_id IS NULL OR v_capacity IS NULL THEN
        SET p_result = 'NOT_FOUND';
        ROLLBACK;
    ELSE
        SELECT COUNT(*) INTO v_active_count
        FROM hostel_allocations WHERE student_id = p_student_id AND status = 'Active';
        IF v_active_count > 0 THEN
            SET p_result = 'STUDENT_ALREADY_ALLOCATED';
            ROLLBACK;
        ELSE
            SET v_available = fn_hostel_available_beds(p_hostel_id);
            IF v_available <= 0 THEN
                SET p_result = 'HOSTEL_CAPACITY_FULL';
                ROLLBACK;
            ELSE
                INSERT INTO hostel_allocations (student_id, hostel_id, room_number, allocation_date, status)
                VALUES (p_student_id, p_hostel_id, p_room_number, CURRENT_DATE(), 'Active');
                INSERT INTO audit_logs (table_name, action_type, record_id, details)
                VALUES ('hostel_allocations', 'INSERT', LAST_INSERT_ID(), CONCAT('Student #', p_student_id, ' allocated to hostel #', p_hostel_id));
                COMMIT;
                SET p_result = 'SUCCESS';
            END IF;
        END IF;
    END IF;
END$$

-- ---------------------------------------------------------------------
-- Procedure 3: sp_department_enrollment_report
-- Generates structured breakdown of all courses, students, and tutors in a department
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_department_enrollment_report$$
CREATE PROCEDURE sp_department_enrollment_report(IN p_dept_id INT)
BEGIN
    -- 1. Department Overview
    SELECT 
        d.department_id,
        d.department_name,
        d.code,
        COUNT(DISTINCT c.course_id) AS total_courses,
        COUNT(DISTINCT t.tutor_id) AS total_tutors,
        COUNT(DISTINCT s.student_id) AS total_students,
        ROUND(AVG(s.marks), 2) AS average_entrance_marks
    FROM departments d
    LEFT JOIN courses c ON d.department_id = c.department_id
    LEFT JOIN tutors t ON d.department_id = t.department_id
    LEFT JOIN students s ON d.department_id = s.department_id
    WHERE d.department_id = p_dept_id
    GROUP BY d.department_id, d.department_name, d.code;

    -- 2. Enrolled Students in this department
    SELECT 
        s.student_id,
        s.name,
        s.email,
        s.marks,
        s.rank,
        fn_calculate_merit_score(s.marks, s.tenth_marks, s.twelfth_marks) AS composite_merit_score
    FROM students s
    WHERE s.department_id = p_dept_id
    ORDER BY s.marks DESC;
END$$

-- =====================================================================
-- 4. DATABASE TRIGGERS
-- =====================================================================

-- ---------------------------------------------------------------------
-- Trigger 1: trg_check_hostel_capacity_before_insert
-- Enforces capacity constraint at the relational level before row insert
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_check_hostel_capacity_before_insert$$
CREATE TRIGGER trg_check_hostel_capacity_before_insert
BEFORE INSERT ON hostel_allocations
FOR EACH ROW
BEGIN
    DECLARE v_available INT;
    IF NEW.status = 'Active' THEN
        SET v_available = fn_hostel_available_beds(NEW.hostel_id);
        IF v_available <= 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hostel bed allocation rejected: Facility has reached full capacity.';
        END IF;
    END IF;
END$$

-- ---------------------------------------------------------------------
-- Trigger 2: trg_check_bus_capacity_before_insert
-- Enforces transit bus seat capacity constraint before allocation insert
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_check_bus_capacity_before_insert$$
CREATE TRIGGER trg_check_bus_capacity_before_insert
BEFORE INSERT ON bus_allocations
FOR EACH ROW
BEGIN
    DECLARE v_available INT;
    IF NEW.status = 'Active' THEN
        SET v_available = fn_bus_available_seats(NEW.bus_id);
        IF v_available <= 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Bus seat pass allocation rejected: Vehicle is at full seating capacity.';
        END IF;
    END IF;
END$$

-- ---------------------------------------------------------------------
-- Trigger 3: trg_audit_application_status_change
-- Audit log trigger whenever an admission application status changes
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_application_status_change$$
CREATE TRIGGER trg_audit_application_status_change
AFTER UPDATE ON applications
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_logs (table_name, action_type, record_id, details)
        VALUES (
            'applications', 
            'UPDATE', 
            NEW.application_id, 
            CONCAT('Status changed from "', OLD.status, '" to "', NEW.status, '". Remarks: ', COALESCE(NEW.remarks, 'None'))
        );
    END IF;
END$$

DELIMITER ;
