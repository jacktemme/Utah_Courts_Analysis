--Creating schema for the two felony tables

CREATE TABLE cases (
	uniqueid INT PRIMARY KEY NOT NULL,
	case_number INT NOT NULL,
	filing_date DATE NOT NULL,
	closure_date DATE,
	case_type_description VARCHAR(30) NOT NULL,
	court_location VARCHAR(30) NOT NULL,
	county VARCHAR(15) NOT NULL,
	court_district INT NOT NULL,
	
	-- ensures case number + court location is unique
	CONSTRAINT case_filing_unique UNIQUE (case_number, court_location) 

);

CREATE TABLE charges (
	id SERIAL PRIMARY KEY, -- Unique identifier for each row
	uniqueid INT NOT NULL,
	charge_number INT NOT NULL,
	violation VARCHAR(30) NOT NULL,
	violation_description TEXT NOT NULL,
	severity_description TEXT NOT NULL,
	
	FOREIGN KEY (uniqueid) REFERENCES cases(uniqueid)
	
);

-- Test to make sure both tables imported correctly
SELECT * FROM cases;
SELECT * FROM charges;


