-- ======================================================
-- Clinic Booking System Database
-- ======================================================

-- 1. Create Database
CREATE DATABASE IF NOT EXISTS clinic_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE clinic_db;

-- 2. Doctors Table
CREATE TABLE doctors (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  specialization VARCHAR(150),
  phone VARCHAR(30),
  email VARCHAR(150) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Patients Table
CREATE TABLE patients (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  date_of_birth DATE,
  gender ENUM('Male','Female','Other') DEFAULT 'Other',
  phone VARCHAR(30),
  email VARCHAR(150) UNIQUE,
  address VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



-- 4. Services Table (e.g., consultation, vaccination)
CREATE TABLE services (
  service_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  description VARCHAR(500),
  price DECIMAL(10,2) DEFAULT 0.00
);

-- 5. Appointments Table
CREATE TABLE appointments (
  appointment_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  doctor_id INT NOT NULL,
  appointment_date DATETIME NOT NULL,
  duration_minutes INT DEFAULT 30,
  status ENUM('Scheduled','Completed','Cancelled','No-Show') DEFAULT 'Scheduled',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- Foreign Keys
  CONSTRAINT fk_appointment_patient
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_appointment_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  -- Prevents double-booking a doctor at the same time
  UNIQUE KEY ux_doctor_datetime (doctor_id, appointment_date)
);

-- 6. Many-to-Many: Appointment Services
CREATE TABLE appointment_services (
  appointment_id INT NOT NULL,
  service_id INT NOT NULL,
  quantity INT DEFAULT 1,
  PRIMARY KEY (appointment_id, service_id),
  CONSTRAINT fk_as_appointment FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_as_service FOREIGN KEY (service_id)
    REFERENCES services(service_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 7. Prescriptions Table (linked to an appointment)
CREATE TABLE prescriptions (
  prescription_id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL,
  medication VARCHAR(255) NOT NULL,
  dosage VARCHAR(255),
  instructions TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_prescription_appointment FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8. Useful Indexes
CREATE INDEX idx_patient_name ON patients(last_name, first_name);
CREATE INDEX idx_doctor_specialization ON doctors(specialization);

-- ======================================================
-- Sample Data (Optional)
-- ======================================================
INSERT INTO doctors (first_name, last_name, specialization, phone, email)
VALUES ('Grace','Mwangi','General Practitioner','+254700111222','g.mwangi@clinic.com');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, phone, email, address)
VALUES ('Lynn','Kurwa','2000-01-01','Female','+254712345678','lynn@example.com','Nairobi');

INSERT INTO services (name, description, price) VALUES
('General Consultation','Standard consultation with doctor', 500.00),
('Vaccination','Routine vaccination service', 800.00);
