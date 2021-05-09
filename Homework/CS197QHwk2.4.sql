/*
CS197Q Homework assignment 2.4
  More Grouping and Join query work (queries 1 and 2)
  2.19 Subqueries
  2.20 Subqueries In Clauses
  2.21 Correlated Subqueries
  2.23 Union, Intersect, Minus Operations
Use the Starr database for this assignment. Use the Starr schema and ERD diagram as needed.

Always develop your queries in small steps. Start with a join, then add grouping and/or constraints.
Use "exploratory" queries to check your results.

You can write a subquery by itself and test it before you put it together with its main query.

Remember to delete any SQL that is not the answer to a question before you submit this file. Do not add any comments.

*/

/* 1. Write a grouping query that calculates the sum of ASSIGN_HOURS for each
      project. The query displays the columns: PROJ_NUM, PROJ_NAME, TOTAL_ASSIGN_HOURS, 
	  where the last column is an alias for the sum of ASSIGN_HOURS.
	  The results ahould be ordered by project name in alphabetical order. 
	  Check: Amber Wave should have 23.7 hours. 
*/

SELECT PROJ_NUM, PROJ_NAME, SUM (ASSIGN_HOURS) AS TOTAL_HOURS  
FROM PROJECT JOIN ASSIGNMENT USING (PROJ_NUM)
GROUP BY PROJ_NUM
ORDER BY PROJ_NAME; 


/* 2. Write a grouping query that displays columns: EMP_NUM, EMP_FNAME, EMP_LNAME, TOTAL_ASSIGN_HOURS
      for only employees with assignments. The column TOTAL_ASSIGN_HOURS is an alias for the sum of an employee's ASSIGN_HOURS
	  for all thier assignments. 
	  The results ahould be ordered by employee last name in alphabetical order. 
	  Check: Arbough should have 19.7 hours.
*/

SELECT EMP_NUM, EMP_FNAME, EMP_LNAME, SUM (ASSIGN_HOURS) AS TOTAL_ASSIGN_HOURS
FROM EMPLOYEE NATURAL JOIN ASSIGNMENT 
GROUP BY EMP_NUM 
ORDER BY EMP_LNAME;


/* 3. Write a query that displays EMP_NUM, EMP_FNAME, EMP_LNAME for all employees who 
      are not currently assigned. Use a subquery, not a join.
	  You should have 13 rows.
*/

SELECT EMP_NUM, EMP_FNAME, EMP_LNAME 
FROM EMPLOYEE WHERE EMP_NUM NOT IN
(SELECT EMP_NUM FROM ASSIGNMENT WHERE ASSIGN_HOURS IS NOT NULL);

/* 4. Write a query that retrieves the columns EMP_NUM, EMP_FNAME, EMP_LNAME from the EMPLOYEE table. 
      Add a WHERE clause that tests if EMP_NUM is IN a subquery which retrieves EMP_NUM from 
	  ASSIGNMENT where ASSIGN_DATE comes after March 3rd, 2010.
	  You should have 8 rows.
*/

SELECT EMP_NUM, EMP_FNAME, EMP_LNAME 
FROM EMPLOYEE WHERE EMP_NUM IN 
(SELECT EMP_NUM FROM ASSIGNMENT WHERE ASSIGN_DATE > '2010-03-03');


/* 5. Write a query that displays EMP_NUM, EMP_FNAME, EMP_LNAME, ASSIGN_HOURS for all
      assignments where the ASSIGN_HOURS are strictly greater than the average of all ASSIGN_HOURS.
	  The results are ordered by ASSIGN_HOURS in descending order.
	  Use a subquery in the WHERE clause to obtain the average ASSIGN_HOURS.
	  You should have 12 rows.
*/

SELECT EMP_NUM, EMP_FNAME, EMP_LNAME, ASSIGN_HOURS
FROM EMPLOYEE NATURAL JOIN ASSIGNMENT
WHERE ASSIGN_HOURS > (SELECT AVG (ASSIGN_HOURS) FROM ASSIGNMENT )
ORDER BY ASSIGN_HOURS DESC;

 
/* 6. Write a query that is a join of two subqueries in a FROM clause:
       ... from (subquery) join (subquery)...
      The first subquery retrieves these columns from the PROJECT table: PROJ_NUM, PROJ_NAME, PROJ_VALUE, 
	  PROJ_BALANCE, and PROJ_REMAINDER as an alias for the difference between PROJ_VALUE and PROJ_BALANCE. 
	  The second subquery retrieves the following columns from the ASSIGNMENT table: PROJ_NUM and CURRENT_CHARGES, 
	  an alias for the sum of the product of ASSIGN_CHG_HR and ASSIGN_HOURS. This subquery needs to group on the 
	  project number to compute the sums.
	  The final result set displays these columns: PROJ_NUM, PROJ_NAME, PROJ_VALUE, PROJ_BALANCE, PROJ_REMAINDER,
	  and CURRENT_CHARGES. The results are sorted alphabetically on project name.
	  You should have 4 rows. The first row would be: 18, Amber Wave, 3500500.0, 2110346.0, 1390154.0, 1544.8
*/


SELECT PROJ_NUM, PROJ_NAME, PROJ_VALUE, PROJ_BALANCE, PROJ_REMAINDER, CURRENT_CHARGES
FROM (SELECT PROJ_NUM, PROJ_NAME, PROJ_VALUE, PROJ_BALANCE, (PROJ_VALUE - PROJ_BALANCE) AS PROJ_REMAINDER 
FROM PROJECT) JOIN 
(SELECT PROJ_NUM, SUM (ASSIGN_CHG_HR * ASSIGN_HOURS) AS CURRENT_CHARGES 
FROM ASSIGNMENT
GROUP BY PROJ_NUM) USING (PROJ_NUM)
ORDER BY PROJ_NAME;


/* 7. Write a query that reports the total charge for each type of job for each project.
      The total charge for a job for one assignment is the product of the ASSIGN_CHG_HR and ASSIGN_HOURS
	  for that row in the assignment table. The sum of those charges for all rows for each specific job for 
	  each project is what is reported in this query. For example, looking at the ASSIGNMENT table, find all 
	  rows for project 15, then find all rows for job code 503. Calculate the product of ASSIGN_CHG_HR and ASSIGN_HOURS
	  for each of those rows and report the sum. The result for JOB_CODE 503 for project 15 would be 794.3. 

      The result set rows for all job codes for project 15 would be:
      PROJ_NUM   PROJ_NAME    ASSIGN_JOB  TOTAL_JOB_CHG
      15         Evergreen    501         541.8
      15         Evergreen    502         387.5
      15         Evergreen    503         794.3
	  15         Evergreen    509         82.92
	  ... etc.
      The result set includes only the following columns: PROJ_NUM, PROJ_NAME, ASSIGN_JOB, TOTAL_JOB_CHG,
	  where TOTAL_JOB_CHG is an alias for the sum of all of the charges for a specific job code for a specific 
	  project. The results must be ordered by PROJ_NUM, then by ASSIGN_JOB.
	  You should have 14 rows.
*/

SELECT PROJ_NUM, PROJ_NAME, ASSIGN_JOB, TOTAL_JOB_CHG 
FROM PROJECT,
(SELECT PROJ_NUM, ASSIGN_JOB, SUM (ASSIGN_CHG_HR * ASSIGN_HOURS) AS TOTAL_JOB_CHG 
FROM ASSIGNMENT GROUP  BY PROJ_NUM, ASSIGN_JOB) USING (PROJ_NUM)
ORDER BY PROJ_NUM, ASSIGN_JOB;




/* 8. Write a query that returns the PROJ_NUM and PROJ_NAME for projects that have assignments for 
      Bio Technicians (ASSIGN_JOB is 509) with the sum of the total ASSIGN_CHG_HR for that job strictly greater than 50.00. 
	  Use a correlated subquery that works with the ASSIGNMENT table to screen for projects that 
	  meet this criterion.  Use a grouping clause with a having condition. The correlated is on PROJ_NUM.
	  You should have one row in the return.
*/

SELECT P.PROJ_NUM, P.PROJ_NAME 
FROM PROJECT P
WHERE EXISTS
(SELECT * FROM ASSIGNMENT A GROUP BY PROJ_NUM HAVING A.ASSIGN_JOB = 509 AND 
SUM(A.ASSIGN_CHG_HR) > 50.00 AND P.PROJ_NUM = A.PROJ_NUM);
	    


/* 9. Write a query that deals with date differences. This query retrieves the columns ASSIGN_NUM, PROJ_NAME, 
      ASSIGN_DATE and DAYS_ELAPSED, which is an alias for the difference in days from each ASSIGN_DATE in the 
	  ASSIGNMENT table, and the date '2010-12-31' (suppose it's the end of the year in 2010 and we want a report 
	  of how many days have elapsed since each assignment was logged). You will also need to join with the PROJECT
	  table as the project name is called for in the result set. The query results are ordered by DAYS_ELAPSED in 
	  descending order.
      Since there is no DATEDIFF function in SQLite, use the julianday() function to calculate a time unit in days.
	  Thus, executing the statement:   SELECT julianday('now') - julianday('2017-12-31') would return a real number that
	  represents the fraction of days between the two dates. This real number should be rounded or cast as an 
	  integer.  For this query, use the CAST (value AS INTEGER) syntax so the result is an integer. This is 
	  appropriate since the dates we are using are discrete. 
      A reference for date/time in SQLite:  http://www.sqlite.org/lang_datefunc.html
	  
	  You should have 25 rows. The first three rows:
	  1001	Amber Wave      2010-03-22	284
      1002	Rolling Tide	2010-03-22	284
      1003	Amber Wave	    2010-03-23	284
*/

SELECT ASSIGN_NUM, PROJ_NAME, ASSIGN_DATE, CAST((julianday('2010-12-31') - julianday(ASSIGN_DATE)) AS INTEGER) AS DAYS_ELAPSED 
FROM ASSIGNMENT JOIN PROJECT USING (PROJ_NUM)
ORDER BY DAYS_ELAPSED DESC;


/* 10. Write an INTERSECT query that returns EMP_NUM, EMP_FNAME, EMP_LNAME for employees who
       have been assigned to both project Amber Wave and project Evergreen. (This is the intersect
	   of two queries, one for each project).
	   You should have two rows.
*/

SELECT DISTINCT EMP_NUM, EMP_FNAME, EMP_LNAME 
FROM EMPLOYEE JOIN ASSIGNMENT USING (EMP_NUM) WHERE PROJ_NUM = 18
INTERSECT 
SELECT DISTINCT EMP_NUM, EMP_FNAME, EMP_LNAME 
FROM EMPLOYEE JOIN ASSIGNMENT USING (EMP_NUM) WHERE PROJ_NUM = 15;

