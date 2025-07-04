/*Adding triggers for auto-genration of primary keys*/
DELIMITER $$

-- Trigger for patient table: Format 'p' + three digits
CREATE TRIGGER before_patient_insert
BEFORE INSERT ON patient
FOR EACH ROW
BEGIN
    DECLARE max_id INT;
    IF NEW.patient_id IS NULL OR NEW.patient_id NOT REGEXP '^p[0-9]{3}$' THEN
        SELECT IFNULL(MAX(CAST(SUBSTRING(patient_id,2) AS UNSIGNED)), 0)
            INTO max_id FROM patient;
        SET max_id = max_id + 1;
        SET NEW.patient_id = CONCAT('p', LPAD(max_id,3,'0'));
    END IF;
END$$

-- Trigger for department table: Format 'dep' + three digits
CREATE TRIGGER before_department_insert
BEFORE INSERT ON department
FOR EACH ROW
BEGIN
    DECLARE max_dep INT;
    IF NEW.department_id IS NULL OR NEW.department_id NOT REGEXP '^dep[0-9]{3}$' THEN
        SELECT IFNULL(MAX(CAST(SUBSTRING(department_id,4) AS UNSIGNED)), 0)
            INTO max_dep FROM department;
        SET max_dep = max_dep + 1;
        SET NEW.department_id = CONCAT('dep', LPAD(max_dep,3,'0'));
    END IF;
END$$

-- Trigger for doctor table: Format 'doc' + three digits
CREATE TRIGGER before_doctor_insert
BEFORE INSERT ON doctor
FOR EACH ROW
BEGIN
    DECLARE max_doc INT;
    IF NEW.doctor_id IS NULL OR NEW.doctor_id NOT REGEXP '^doc[0-9]{3}$' THEN
        SELECT IFNULL(MAX(CAST(SUBSTRING(doctor_id,4) AS UNSIGNED)), 0)
            INTO max_doc FROM doctor;
        SET max_doc = max_doc + 1;
        SET NEW.doctor_id = CONCAT('doc', LPAD(max_doc,3,'0'));
    END IF;
END$$

-- Trigger for insurance table: Format 'i' + three digits
CREATE TRIGGER before_insurance_insert
BEFORE INSERT ON insurance
FOR EACH ROW
BEGIN
    DECLARE max_ins INT;
    IF NEW.insurance_id IS NULL OR NEW.insurance_id NOT REGEXP '^i[0-9]{3}$' THEN
        SELECT IFNULL(MAX(CAST(SUBSTRING(insurance_id,2) AS UNSIGNED)), 0)
            INTO max_ins FROM insurance;
        SET max_ins = max_ins + 1;
        SET NEW.insurance_id = CONCAT('i', LPAD(max_ins,3,'0'));
    END IF;
END$$

-- Trigger for appointment table: Format 'a' + three digits
CREATE TRIGGER before_appointment_insert
BEFORE INSERT ON appointment
FOR EACH ROW
BEGIN
    DECLARE max_app INT;
    IF NEW.appointment_id IS NULL OR NEW.appointment_id NOT REGEXP '^a[0-9]{3}$' THEN
        SELECT IFNULL(MAX(CAST(SUBSTRING(appointment_id,2) AS UNSIGNED)), 0)
            INTO max_app FROM appointment;
        SET max_app = max_app + 1;
        SET NEW.appointment_id = CONCAT('a', LPAD(max_app,3,'0'));
    END IF;
END$$

-- Trigger for billing table: Format 'b' + three digits
CREATE TRIGGER before_billing_insert
BEFORE INSERT ON billing
FOR EACH ROW
BEGIN
    DECLARE max_bill INT;
    IF NEW.bill_id IS NULL OR NEW.bill_id NOT REGEXP '^b[0-9]{3}$' THEN
        SELECT IFNULL(MAX(CAST(SUBSTRING(bill_id,2) AS UNSIGNED)), 0)
            INTO max_bill FROM billing;
        SET max_bill = max_bill + 1;
        SET NEW.bill_id = CONCAT('b', LPAD(max_bill,3,'0'));
    END IF;
END$$

-- Trigger for medicine table: Format 'm' + three digits
CREATE TRIGGER before_medicine_insert
BEFORE INSERT ON medicine
FOR EACH ROW
BEGIN
    DECLARE max_med INT;
    IF NEW.medicine_id IS NULL OR NEW.medicine_id NOT REGEXP '^m[0-9]{3}$' THEN
        SELECT IFNULL(MAX(CAST(SUBSTRING(medicine_id,2) AS UNSIGNED)), 0)
            INTO max_med FROM medicine;
        SET max_med = max_med + 1;
        SET NEW.medicine_id = CONCAT('m', LPAD(max_med,3,'0'));
    END IF;
END$$

DELIMITER ;

/*Adding soft delete cascade triggers*/
DELIMITER $$

/* 
Trigger: Cascade soft delete from Patient to Appointment, Billing, and Patient_Insurance.
When a patient is soft-deleted (is_deleted changes from 0 to 1), all related records are marked as deleted.
*/
CREATE TRIGGER after_patient_soft_delete
AFTER UPDATE ON patient
FOR EACH ROW
BEGIN
    IF NEW.is_deleted = b'1' AND OLD.is_deleted = b'0' THEN
         UPDATE appointment 
         SET is_deleted = b'1'
         WHERE patient_id = NEW.patient_id;
         
         UPDATE billing 
         SET is_deleted = b'1'
         WHERE patient_id = NEW.patient_id;
         
         UPDATE patient_insurance 
         SET is_deleted = b'1'
         WHERE patient_id = NEW.patient_id;
    END IF;
END$$

/* 
Trigger: Cascade soft delete from Doctor to Appointment.
When a doctor is soft-deleted, all appointments for that doctor are marked as deleted.
*/
CREATE TRIGGER after_doctor_soft_delete
AFTER UPDATE ON doctor
FOR EACH ROW
BEGIN
    IF NEW.is_deleted = b'1' AND OLD.is_deleted = b'0' THEN
         UPDATE appointment
         SET is_deleted = b'1'
         WHERE doctor_id = NEW.doctor_id;
    END IF;
END$$

/* 
Trigger: Cascade soft delete from Department to Doctor.
When a department is soft-deleted, all doctors in that department are marked as deleted.
*/
CREATE TRIGGER after_department_soft_delete
AFTER UPDATE ON department
FOR EACH ROW
BEGIN
    IF NEW.is_deleted = b'1' AND OLD.is_deleted = b'0' THEN
         UPDATE doctor
         SET is_deleted = b'1'
         WHERE department_id = NEW.department_id;
    END IF;
END$$

/* 
Trigger: Cascade soft delete from Insurance to Patient_Insurance.
When an insurance record is soft-deleted, all associated patient_insurance records are marked as deleted.
*/
CREATE TRIGGER after_insurance_soft_delete
AFTER UPDATE ON insurance
FOR EACH ROW
BEGIN
    IF NEW.is_deleted = b'1' AND OLD.is_deleted = b'0' THEN
         UPDATE patient_insurance
         SET is_deleted = b'1'
         WHERE insurance_id = NEW.insurance_id;
    END IF;
END$$

/* 
Trigger: Cascade soft delete from Appointment to Billing.
When an appointment is soft-deleted, its billing record is marked as deleted.
*/
CREATE TRIGGER after_appointment_soft_delete
AFTER UPDATE ON appointment
FOR EACH ROW
BEGIN
    IF NEW.is_deleted = b'1' AND OLD.is_deleted = b'0' THEN
         UPDATE billing
         SET is_deleted = b'1'
         WHERE appointment_id = NEW.appointment_id;
    END IF;
END$$

/* 
Trigger: Cascade soft delete from Billing to Billing_Medicine.
When a billing record is soft-deleted, all related billing_medicine records are marked as deleted.
*/
CREATE TRIGGER after_billing_soft_delete
AFTER UPDATE ON billing
FOR EACH ROW
BEGIN
    IF NEW.is_deleted = b'1' AND OLD.is_deleted = b'0' THEN
         UPDATE billing_medicine
         SET is_deleted = b'1'
         WHERE bill_id = NEW.bill_id;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

/* 
Decription: A procedure that updates the payment status for a specific billing record.
Error Handling: Checks that the billing ID and status are not NULL and that the billing record exists.
*/
CREATE PROCEDURE update_billing_status(
    IN in_bill_id VARCHAR(5),
    IN in_status ENUM('Pending','Paid')
)
BEGIN
    -- Check for NULL inputs
    IF in_bill_id IS NULL OR in_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Billing ID and Status cannot be NULL.';
    END IF;
    
    -- Check that the billing record exists
    IF NOT EXISTS (SELECT 1 FROM billing WHERE bill_id = in_bill_id AND is_deleted = b'0') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Billing record not found or already deleted.';
    END IF;
    
    UPDATE billing
    SET payment_status = in_status
    WHERE bill_id = in_bill_id 
      AND is_deleted = b'0';
END$$

/* 
Decription: A procedure that books an appointment by inserting a new record after checking if the doctor is available.
Error Handling: Checks that all required inputs are provided (non-NULL) and that the doctor exists and is available.
*/
CREATE PROCEDURE book_appointment(
    IN in_patient_id VARCHAR(5),
    IN in_doctor_id VARCHAR(6),
    IN in_date DATE,
    IN in_time TIME,
    IN in_diagnosis MEDIUMTEXT,
    IN in_prescription MEDIUMTEXT,
    IN in_status ENUM('Walk-In','Scheduled','Completed','Cancelled')
)
BEGIN
    DECLARE cnt INT DEFAULT 0;

    -- Null and validity checks for inputs
    IF in_patient_id IS NULL OR in_doctor_id IS NULL OR in_date IS NULL OR in_time IS NULL OR in_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient ID, Doctor ID, Date, Time, and Status are required.';
    END IF;
    
    -- Check if doctor exists and is not soft-deleted
    IF NOT EXISTS (SELECT 1 FROM doctor WHERE doctor_id = in_doctor_id AND is_deleted = b'0') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor not found or is deleted.';
    END IF;
    
    -- Check if patient exists and is not soft-deleted
    IF NOT EXISTS (SELECT 1 FROM patient WHERE patient_id = in_patient_id AND is_deleted = b'0') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient not found or is deleted.';
    END IF;
    
    -- Check if the doctor already has an appointment at the specified date and time.
    SELECT COUNT(*) INTO cnt
    FROM appointment
    WHERE doctor_id = in_doctor_id
      AND appointment_date = in_date
      AND appointment_time = in_time
      AND is_deleted = b'0';
      
    IF cnt > 0 THEN
         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor is not available at this time.';
    ELSE
         INSERT INTO appointment(
             patient_id, doctor_id, appointment_date, appointment_time, 
             diagnosis, prescription, status, is_deleted
         )
         VALUES(
             in_patient_id, in_doctor_id, in_date, in_time, 
             in_diagnosis, in_prescription, in_status, b'0'
         );
    END IF;
END$$

/*
Decription: A procedure that retrieves the billing details (total bill) for the patient’s who have scheduled appointment.
Error Handling: Checks for NULL patient ID and existence of a scheduled appointment.
*/
CREATE PROCEDURE get_patient_current_bill(
    IN in_patient_id VARCHAR(5)
)
BEGIN
    IF in_patient_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient ID cannot be NULL.';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM appointment WHERE patient_id = in_patient_id AND status = 'Scheduled' AND is_deleted = b'0') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No scheduled appointment found for this patient.';
    END IF;
    
    SELECT 
      b.bill_id,
      b.total_amount,
      b.payment_status,
      a.appointment_date,
      a.appointment_time
   FROM billing b
   INNER JOIN appointment a ON b.appointment_id = a.appointment_id
   WHERE b.patient_id = in_patient_id 
     AND a.status = 'Scheduled'
     AND b.is_deleted = b'0'
     AND a.is_deleted = b'0'
   ORDER BY a.appointment_date ASC
   LIMIT 1;
END$$

/* 
Decription: A procedure that generates a summary report of all appointments for a given patient with the associated doctor between two dates.
Error Handling: Checks for NULL patient ID, valid date range, and existence of appointments.
*/
CREATE PROCEDURE generate_patient_appointment_summary(
    IN in_patient_id VARCHAR(5),
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    IF in_patient_id IS NULL OR start_date IS NULL OR end_date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient ID and date range cannot be NULL.';
    END IF;
    
    IF start_date > end_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Start date must be before or equal to end date.';
    END IF;
    
    SELECT 
        a.appointment_id,
        a.appointment_date,
        a.appointment_time,
        a.status,
        CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
        a.diagnosis,
        a.prescription
    FROM appointment a
    INNER JOIN doctor d ON a.doctor_id = d.doctor_id
    WHERE a.patient_id = in_patient_id
      AND a.appointment_date BETWEEN start_date AND end_date
      AND a.is_deleted = b'0';
END$$

/* 
Decription: Function that calculates and returns the age of a patient based on their date of birth.
Error Handling: Checks for NULL patient ID and existence of the patient.
*/
CREATE FUNCTION calculate_patient_age(in_patient_id VARCHAR(5))
RETURNS INT 
READS SQL DATA
BEGIN
   DECLARE dob DATE;
   DECLARE age INT;
   
   IF in_patient_id IS NULL THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient ID cannot be NULL.';
   END IF;
   
   SELECT date_of_birth INTO dob 
   FROM patient 
   WHERE patient_id = in_patient_id 
     AND is_deleted = b'0';
     
   IF dob IS NULL THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient not found or has no date of birth.';
   END IF;
     
   SET age = TIMESTAMPDIFF(YEAR, dob, CURDATE());
   RETURN age;
END$$

/* 
Decription: Function that returns the number of appointments for a given doctor on a specific day.
Error Handling: Checks for NULL doctor ID or date.
*/
CREATE FUNCTION count_doctor_appointments(in_doctor_id VARCHAR(6), in_date DATE)
RETURNS INT 
READS SQL DATA
BEGIN
   DECLARE appt_count INT;
   
   IF in_doctor_id IS NULL OR in_date IS NULL THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor ID and Date cannot be NULL.';
   END IF;
   
   SELECT COUNT(*) INTO appt_count
   FROM appointment
   WHERE doctor_id = in_doctor_id 
     AND appointment_date = in_date
     AND is_deleted = b'0';
     
   RETURN appt_count;
END$$

DELIMITER ;

/*
-- Testing update_billing_status Procedure
-- Success Test:
-- Before update, check billing record b002.
SELECT * FROM billing WHERE bill_id = 'b002';
-- Update billing status for bill b002 from 'Pending' to 'Paid'
CALL update_billing_status('b002', 'Paid');
-- Verify update:
SELECT * FROM billing WHERE bill_id = 'b002';

-- Failure Test:
-- Pass a NULL billing ID (should trigger an error)
CALL update_billing_status(NULL, 'Paid');
-- Pass a non-existent billing id (assuming b999 does not exist)
CALL update_billing_status('b999', 'Paid');

--*******************************************************
-- Testing book_appointment Procedure
-- Success Test:
-- Book an appointment for patient 'p001' with doctor 'doc001' on an available slot.
CALL book_appointment('p001', 'doc001', '2025-12-25', '15:00:00', 'Routine Check', 'None', 'Scheduled');
-- Verify the new appointment:
SELECT * FROM appointment 
WHERE patient_id = 'p001' 
  AND appointment_date = '2025-12-25'
  AND appointment_time = '15:00:00';

-- Failure Test:
-- Attempt to book with a NULL parameter (e.g., missing doctor_id)
CALL book_appointment('p001', NULL, '2025-12-25', '15:00:00', 'Routine Check', 'None', 'Scheduled');
-- Attempt to book when the doctor already has an appointment at that slot.
-- (Assuming doctor 'doc002' already has an appointment on '2025-12-02' at '10:00:00' as per our sample data)
CALL book_appointment('p003', 'doc002', '2025-12-02', '10:00:00', 'Follow-up', 'Medication A', 'Scheduled');

-- *******************************************

-- Testing get_patient_current_bill Procedure
-- Success Test:
-- Retrieve the current bill for patient 'p001' (should return the scheduled appointment's billing details)
CALL get_patient_current_bill('p001');

-- Failure Test:
-- Pass a NULL patient ID.
CALL get_patient_current_bill(NULL);
-- Pass a patient ID with no scheduled appointment (assuming 'p999' doesn't exist or has no scheduled appointment)
CALL get_patient_current_bill('p999');

--***************************************************
-- Testing generate_patient_appointment_summary Procedure
-- Success Test:
-- Generate an appointment summary for patient 'p005' between '2025-01-01' and '2025-12-31'
CALL generate_patient_appointment_summary('p005', '2025-01-01', '2025-12-31');

-- Failure Test:
-- Pass a NULL patient ID.
CALL generate_patient_appointment_summary(NULL, '2025-01-01', '2025-12-31');
-- Pass an invalid date range (start date after end date)
CALL generate_patient_appointment_summary('p005', '2025-12-31', '2025-01-01');

--**************************************
-- Testing calculate_patient_age Function
-- Success Test:
-- Calculate and display the age for patient 'p001'
SELECT calculate_patient_age('p001') AS age;

-- Failure Test:
-- Pass a NULL patient ID (should trigger an error)
SELECT calculate_patient_age(NULL) AS age;
-- Pass a non-existent patient ID (assuming 'p999' does not exist)
SELECT calculate_patient_age('p999') AS age;

--********************************************
-- Testing count_doctor_appointments Function
-- Success Test:
-- Count the number of appointments for doctor 'doc001' on '2025-03-21'
SELECT count_doctor_appointments('doc001', '2025-03-21') AS appointment_count;

-- Failure Test:
-- Pass a NULL doctor ID.
SELECT count_doctor_appointments(NULL, '2025-03-21') AS appointment_count;
-- Pass a NULL date.
SELECT count_doctor_appointments('doc001', NULL) AS appointment_count;
*/