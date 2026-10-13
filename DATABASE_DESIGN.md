# Database design

The source of truth is database/schema.sql. The fresh database contains 16 base tables, InnoDB storage, utf8mb4 text and a single authoritative capacity field per facility/course.

## users

```sql
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NULL,
    role ENUM('ADMIN', 'APPLICANT') NOT NULL DEFAULT 'ADMIN',
    account_status ENUM('ACTIVE', 'SUSPENDED', 'PENDING') NOT NULL DEFAULT 'ACTIVE',
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## admins

```sql
CREATE TABLE admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    admin_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## departments

```sql
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(10) NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## courses

```sql
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(120) NOT NULL,
    course_code VARCHAR(20) NULL,
    duration_years INT DEFAULT 4 CHECK (duration_years > 0),
    department_id INT NOT NULL,
    intake_capacity INT DEFAULT 60 CHECK (intake_capacity > 0),
    annual_fee DECIMAL(10,2) DEFAULT 75000.00 CHECK (annual_fee >= 0),
    eligibility TEXT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_courses_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uk_dept_course_name UNIQUE (department_id, course_name)
) ENGINE=InnoDB;
```

## tutors

```sql
CREATE TABLE tutors (
    tutor_id INT AUTO_INCREMENT PRIMARY KEY,
    tutor_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    qualification VARCHAR(100) DEFAULT 'M.Tech / Ph.D',
    department_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tutors_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
```

## students

```sql
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    name VARCHAR(100) NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    age INT NOT NULL CHECK (age >= 15 AND age <= 60),
    address TEXT NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    `rank` INT NULL CHECK (`rank` > 0),
    marks DECIMAL(5,2) NOT NULL CHECK (marks >= 0.00 AND marks <= 100.00),
    tenth_marks DECIMAL(5,2) NOT NULL CHECK (tenth_marks >= 0.00 AND tenth_marks <= 100.00),
    twelfth_marks DECIMAL(5,2) NOT NULL CHECK (twelfth_marks >= 0.00 AND twelfth_marks <= 100.00),
    department_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_students_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_students_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
```

## admission_cycles

```sql
CREATE TABLE admission_cycles (
    cycle_id INT AUTO_INCREMENT PRIMARY KEY,
    cycle_name VARCHAR(100) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('UPCOMING', 'ACTIVE', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_cycle_dates CHECK (end_date >= start_date)
) ENGINE=InnoDB;
```

## applications

```sql
CREATE TABLE applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    application_number VARCHAR(50) NOT NULL UNIQUE,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    cycle_id INT NULL,
    application_date DATE NOT NULL,
    status ENUM('DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'DOCUMENTS_REQUIRED', 'APPROVED', 'REJECTED', 'WAITLISTED', 'WITHDRAWN') NOT NULL DEFAULT 'SUBMITTED',
    marks_obtained DECIMAL(5,2) NULL,
    maximum_marks DECIMAL(5,2) DEFAULT 100.00,
    reviewed_by INT NULL,
    reviewed_at TIMESTAMP NULL,
    remarks TEXT NULL,
    admin_remarks TEXT NULL,
    approved_student_id INT GENERATED ALWAYS AS (CASE WHEN status = 'APPROVED' THEN student_id ELSE NULL END) VIRTUAL,
    UNIQUE KEY uq_approved_admission (approved_student_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_applications_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_applications_course
        FOREIGN KEY (course_id) REFERENCES courses(course_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_applications_cycle
        FOREIGN KEY (cycle_id) REFERENCES admission_cycles(cycle_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    cycle_key INT GENERATED ALWAYS AS (COALESCE(cycle_id, 0)) VIRTUAL,
    CONSTRAINT uk_student_course_cycle UNIQUE (student_id, course_id, cycle_key)
) ENGINE=InnoDB;
```

## application_status_history

```sql
CREATE TABLE application_status_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    old_status VARCHAR(50) NULL,
    new_status VARCHAR(50) NOT NULL,
    changed_by VARCHAR(100) DEFAULT 'admin',
    remarks TEXT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_application
        FOREIGN KEY (application_id) REFERENCES applications(application_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
```

## hostels

```sql
CREATE TABLE hostels (
    hostel_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    type ENUM('Boys', 'Girls', 'Co-ed') DEFAULT 'Co-ed',
    address TEXT NOT NULL,
    number_of_seats INT NOT NULL CHECK (number_of_seats > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## hostel_allocations

```sql
CREATE TABLE hostel_allocations (
    allocation_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    hostel_id INT NOT NULL,
    room_number VARCHAR(20) NULL,
    allocation_date DATE NOT NULL,
    status ENUM('Active', 'Vacated') NOT NULL DEFAULT 'Active',
    active_student_id INT GENERATED ALWAYS AS (CASE WHEN status = 'Active' THEN student_id ELSE NULL END) VIRTUAL,
    UNIQUE KEY uq_active_hostel (active_student_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_hostel_alloc_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_hostel_alloc_hostel
        FOREIGN KEY (hostel_id) REFERENCES hostels(hostel_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
```

## buses

```sql
CREATE TABLE buses (
    bus_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(50) NOT NULL UNIQUE,
    route VARCHAR(150) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## bus_allocations

```sql
CREATE TABLE bus_allocations (
    allocation_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    bus_id INT NOT NULL,
    allocation_date DATE NOT NULL,
    status ENUM('Active', 'Cancelled') NOT NULL DEFAULT 'Active',
    active_student_id INT GENERATED ALWAYS AS (CASE WHEN status = 'Active' THEN student_id ELSE NULL END) VIRTUAL,
    UNIQUE KEY uq_active_bus (active_student_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bus_alloc_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bus_alloc_bus
        FOREIGN KEY (bus_id) REFERENCES buses(bus_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
```

## announcements

```sql
CREATE TABLE announcements (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    published_by VARCHAR(100) DEFAULT 'Admission Directorate',
    is_published BOOLEAN DEFAULT TRUE,
    published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## payments

```sql
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(10) DEFAULT 'INR',
    transaction_reference VARCHAR(100) NOT NULL UNIQUE,
    status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'SUCCESS',
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_application
        FOREIGN KEY (application_id) REFERENCES applications(application_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
```

## audit_logs

```sql
CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    record_id INT NOT NULL,
    details TEXT NULL,
    changed_by VARCHAR(100) DEFAULT 'system_admin',
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## Derived values and rules

Occupancy and department counts are calculated through views. Generated keys enforce one approved admission and active allocation per student. cycle_key implements duplicate application protection when cycle_id is NULL. Statuses are uppercase in applications; hostel/bus allocation statuses retain Active/Vacated/Cancelled.

See procedures_and_triggers.sql for optional academic routines/triggers. API transactions enforce admission and allocation rules for both creation and reactivation. MySQL checks, unique and foreign keys provide further protection.
