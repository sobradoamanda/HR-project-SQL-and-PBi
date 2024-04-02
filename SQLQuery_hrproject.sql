-- CREATING DATABASE AND IMPORTING DATASET

CREATE DATABASE hr_project;

-- CHECKING DATASET
SELECT COUNT(*) FROM hr_information; 
-- 22214 rows

SELECT * FROM hr_information;

SELECT DISTINCT race FROM hr_information;
SELECT DISTINCT gender FROM hr_information;
SELECT DISTINCT department FROM hr_information;
SELECT DISTINCT location_state FROM hr_information;

-- DATA CLEANING

EXEC sp_help hr_information;

-- Removing 'UTC' from termdate
UPDATE hr_information
SET termdate = LEFT(termdate, LEN(termdate) - 4); 

-- Converting into date
UPDATE hr_information
SET termdate = CONVERT(date, termdate, 126);

SELECT termdate FROM hr_information;

-- Changing column type
ALTER TABLE hr_information
ALTER COLUMN termdate DATE;

-- Removing ';' from location_state
UPDATE hr_information
SET location_state = LEFT(location_state, (LEN(location_state)- 1));

-- Adjusting column values
UPDATE hr_information
SET location_state =
CASE WHEN location_state = 'Ohi' THEN 'Ohio' 
	 WHEN location_state = 'Indian' THEN 'Indiana'
	 WHEN location_state = 'Pennsylvani' THEN 'Pennsylvania'
	 ELSE location_state END

-- Adding a new column
ALTER TABLE hr_information
ADD age INT;

UPDATE hr_information
SET age = DATEDIFF(YEAR, birthdate, GETDATE())

SELECT MIN(age) AS YOUNGEST, MAX(age) AS OLDEST
FROM hr_information;


-- ANALYSIS

-- What is the gender breakdown of employees in the company? Non-Conforming: 502 / Male: 11288 / Female: 8455

SELECT gender, COUNT(*) AS count FROM hr_information
WHERE termdate IS NULL
GROUP BY gender;

-- What is the race/ethnicity breakdown of employees in the company? 

SELECT race, COUNT(*) as count FROM hr_information
WHERE termdate IS NULL
GROUP BY race
ORDER BY COUNT(*) DESC;

-- What is the age distribution of employees in the company?

SELECT MIN(age) AS YOUNGEST, MAX(age) AS OLDEST 
FROM hr_information;

SELECT
	CASE WHEN age BETWEEN 22 AND 30 THEN '22-30'
		 WHEN age BETWEEN 31 AND 40 THEN '31-40'
		 WHEN age BETWEEN 41 AND 50 THEN '41-50'
		 WHEN age BETWEEN 51 AND 60 THEN '51-60'
		 ELSE '61+' 
	END AS age_group, count(*) AS count
FROM hr_information
WHERE termdate IS NULL
GROUP BY CASE WHEN age BETWEEN 22 AND 30 THEN '22-30'
		 WHEN age BETWEEN 31 AND 40 THEN '31-40'
		 WHEN age BETWEEN 41 AND 50 THEN '41-50'
		 WHEN age BETWEEN 51 AND 60 THEN '51-60'
		 ELSE '61+' END
ORDER BY age_group;

SELECT 
	CASE WHEN age BETWEEN 22 AND 30 THEN '22-30'
		 WHEN age BETWEEN 31 AND 40 THEN '31-40'
		 WHEN age BETWEEN 41 AND 50 THEN '41-50'
		 WHEN age BETWEEN 51 AND 60 THEN '51-60'
		 ELSE '61+' 
	END AS age_group, gender, count(*) AS count
FROM hr_information
WHERE termdate IS NULL
GROUP BY CASE WHEN age BETWEEN 22 AND 30 THEN '22-30'
		 WHEN age BETWEEN 31 AND 40 THEN '31-40'
		 WHEN age BETWEEN 41 AND 50 THEN '41-50'
		 WHEN age BETWEEN 51 AND 60 THEN '51-60'
		 ELSE '61+' END, gender
ORDER BY age_group, gender;

-- How many employees work at headquarters versus remote locations?

SELECT location, COUNT(*) as count FROM hr_information
WHERE termdate IS NULL
GROUP BY location;

-- What is the average length of employment for employees who have been terminated?

SELECT AVG(DATEDIFF(YEAR,hire_date, termdate)) as avg_length_employment
FROM hr_information
WHERE termdate <= GETDATE() AND termdate IS NOT NULL;

-- How does the gender distribution vary across departments and job titles?

SELECT department, gender, COUNT(*) AS count
FROM hr_information
WHERE termdate IS NULL
GROUP BY department, gender
ORDER BY department;

-- What is the distribution of job titles across the company?

SELECT jobtitle, COUNT(*) as count
FROM hr_information
WHERE termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;

-- Which department has the highest turnover rate?

SELECT department, subquery.total_count, subquery.terminated_count, ROUND(CAST(subquery.terminated_count AS FLOAT)/subquery.total_count,4) AS termination_rate
FROM (
	SELECT department, count(*) AS total_count, 
	SUM(CASE WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 ELSE 0 END) AS terminated_count
	FROM hr_information	
	GROUP BY department) AS subquery
ORDER BY termination_rate;

-- What is the distribution of employees across locations by state?

SELECT location_state, COUNT(*) AS count
FROM hr_information	
WHERE termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- How has the company's employee count changed over time based on hire and term dates?

SELECT subquery.year, subquery.hires, subquery.terminations, subquery.hires-subquery.terminations AS net_change, (subquery.hires - subquery.terminations)*100/NULLIF(subquery.hires,0) AS net_change_percent
FROM (
	SELECT YEAR(hire_date) AS YEAR, COUNT(*) AS hires, SUM(CASE WHEN termdate IS NOT NUll AND termdate <= GETDATE() THEN 1 ELSE 0 END) AS terminations
	FROM hr_information
	GROUP BY YEAR(hire_date)
	) AS subquery 
ORDER BY subquery.year ASC;

-- What is the tenure distribution for each department?

SELECT department, AVG(DATEDIFF(YEAR, hire_date, termdate)) AS avg_tenure
FROM hr_information
WHERE termdate IS NOT NULL AND termdate <= GETDATE()
GROUP BY department;


