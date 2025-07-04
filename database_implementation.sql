/*Create Schema*/
CREATE DATABASE IF NOT EXISTS hospital_management;
USE hospital_management;

/*Create Associative and Non-associative Tables*/
-- Table: patient
CREATE TABLE patient (
    patient_id VARCHAR(5) PRIMARY KEY,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(6) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    address VARCHAR(50) NOT NULL,
    email VARCHAR(40) NOT NULL,
    emergency_contact_name VARCHAR(40),
    emergency_contact_number VARCHAR(15),
    is_deleted BIT(1) DEFAULT b'0'
);

-- Table: department
CREATE TABLE department (
    department_id VARCHAR(7) PRIMARY KEY,
    department_name VARCHAR(20) NOT NULL,
    is_deleted BIT(1) DEFAULT b'0'
);

-- Table: doctor
CREATE TABLE doctor (
    doctor_id VARCHAR(7) PRIMARY KEY,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    role VARCHAR(25) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    email VARCHAR(40) NOT NULL,
    available_days SET('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
    is_deleted BIT(1) DEFAULT b'0',    
    department_id VARCHAR(7),
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

-- Table: insurance
CREATE TABLE insurance (
    insurance_id VARCHAR(5) PRIMARY KEY,
    insurance_provider VARCHAR(50) NOT NULL,
    is_deleted BIT(1) DEFAULT b'0'
);

-- Table: patient_insurance (associative)
CREATE TABLE patient_insurance (
    insurance_id VARCHAR(5),
    patient_id VARCHAR(5),
    policy_number VARCHAR(10) NOT NULL,
    coverage_amount MEDIUMINT NOT NULL,
    expiry_date DATE NOT NULL,
    is_deleted BIT(1) DEFAULT b'0',
    PRIMARY KEY (insurance_id, patient_id),
    FOREIGN KEY (insurance_id) REFERENCES insurance(insurance_id),
--        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
--        ON UPDATE CASCADE ON DELETE CASCADE
);

-- Table: appointment
CREATE TABLE appointment (
    appointment_id VARCHAR(5) PRIMARY KEY,
    patient_id VARCHAR(5),
    doctor_id VARCHAR(7),
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    diagnosis MEDIUMTEXT,
    prescription MEDIUMTEXT,
    status ENUM('Walk-In','Scheduled','Completed','Cancelled') NOT NULL,
    is_deleted BIT(1) DEFAULT b'0',
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id)
);

-- Table: billing
CREATE TABLE billing (
    bill_id VARCHAR(5) PRIMARY KEY,
    appointment_id VARCHAR(5),
    total_amount FLOAT NOT NULL,
    payment_status ENUM('Pending','Paid') NOT NULL,
    is_deleted BIT(1) DEFAULT b'0',
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id)
);

-- Table: medicine
CREATE TABLE medicine (
    medicine_id VARCHAR(5) PRIMARY KEY,
    medicine_name VARCHAR(25) NOT NULL,
    stock_quantity INT NOT NULL,
    supplier VARCHAR(40) NOT NULL,
    expiry_date DATE NOT NULL,
    unit_price FLOAT NOT NULL,
    is_deleted BIT(1) DEFAULT b'0'
);

-- Table: billing_medicine (associative)
CREATE TABLE billing_medicine (
    bill_id VARCHAR(5),
    medicine_id VARCHAR(5),
    quantity INT NOT NULL,
    is_deleted BIT(1) DEFAULT b'0',
    PRIMARY KEY (bill_id, medicine_id),
    FOREIGN KEY (bill_id) REFERENCES billing(bill_id),
	-- ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id)
     --   ON UPDATE CASCADE ON DELETE CASCADE
);


/*Inserting data into all the created tables*/

/*Insert Data into patient table*/
INSERT INTO patient (
    patient_id, first_name, last_name, date_of_birth, gender, 
    contact_number, address, email, emergency_contact_name, 
    emergency_contact_number, is_deleted
)
VALUES
('p001','John','Doe','1990-05-14','Male','(123)4567890',
 '123 Maple Street, New York, NY 10001, USA','john@example.com',
 'Jane Doe','(223)3445566', b'0'),
('p002','Alice','Smith','1985-09-23','Female','(987)6543210',
 '456 Oak Avenue, Los Angeles, CA 90012, USA','alice@example.com',
 'Michael Smith','(667)7889900', b'0'),
('p003','Robert','Brown','1992-07-30','Male','(564)7382910',
 '789 Pine Road, Chicago, IL 60611, USA','robert@example.com',
 'Laura Brown','(334)4556677', b'0'),
('p004','Emily','Johnson','1998-12-01','Female','(110)0223344',
 '101 Birch Lane, Houston, TX 77002, USA','emily@example.com',
 'Daniel Johnson','(778)8990011', b'0'),
('p005','David','Miller','1978-06-17','Male','(998)8776655',
 '202 Cedar Drive, Seattle, WA 98101, USA','david@example.com',
 'Sarah Miller','(556)6778899', b'0'),
('p006','Michael','Clark','1982-03-10','Male','(909)0909090',
 '1233 Cherry Drive, Boston, MA 02101, USA','michael@example.com',
 'Patrick Clark','(112)2334455', b'1'),
('p007','Ellie','Johnson','1999-04-15','Female','(520)8776656',
 '1724 Maplewood Lane, Brookhaven, TX 75432','ejohnson@example.com',
 'Michael Johnson','(312)7748921', b'0'),
('p008','Bob','Williams','1993-09-22','Male','(213)0909091',
 '289 Westlake Drive, Fairview, OH 44126','bobw93@example.com',
 'Sarah Williams','(415)9823476', b'0'),
('p009','Charlie','Anderson','1978-06-10','Male','(707)8776657',
 '915 Ocean Breeze Ave, Clearwater, FL 33755','charmander@example.com',
 'Linda Anderson','(646)2157093', b'0'),
('p010','David','Rickman','1973-11-05','Male','(420)2436569',
 '4701 Meadowbrook Court, Willow Springs, OR 97497','harrypotterfan365@example.com',
 'James Rickman','(503)6714582', b'1');

/*Insert Data into department table*/
INSERT INTO department (department_id, department_name, is_deleted)
VALUES
('dep001','Cardiology', b'0'),
('dep002','Neurology', b'0'),
('dep003','Pediatrics', b'0'),
('dep004','Orthopedics', b'0'),
('dep005','Dermatology', b'0');

/*  Insert Data into doctor table */
INSERT INTO doctor (
    doctor_id, first_name, last_name, role, department_id,
    contact_number, email, available_days, is_deleted
)
VALUES
('doc001','Abhimanyu','Pandey','Cardiologist','dep001',
 '(112)2334455','abhimanyu.pandey@hospital.com','Monday,Wednesday,Friday', b'0'),
('doc002','Rajesh','Gupta','Neurologist','dep002',
 '(223)3445566','r.gupta@hospital.com','Tuesday,Thursday,Saturday', b'0'),
('doc003','Samuel','Thompson','Pediatrician','dep003',
 '(334)4556677','s.thompson@hospital.com','Monday,Tuesday,Thursday,Friday', b'0'),
('doc004','Pooja','Pandit','Orthopedician','dep004',
 '(445)5667788','pooja.pandit@hospital.com','Wednesday,Friday', b'0'),
('doc005','Adams','Hall','Pediatrician','dep003',
 '(556)6778899','adams.h@hospital.com','Tuesday,Wednesday,Saturday,Sunday', b'1'),
('doc006','Micahel','Lee','Dermatologist','dep005',
 '(520)6787651','m.lee@hospital.com','Wednesday,Saturday,Sunday', b'0');


/* Insert Data into insurance table */
INSERT INTO insurance (insurance_id, insurance_provider, is_deleted)
VALUES
('i001','Aetna', b'0'),
('i002','Blue Cross', b'0'),
('i003','UnitedHealth', b'0'),
('i004','Cigna', b'0'),
('i005','Humana', b'0');

/* Insert Data into appointment table */
INSERT INTO appointment (
    appointment_id, patient_id, doctor_id, appointment_date, 
    appointment_time, diagnosis, prescription, status, is_deleted
)
VALUES
('a001','p001','doc002','2025-12-02','10:00:00',NULL,NULL,'Scheduled', b'0'),
('a002','p002','doc003','2025-02-14','14:30:00','Flu','Paracetamol','Completed', b'0'),
('a003','p003','doc001','2025-03-21','09:00:00',NULL,NULL,'Walk-In', b'0'),
('a004','p004','doc002','2025-02-28','16:15:00',NULL,NULL,'Cancelled', b'0'),
('a005','p005','doc003','2025-01-29','11:45:00','Migraine','Ibuprofen','Completed', b'0'),
('a006','p006','doc005','2025-12-30','10:15:00',NULL,NULL,'Scheduled', b'1'),
('a007','p007','doc001','2025-01-31','11:15:00','Heart Issue','Metformin','Completed', b'0'),
('a008','p008','doc004','2025-01-04','12:15:00','Fracture','Omeprazole','Completed', b'0'),
('a009','p009','doc005','2025-02-02','13:15:00',NULL,NULL,'Cancelled', b'1'),
('a010','p010','doc004','2025-05-14','14:15:00',NULL,NULL,'Scheduled', b'1'),
('a011','p005','doc006','2025-01-27','15:15:00','Skin Rash','Aspirin','Completed', b'0');

/* Insert Data into billing table */
INSERT INTO billing (
    bill_id, patient_id, appointment_id, total_amount, payment_status, is_deleted
)
VALUES
('b001','a002',257.99,'Paid', b'0'),
('b002','a005',150.74,'Pending', b'0'),
('b003','a007',191.36,'Paid', b'0'),
('b004','a008',25.00,'Pending', b'0'),
('b005','a011',873.65,'Paid', b'0');

/* Insert Data into medicine table */
INSERT INTO medicine (
    medicine_id, medicine_name, stock_quantity, supplier, 
    expiry_date, unit_price, is_deleted
)
VALUES
('m001','Paracetamol',100,'MediCorp','2026-01-01',10, b'0'),
('m002','Ibuprofen',50,'HealthPlus','2025-09-30',15, b'0'),
('m003','Aspirin',75,'PharmaWorld','2025-06-15',8, b'0'),
('m004','Metformin',30,'MediCorp','2026-03-20',12, b'0'),
('m005','Omeprazole',60,'PharmaWorld','2025-11-10',20, b'0');

/*  Insert Data into patient_insurance table */
INSERT INTO patient_insurance (
    insurance_id, patient_id, policy_number, coverage_amount, expiry_date, is_deleted
)
VALUES
('i001','p001','POL12345', 5000, '2026-12-31', b'0'),
('i002','p002','POL67890',10000,'2027-06-30', b'0'),
('i003','p003','POL54321', 7500, '2026-09-15', b'0'),
('i004','p004','POL98765', 8000, '2027-03-20', b'0'),
('i003','p005','POL24680', 6000, '2026-11-10', b'0'),
('i003','p006','POL54543', 7300, '2026-12-31', b'1'),
('i004','p007','POL98123',50000,'2027-06-15', b'0'),
('i004','p001','POL24001',1280, '2026-09-07', b'0'),
('i001','p009','POL24365', 3000, '2027-03-01', b'0'),
('i001','p010','POL70707', 7337, '2026-11-11', b'1');

/* Insert Data into billing_medicine table */
INSERT INTO billing_medicine (
    bill_id, medicine_id, quantity, is_deleted
)
VALUES
('b001','m001',2, b'0'),
('b001','m002',1, b'0'),
('b002','m003',3, b'0'),
('b003','m001',1, b'0'),
('b004','m004',2, b'0'),
('b005','m005',1, b'0'),
('b005','m002',2, b'0');