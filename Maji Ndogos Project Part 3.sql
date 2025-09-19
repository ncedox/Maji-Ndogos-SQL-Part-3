-- This part of the project focuses on the auditors' report. 
-- We're using it to verify the accuracy of employee work records.

-- First ly lets check How many recordes Audited

SELECT count(*)
FROM 
	auditor_report; -- we have found that there are 1620 records audited


-- Lets connect Auditors and Visits table

SELECT
   auditor_report.location_id,
   auditor_report.true_water_source_score,
   visits.record_id
FROM md_water_services.auditor_report AS auditor_report
JOIN md_water_services.visits AS visits
     ON auditor_report.location_id = visits.location_id;

-- Let us now Add surveyor scores

SELECT 
    visits.record_id,
    visits.location_id,
    water_quality.subjective_quality_score AS surveyor_score,
    auditor_report.true_water_source_score AS auditor_score
FROM md_water_services.auditor_report AS auditor_report
JOIN md_water_services.visits AS visits
    ON auditor_report.location_id = visits.location_id
JOIN md_water_services.water_quality AS water_quality
    ON visits.record_id = water_quality.record_id;

-- Now Finding Matchng Scores

SELECT 
    visits.record_id,
    visits.location_id,
    water_quality.subjective_quality_score AS surveyor_score,
    auditor_report.true_water_source_score AS auditor_score
FROM md_water_services.auditor_report AS auditor_report
JOIN md_water_services.visits AS visits
    ON auditor_report.location_id = visits.location_id
JOIN md_water_services.water_quality AS water_quality
    ON visits.record_id = water_quality.record_id
WHERE water_quality.subjective_quality_score = auditor_report.true_water_source_score
  AND visits.visit_count = 1
  ; -- From the above cde we are able to see that there are 1518 matching records
	-- Meaning that there 1518 matching recards between auditors score and surveyor score


-- Lets Find the mismatching  Scores

SELECT 
    visits.record_id,
    visits.location_id,
    water_quality.subjective_quality_score AS surveyor_score,
    auditor_report.true_water_source_score AS auditor_score
FROM md_water_services.auditor_report AS auditor_report
JOIN md_water_services.visits AS visits
    ON auditor_report.location_id = visits.location_id
JOIN md_water_services.water_quality AS water_quality
    ON visits.record_id = water_quality.record_id
WHERE water_quality.subjective_quality_score <> auditor_report.true_water_source_score
  AND visits.visit_count = 1;
-- There are 102 Mismatching records
-- So there is 94% matching Scores between auditors and the surveyers
	
 -- Let us further investigate the 102 errors made by surveyors
 
 -- Step no1: we Create a View for Incorrect Records
 -- We join the auditor report → visits → water_quality → employee.
 -- Only include rows where the auditor score doesn’t match the surveyor score.
 -- Include employee_name so we can see who made the mistakes.
 -- This view makes it easier to reuse this data later without rewriting the joins.
 
 CREATE VIEW md_water_services.Incorrect_records AS
SELECT
    auditor_report.location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score,
    auditor_report.statements AS statements
FROM md_water_services.auditor_report AS auditor_report
JOIN md_water_services.visits AS visits
    ON auditor_report.location_id = visits.location_id
JOIN md_water_services.water_quality AS water_quality
    ON visits.record_id = water_quality.record_id
JOIN md_water_services.employee AS employee
    ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE visits.visit_count = 1
  AND auditor_report.true_water_source_score <> water_quality.subjective_quality_score
  ;

-- Step no2: Count Mistakes per Employee
-- We count how many times each employee appears in Incorrect_records.
-- number_of_mistakes shows who made more mistakes.
-- This CTE (common table expression) makes the next steps easier.

WITH error_count AS ( -- Count mistakes per employee
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM md_water_services.Incorrect_records
    GROUP BY employee_name
   
)
SELECT * FROM error_count;

-- Step no 3: Calculate Average Mistakes
-- Calculates the average mistakes per employee.
-- We will use this number to identify employees who made above-average mistakes.
WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM md_water_services.Incorrect_records
    GROUP BY employee_name
)
SELECT AVG(number_of_mistakes) AS avg_error_count_per_empl
FROM error_count;


-- Step 4: List  Employees With Above Average Mistakes
-- Finds employees whose mistakes are higher than average.
-- This helps highlight employees who might need closer review.

WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM md_water_services.Incorrect_records
    GROUP BY employee_name
)
SELECT
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (
    SELECT AVG(number_of_mistakes)
    FROM error_count
);
-- From the above code we were able to spot Employees and are as follows:
-- Bello Azibo 26 mistakes
-- Zuriel Matembo  17 mistakes
-- Malachi Mavuso 21 mistakes
-- Lalita Kaburi 7 Mistakes

-- Let us Filter Incorrect_records for these four employees to examine patterns
-- So the Filters Incorrect_records to show only the four suspects’ records.
-- Includes location_id and statements so you can examine patterns.


WITH error_count AS ( 
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM md_water_services.Incorrect_records
    GROUP BY employee_name
),
suspect_list AS (
    SELECT
        employee_name
    FROM error_count
    WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT
    employee_name,
    location_id,
    statements
FROM md_water_services.Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list);


-- Now Let Us Filter statements mentioning “cash”
-- Further filters to records containing “cash”.
-- This isolates potentially bribery-related entries.
-- Shows that only the four suspects have such statements.

WITH error_count AS ( 
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM md_water_services.Incorrect_records
    GROUP BY employee_name
),
suspect_list AS (
    SELECT
        employee_name
    FROM error_count
    WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT
    employee_name,
    location_id,
    statements
FROM md_water_services.Incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list)
  AND statements LIKE '%cash%';
  -- Findgs are that the following emplees may have taken bribe: Zuriel Matembo
  -- Malachi Mavuso, Bello Azibo, Lalitha Kaburi
