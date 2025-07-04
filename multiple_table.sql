 /* Multiple table queries */

/* 
Query Type 1: INNER JOIN with an Associative Table
*/
/* Query 1.1: For each billing record, list the medicines and their billed quantities */
SELECT 
    b.bill_id,
    b.patient_id,
    b.appointment_id,
    b.total_amount,
    bm.medicine_id,
    m.medicine_name,
    bm.quantity
FROM billing b 
INNER JOIN billing_medicine bm ON bm.bill_id = b.bill_id
INNER JOIN medicine m ON bm.medicine_id = m.medicine_id
WHERE b.is_deleted = b'0'
  AND bm.is_deleted = b'0'
  AND m.is_deleted = b'0';

/* Query 1.2: Retrieve detailed billing and medicine details for a specific patient (e.g., patient 'p002') */
SELECT 
    b.bill_id,
    b.total_amount,
    m.medicine_id,
    m.medicine_name,
    bm.quantity,
    (m.unit_price * bm.quantity) AS computed_medicine_cost
FROM billing b
INNER JOIN billing_medicine bm ON b.bill_id = bm.bill_id
INNER JOIN medicine m ON bm.medicine_id = m.medicine_id
WHERE b.patient_id = 'p002'
  AND b.is_deleted = b'0'
  AND bm.is_deleted = b'0'
  AND m.is_deleted = b'0';

/* Query 1.3: Check billing consistency – Compare bill total with the sum of (medicine unit_price * quantity)
   A query that aggregates the medicine cost per bill and flags any discrepancy.
*/
SELECT 
    b.bill_id,
    b.total_amount,
    SUM(m.unit_price * bm.quantity) AS computed_total,
    CASE 
         WHEN ABS(b.total_amount - SUM(m.unit_price * bm.quantity)) < 0.01 THEN 'Consistent'
         ELSE 'Discrepancy'
    END AS billing_consistency
FROM billing b
INNER JOIN billing_medicine bm ON b.bill_id = bm.bill_id
INNER JOIN medicine m ON bm.medicine_id = m.medicine_id
WHERE b.is_deleted = b'0'
  AND bm.is_deleted = b'0'
  AND m.is_deleted = b'0'
GROUP BY b.bill_id;

/* Query 1.4: A query that retrieves detailed information about active patients, their associated insurance policies,
and providers using inner join. */
SELECT * FROM 
    patient p
INNER JOIN 
    patient_insurance pi ON p.patient_id = pi.patient_id
INNER JOIN 
    insurance i ON pi.insurance_id = i.insurance_id
WHERE 
    p.is_deleted = b'0'
    AND i.is_deleted = b'0'
    AND pi.is_deleted = b'0';

/* 
Query Type 2: LEFT OUTER JOIN
*/

/* Query 2.1: List all active appointments with corresponding patient and doctor names*/
SELECT 
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    a.status
FROM appointment a
LEFT OUTER JOIN patient p ON a.patient_id = p.patient_id
LEFT OUTER JOIN doctor d ON a.doctor_id = d.doctor_id
WHERE a.is_deleted = b'0';

/* Query 2.2: Retrieve all active billing details for a specific patient (e.g., 'p005') along with appointment date */
SELECT 
    b.bill_id,
    b.total_amount,
    a.appointment_date,
    a.appointment_time,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name
FROM billing b
LEFT OUTER JOIN appointment a ON b.appointment_id = a.appointment_id
LEFT OUTER JOIN patient p ON b.patient_id = p.patient_id
WHERE b.patient_id = 'p005'
  AND b.is_deleted = b'0';

/* Query 2.3: List all active patients with their latest appointment date.
   Even if a patient has never had an appointment, they will appear with a NULL appointment_date.
*/
SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    MAX(a.appointment_date) AS latest_appointment
FROM patient p
LEFT OUTER JOIN appointment a ON p.patient_id = a.patient_id AND a.is_deleted = b'0'
WHERE p.is_deleted = b'0'
GROUP BY p.patient_id, p.first_name, p.last_name;

/* Query 2.4: Retrieve all active patients along with their billing details, including those who have not been billed yet.
*/
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    b.bill_id,
    b.total_amount,
    b.payment_status
FROM patient p
LEFT OUTER JOIN billing b ON p.patient_id = b.patient_id AND b.is_deleted = b'0'
WHERE p.is_deleted = b'0';


/* 
Query Type 3: Set Operation
Purpose: To combine results from different tables.
*/

/* Query 3.1: Combine a list of patients and doctors with their IDs and names */
SELECT 
    patient_id AS ID, 
    CONCAT(first_name, ' ', last_name) AS Name, 
    'Patient' AS Person_Type
FROM patient
WHERE is_deleted = b'0'
UNION
SELECT 
    doctor_id AS ID, 
    CONCAT(first_name, ' ', last_name) AS Name, 
    'Doctor' AS Person_Type
FROM doctor
WHERE is_deleted = b'0';

/* Query 3.2: Consolidate active email addresses from both patients and doctors */
SELECT email AS Contact_Email, 'Patient' AS Person_Type
FROM patient
WHERE is_deleted = b'0' AND email IS NOT NULL
UNION
SELECT email AS Contact_Email, 'Doctor' AS Person_Type
FROM doctor
WHERE is_deleted = b'0' AND email IS NOT NULL;

/* Query 3.3: Combine lists of patients with pending bills and patients with completed bills, 
   indicating billing status. This can be used for a consolidated billing dashboard.
*/
SELECT patient_id, 'Pending' AS Bill_Status
FROM billing
WHERE is_deleted = b'0' AND payment_status = 'Pending'
UNION
SELECT patient_id, 'Paid' AS Bill_Status
FROM billing
WHERE is_deleted = b'0' AND payment_status = 'Paid';

/* Query 3.4: Patients who have scheduled appointments, but are not listed in the billing table (No payment or billing information)*/
(SELECT p.patient_id, p.first_name, p.last_name, a.appointment_id, a.appointment_date
FROM patient p
INNER JOIN appointment a ON p.patient_id = a.patient_id
WHERE a.status = 'Scheduled')
EXCEPT
(SELECT p.patient_id, p.first_name, p.last_name, a.appointment_id, a.appointment_date
FROM patient p
INNER JOIN appointment a ON p.patient_id = a.patient_id
INNER JOIN billing b ON a.appointment_id = b.appointment_id);

/*Query 3.5: All patients who have had completed or canceled appointments in the last 6 months*/
(SELECT DISTINCT p.patient_id, p.first_name, p.last_name
FROM patient p
INNER JOIN appointment a ON p.patient_id = a.patient_id
WHERE a.Status = 'Completed'
AND a.appointment_date >= CURDATE() - INTERVAL 6 MONTH)
UNION
(SELECT DISTINCT p.patient_id, p.first_name, p.last_name
FROM patient p
INNER JOIN appointment a ON p.patient_id = a.patient_id
WHERE a.Status = 'Cancelled'
AND a.appointment_date >= CURDATE() - INTERVAL 6 MONTH);


/* Query Type 4: Subquery with Multi-Row Operator */
/* Query 4.1: List patients who have appointments with doctors from the Cardiology department ('dep001') */
SELECT 
    patient_id, first_name, last_name
FROM patient
WHERE patient_id IN (
    SELECT DISTINCT a.patient_id
    FROM appointment a
    WHERE a.doctor_id IN (
         SELECT doctor_id 
         FROM doctor 
         WHERE department_id = 'dep001' AND is_deleted = b'0'
    )
    AND a.is_deleted = b'0'
)
AND is_deleted = b'0';

/* Query 4.2: List active patients with non pending bills.
*/
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name
FROM patient p
WHERE p.patient_id NOT IN (
    SELECT b.patient_id
    FROM billing b
    WHERE b.payment_status = 'Pending' AND b.is_deleted = b'0' AND b.patient_id IS NOT NULL
)
AND p.is_deleted = b'0';

/* Query 4.3: List patients who have more than two appointments.
   The subquery groups appointments by patient_id and selects those with count > 2.
*/
SELECT 
    patient_id,
    first_name,
    last_name
FROM patient
WHERE patient_id IN (
    SELECT patient_id
    FROM appointment
    WHERE is_deleted = b'0'
    GROUP BY patient_id
    HAVING COUNT(appointment_id) > 2
)
AND is_deleted = b'0';

/* Query 4.4: List all active patients who have pending bills and oes not have an appointment with a Neurologist ('dep002').
*/
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name
FROM patient p
WHERE p.patient_id IN (
    SELECT b.patient_id
    FROM billing b
    WHERE b.payment_status = 'Pending' AND b.is_deleted = b'0'
)
AND p.patient_id IN (
    SELECT a.patient_id
    FROM appointment a
    WHERE a.doctor_id NOT IN (
         SELECT doctor_id 
         FROM doctor 
         WHERE department_id = 'dep002' AND is_deleted = b'0'
    )
    AND a.is_deleted = b'0'
)
AND p.is_deleted = b'0';


/* Query Type 5: Derived Table Using WITH (Common Table Expression)*/

/* Query 5.1: Compute total billing per patient and list active patients whose total billing exceeds $500 
*/
WITH TotalBilling AS (
    SELECT 
        patient_id, 
        SUM(total_amount) AS total_bill
    FROM billing
    WHERE is_deleted = b'0'
    GROUP BY patient_id
)
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    tb.total_bill
FROM patient p
INNER JOIN TotalBilling tb ON p.patient_id = tb.patient_id
WHERE tb.total_bill > 500
  AND p.is_deleted = b'0';

/* Query 5.2: Compute average billing per patient and list patients with billing above the average. */
WITH PatientBilling AS (
    SELECT 
        patient_id,
        SUM(total_amount) AS total_bill
    FROM billing
    WHERE is_deleted = b'0'
    GROUP BY patient_id
),
AvgBilling AS (
    SELECT AVG(total_bill) AS avg_bill
    FROM PatientBilling
)
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    pb.total_bill,
    ab.avg_bill
FROM patient p
INNER JOIN PatientBilling pb ON p.patient_id = pb.patient_id
INNER JOIN AvgBilling ab
WHERE pb.total_bill > ab.avg_bill
  AND p.is_deleted = b'0';

/* Query 5.3: Compute the total number of appointments per department using CTE,
   then list departments with above-average appointment counts.
*/
WITH DeptAppointments AS (
    SELECT 
        d.department_id,
        d.department_name,
        COUNT(a.appointment_id) AS appointment_count
    FROM department d
    LEFT OUTER JOIN doctor doc ON d.department_id = doc.department_id AND doc.is_deleted = b'0'
    LEFT OUTER JOIN appointment a ON doc.doctor_id = a.doctor_id AND a.is_deleted = b'0'
    WHERE d.is_deleted = b'0'
    GROUP BY d.department_id, d.department_name
),
AvgAppointments AS (
    SELECT AVG(appointment_count) AS avg_app
    FROM DeptAppointments
)
SELECT 
    da.department_id,
    da.department_name,
    da.appointment_count,
    aa.avg_app
FROM DeptAppointments da, AvgAppointments aa
WHERE da.appointment_count > aa.avg_app;

