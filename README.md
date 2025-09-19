# Maji Ndogo Water Services Audit Project(PART3)
## Description
This project investigates the accuracy and integrity of water quality records collected by surveyors in Maji Ndogo. Using the auditor’s report as a benchmark, the project compares employee-recorded scores with the auditor’s scores to identify discrepancies.
#### The analysis focuses on:
Verifying the total number of audited records.
Matching surveyor scores against the auditor’s scores.
Creating a view of incorrect records (Incorrect_records) for detailed analysis.
Counting mistakes per employee and identifying those with above-average errors.
Examining the statements associated with suspect employees to detect potential corruption.
The goal is to provide a data-driven view of employee performance and potential integrity issues, supporting accountability and transparency in water service management.
# Project Tasks
## Part 1: Load and Compare Scores
Load the auditor’s CSV data into a table called auditor_report.
Join auditor_report with visits to get record_id.
Join visits with water_quality to add subjective_quality_score (surveyor scores).
Compare auditor_score vs surveyor_score to identify mismatches.
# Part 2: Create Incorrect Records View
Create a view called Incorrect_records containing only mismatched rows.
Include these columns: location_id, record_id, employee_name, auditor_score, surveyor_score, statements.
# Part 3: Count Mistakes per Employee
Use a CTE called error_count to count how many times each employee_name appears in Incorrect_records.
Calculate the average number of mistakes per employee to identify outliers.
# Part 4: Identify Suspect Employees
Create a CTE called suspect_list for employees whose mistake count is above average.
These are the employees who require closer review.
# Part 5: Link Records to Suspects
Filter Incorrect_records to show only rows belonging to the suspect employees.
Include employee_name, location_id, and statements.
# Part 6: Check for Corruption Clues
Focus on the statements column for mentions of “cash”.
Confirm that only suspect employees have statements mentioning cash.
Verify that no non-suspect employees appear in these filtered results.

# Findings
### 1. Total Audited Records
Auditor checked 1,620 records.
### 2. Matching vs Mismatching Scores
1,518 records matched between auditor and surveyor scores.
102 records did not match (about 6% mismatch).

### 3. Incorrect Records and Employee Mistakes
Created Incorrect_records view for all mismatched records.
Counted mistakes per employee using error_count.
### 4. Employees with Above-Average Mistakes
Four employees had mistakes higher than the average:
Bello Azibo – 26 mistakes
Zuriel Matembo – 17 mistakes
Malachi Mavuso – 21 mistakes
Lalitha Kaburi – 7 mistakes
### 5. Suspicious Patterns in Statements
Filtered Incorrect_records for these four employees.
Looked at statements for any mention of “cash”.
Only these four employees had statements containing cash.
No non-suspect employees had statements mentioning cash.
# Conclusion:
Most surveyor records (94%) matched the auditor’s scores.
A small group of employees made more mistakes than average.
Statements mentioning cash were exclusively linked to these employees, highlighting a potential concern for misconduct or bribery.
