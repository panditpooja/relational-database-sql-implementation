/* Single table queries for hospital management system */
/*Patient table queries*/
-- 1. Retrieve full name of all the non-deleted patients in upper case.
SELECT patient_id, UPPER(CONCAT(first_name, ' ', last_name)) AS full_name
FROM patient
WHERE is_deleted = b'0';

-- 2. Count active (non-deleted) patients
SELECT COUNT(*) AS active_patient_count
FROM patient
WHERE is_deleted = b'0';

-- 3. Retrieve non-deleted patients sorted by date_of_birth (oldest first)
SELECT patient_id, first_name, last_name, date_of_birth
FROM patient
WHERE is_deleted = b'0'
ORDER BY date_of_birth ASC;

-- 4. Retrieve only the first 5 oldest non-deleted patients
SELECT patient_id, first_name, last_name
FROM patient
WHERE is_deleted = b'0'
ORDER BY date_of_birth ASC
LIMIT 5;

-- 5. Use CASE to classify patients as "Adult" if their age is atleast 18 years and others as "Minor".
SELECT patient_id, first_name, last_name,
       CASE 
           WHEN DATEDIFF(CURDATE(), date_of_birth) / 365 >= 18 THEN 'Adult'
           ELSE 'Minor'
       END AS age_group
FROM patient
WHERE is_deleted = b'0';


/*Doctor table queries*/
-- 1. Retrieve active doctor full name in lower case along with their roles.
SELECT doctor_id, LOWER(CONCAT(first_name, ' ', last_name)) AS full_name, role
FROM doctor
WHERE is_deleted = b'0';

-- 2. Count active doctors and inactive doctors in the hospital
SELECT is_deleted, COUNT(*) AS doctor_count
FROM doctor
GROUP BY is_deleted;

-- 3. Retrieve doctors sorted by last name
SELECT * FROM doctor
WHERE is_deleted = b'0'
ORDER BY last_name ASC;

-- 4. Retrieve an active doctor with his/her role whose last name start with letter "P" and last name sorted in ascending order.
SELECT doctor_id, first_name, last_name, role
FROM doctor
WHERE is_deleted = b'0' AND last_name LIKE "P%"
ORDER BY last_name ASC
LIMIT 1;

-- 5. A query to determine a list of doctors and their availability on Sunday.
SELECT doctor_id, first_name, last_name,
       CASE 
           WHEN FIND_IN_SET('Sunday', available_days) > 0 THEN 'Available on Sunday'
           ELSE 'Not available on Sunday'
       END AS availability
FROM doctor
WHERE is_deleted = b'0';

/*Department Table Queries*/
-- 1. Retrieve department details where the department starts with "Ped"
SELECT * FROM department
WHERE is_deleted = b'0' AND SUBSTR(department_name,1,3) = 'Ped';

-- 2. Retrieve the total departments in the hospital.
SELECT COUNT(*) AS department_count
FROM department
WHERE is_deleted = b'0';

-- 3. Sort the departments in alphabetical order
SELECT department_id, department_name
FROM department
ORDER BY department_name ASC;

-- 4. Retrieve the First 3 Departments with the Least Number of Letters in Name
SELECT department_id, department_name
FROM department
WHERE is_deleted = b'0'
ORDER BY LENGTH(department_name) ASC
LIMIT 3;
 
-- 5. Flag departments as "Active" or "Inactive" based on is_deleted flag
SELECT department_id, department_name, IF(is_deleted = b'0', 'Active', 'Deleted') AS Status
FROM department;

/* Insurance Table Queries */

-- 1. Convert active insurance_provider names to Title Case for better readability
SELECT insurance_id, 
       CONCAT(UPPER(LEFT(insurance_provider, 1)), LOWER(SUBSTRING(insurance_provider, 2))) AS insurance_provider
FROM insurance
WHERE is_deleted = b'0';

-- 2. Count total insurance records irrespective of if they are active or not.
SELECT COUNT(*) AS total_insurances
FROM insurance;

-- 3. Count insurance providers by Word Count in their name
SELECT 
    CASE 
        WHEN CHAR_LENGTH(insurance_provider) - CHAR_LENGTH(REPLACE(insurance_provider, ' ', '')) + 1 = 1 THEN 'Single Word'
        WHEN CHAR_LENGTH(insurance_provider) - CHAR_LENGTH(REPLACE(insurance_provider, ' ', '')) + 1 = 2 THEN 'Two Words'
        ELSE 'Three or More Words'
    END AS Word_Count_Category,
    COUNT(*) AS Provider_Count
FROM insurance
WHERE is_deleted = 0
GROUP BY Word_Count_Category
ORDER BY Provider_Count DESC;

-- 4. Retrieve only the first 2 insurance records sorted by their insurance_id
SELECT insurance_id, insurance_provider
FROM insurance
WHERE is_deleted = b'0'
ORDER BY insurance_id
LIMIT 2;

-- 5. Flag insurance providers as 'Active' or 'Inactive' based on their is_deleted feature.
SELECT insurance_id, insurance_provider,
       CASE 
           WHEN is_deleted = b'0' THEN 'Active'
           ELSE 'Inactive'
       END AS Status
FROM insurance;


/* Appointment table queries */

-- 1. Retrieve active appointments with formatted date in a more readable format (e.g., "March 30, 2025").
SELECT appointment_id, patient_id, doctor_id,
       DATE_FORMAT(appointment_date, '%M %d, %Y') AS formatted_date,
       appointment_time, status
FROM appointment
WHERE is_deleted = b'0';

-- 2. Count active appointments grouped by status
SELECT status, COUNT(*) AS count
FROM appointment
WHERE is_deleted = b'0'
GROUP BY status;

-- 3. Retrieve active appointments sorted by appointment_time
SELECT appointment_id, appointment_date, appointment_time, status
FROM appointment
WHERE is_deleted = b'0'
ORDER BY appointment_time;

-- 4. Retrieve only the first 4 active appointments sorted by their date of appointment.
SELECT * FROM appointment
WHERE is_deleted = b'0'
ORDER BY appointment_date
LIMIT 4;

-- 5. Check if diagnosis or prescription is NULL,  if yes then replace them with "Not Provided"
SELECT 
    appointment_id, 
    patient_id, 
    doctor_id, 
    appointment_date, 
    appointment_time, 
    COALESCE(diagnosis, 'Not Provided') AS Diagnosis, 
    COALESCE(prescription, 'Not Provided') AS Prescription
FROM appointment;

/* Billing table queries */
-- 1. Retrieve active billing details with a concatenated description containing total amount value with status of the payment
SELECT bill_id, appointment_id,
       CONCAT('Total: $', total_amount, ', Status: ', payment_status) AS billing_info
FROM billing
WHERE is_deleted = b'0';

-- 2. Display the total_amount from active and paid bills
SELECT SUM(total_amount) AS total_paid
FROM billing
WHERE is_deleted = b'0' AND payment_status = 'Paid';

-- 3. Retrieve bills sorted by total_amount (highest first) of active patients.
SELECT bill_id, total_amount, payment_status
FROM billing
WHERE is_deleted = b'0'
ORDER BY total_amount DESC;

-- 4. Retrieve only the first 2 billing records of active patients.
SELECT bill_id, total_amount, payment_status
FROM billing
WHERE is_deleted = b'0'
ORDER BY bill_id
LIMIT 2;

-- 5. Show a friendly payment status message like if the bill is paid then display "Payment Completed" and if not then display "Payment Pending"
SELECT bill_id,
       CASE 
           WHEN payment_status = 'Paid' THEN 'Payment Completed'
           ELSE 'Payment Pending'
       END AS payment_status_text
FROM billing
WHERE is_deleted = b'0';

/* Medicine table queries */
-- 1. Retrieve active medicine details with a concatenated description containing number of stock available with respective unit price
SELECT medicine_id, medicine_name,
       CONCAT('Stock: ', stock_quantity, ', Price: $', unit_price) AS medicine_desc
FROM medicine
WHERE is_deleted = b'0';

-- 2. Find the total medicine stock available in the hospital.
SELECT SUM(stock_quantity) AS total_stock
FROM medicine
WHERE is_deleted = b'0';

-- 3. Retrieve medicines sorted by expiry_date (soonest first)
SELECT medicine_id, medicine_name, expiry_date
FROM medicine
WHERE is_deleted = b'0'
ORDER BY expiry_date ASC;

-- 4. Retrieve only the first 3 medicines sorted by their medicine_id.
SELECT medicine_id, medicine_name, stock_quantity
FROM medicine
WHERE is_deleted = b'0'
ORDER BY medicine_id
LIMIT 3;

-- 5. Use CASE to indicate if a medicine is near expiry (within 6 months)
SELECT medicine_id, medicine_name, expiry_date,
       CASE 
           WHEN DATEDIFF(expiry_date, CURDATE()) <= 180 THEN 'Near Expiry'
           ELSE 'Fresh'
       END AS expiry_status
FROM medicine
WHERE is_deleted = b'0';