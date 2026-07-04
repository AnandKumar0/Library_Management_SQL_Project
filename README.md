# Library Management System using SQL Project -- P2

## Project Overview

**Project Title:** Library Management System

**Level:** Intermediate

**Database:** sql_project_p2

**Tools Used:** PostgreSQL, SQL, GitHub

This project demonstrates the implementation of a Library Management System using PostgreSQL. It includes database design, table relationships, CRUD operations, CTAS (Create Table As Select), advanced SQL queries, business reporting, and PL/pgSQL stored procedures.

The objective of this project is to showcase practical SQL skills commonly used in database management, business reporting, and analytical workflows.

---

# Objectives

### Set up the Library Management System Database

Create and populate the database with tables for:

* Branch
* Employees
* Members
* Books
* Issued Status
* Return Status

### CRUD Operations

Perform Create, Read, Update, and Delete operations.

### CTAS (Create Table As Select)

Utilize CTAS to create summary tables from query results.

### Advanced SQL Queries

Develop queries to retrieve, analyze, and summarize library activities.

### Stored Procedures

Implement PL/pgSQL procedures to automate issuing and returning books.

### Reporting

Generate branch reports, active member reports, and performance reports.

---

# Project Structure

## 1. Database Setup

### Database Creation

```sql
CREATE DATABASE library_db;
```

### Table Creation

The following tables were created:

### Branch

```sql
DROP TABLE IF EXISTS branch;

CREATE TABLE branch (

  branch_id VARCHAR(15) PRIMARY KEY,
  
  manager_id VARCHAR(15),
  
  branch_address VARCHAR(30),
  
  contact_no VARCHAR(15)

);
```

---

### Employees

```sql
DROP TABLE IF EXISTS employees;
  
CREATE TABLE employees (
  
  emp_id VARCHAR(50) PRIMARY KEY,
  
  emp_name VARCHAR(50),
  
  position VARCHAR(50),
  
  salary DECIMAL(10,2),
  
  branch_id VARCHAR(20)

);
```

---

### Members

```sql
DROP TABLE IF EXISTS members;

CREATE TABLE members (

  member_id VARCHAR(15) PRIMARY KEY,
  
  member_name VARCHAR(50),
  
  member_address VARCHAR(50),
  
  reg_date DATE

);
```

---

### Books

```sql
DROP TABLE IF EXISTS books;

CREATE TABLE books (

  isbn VARCHAR(60) PRIMARY KEY,
  
  book_title VARCHAR(100),
  
  category VARCHAR(50),
  
  rental_price DECIMAL(10,2),
  
  status VARCHAR(20),
  
  author VARCHAR(50),
  
  publisher VARCHAR(50)

);
```

---

### Issued Status

```sql
DROP TABLE IF EXISTS issued_status;

CREATE TABLE issued_status (

  issued_id VARCHAR(20) PRIMARY KEY,
  
  issued_member_id VARCHAR(50),
  
  issued_book_name VARCHAR(100),
  
  issued_date DATE,
  
  issued_book_isbn VARCHAR(60),
  
  issued_emp_id VARCHAR(50)

);
```

---

### Return Status

```sql
DROP TABLE IF EXISTS return_status;

CREATE TABLE return_status (

  return_id VARCHAR(20) PRIMARY KEY,
  
  issued_id VARCHAR(50),
  
  return_book_name VARCHAR(100),
  
  return_date DATE,
  
  return_book_isbn VARCHAR(60)

);
```

---

## Foreign Keys

Relationships were implemented to maintain data integrity.

```sql
ALTER TABLE issued_status

ADD CONSTRAINT fk_members

FOREIGN KEY (issued_member_id)

REFERENCES members(member_id);
```

```sql
ALTER TABLE issued_status

ADD CONSTRAINT fk_books

FOREIGN KEY (issued_book_isbn)

REFERENCES books(isbn);
```

```sql
ALTER TABLE issued_status

ADD CONSTRAINT fk_employees

FOREIGN KEY (issued_emp_id)

REFERENCES employees(emp_id);
```

```sql
ALTER TABLE employees

ADD CONSTRAINT fk_branch

FOREIGN KEY (branch_id)

REFERENCES branch(branch_id);
```

```sql
ALTER TABLE return_status

ADD CONSTRAINT fk_issued_status

FOREIGN KEY (issued_id)

REFERENCES issued_status(issued_id);
```

---

# 2. CRUD Operations

## Task 1. Create a New Book Record

Objective:

Insert a new book into the books table.

```sql
INSERT INTO books (

  isbn,
  
  book_title,
  
  category,
  
  rental_price,
  
  status,
  
  author,
  
  publisher

)

VALUES (
  
  '978-1-60129-456-2',
  
  'To Kill a Mockingbird',
  
  'Classic',
  
  6.00,
  
  'yes',
  
  'Harper Lee',
  
  'J.B. Lippincott & Co.'

);
```

---

## Task 2. Update an Existing Member Address

Objective:

Update the address of an existing member.

```sql
UPDATE members

SET member_address = '125 Oak St'

WHERE member_id = 'C103';
```

---

## Task 3. Delete Record from Issued Status

Objective:

Delete a specific issued record.

```sql
DELETE FROM issued_status

WHERE issued_id = 'IS121';
```

---

## Task 4. Retrieve Books Issued by Employee

Objective:

Retrieve all books issued by employee E101.

```sql
SELECT *

FROM issued_status

WHERE issued_emp_id='E101';
```

---

## Task 5. Members Who Issued More Than One Book

Objective:

Identify members with multiple book issues.

```sql
SELECT

  issued_emp_id,
  
  COUNT(*)

FROM issued_status

GROUP BY 1

HAVING COUNT(*) > 1;
```

---

# 3. CTAS (Create Table As Select)

## Task 6. Create Book Issue Summary Table

Objective:

Create a summary table containing books and total issue counts.

```sql
CREATE TABLE book_issued_cnt AS

SELECT

  b.isbn,
  
  b.book_title,
  
  COUNT(ist.issued_id) AS issue_count

FROM issued_status ist

JOIN books b

ON ist.issued_book_isbn = b.isbn

GROUP BY
  
  b.isbn,
  
  b.book_title;
```

---

## Task 7. Retrieve All Books in a Specific Category

Objective:

Retrieve all books belonging to the Classic category.
```sql
SELECT *
FROM books
WHERE category = 'Classic';
```

## Task 8. Find Total Rental Income by Category

Objective:

Calculate total rental revenue generated by each book category.
```sql
SELECT
    b.category,
    SUM(b.rental_price) AS total_price,
    COUNT(*) AS total_count
FROM books b
JOIN issued_status ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;
```

## Task 9. List Members Registered in the Last 180 Days

Objective:

Identify recently registered members.

Sample data insertion:

```sql
INSERT INTO members
(member_id, member_name, member_address, reg_date)

VALUES

  ('C150','Sam','145 Main St','2026-04-02'),
  
  ('C151','Kitty','145 Main Mt','2026-05-05');
```

Query:

```sql
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 DAYS';
```


## Task 10. Employee and Manager Analysis

Objective:

Display employee information along with manager details and branch information.

```sql

SELECT

  e1.emp_id,
  
  e1.emp_name,
  
  e1.position,
  
  e1.salary,
  
  b.branch_id,
  
  b.manager_id,
  
  e2.emp_name AS manager

FROM employees e1

JOIN branch b

ON e1.branch_id = b.branch_id

JOIN employees e2

ON e2.emp_id = b.manager_id;
```

## Task 11. Create Expensive Books Table

Objective:

Create a table containing books with rental price greater than $7.

```sql
CREATE TABLE expensive_books AS

SELECT *

FROM books

WHERE rental_price > 7;
```

---

## Task 12. Retrieve Books Not Yet Returned

Objective:

Identify books that have been issued but not returned.

```sql

SELECT *

FROM issued_status ist

LEFT JOIN return_status rs

ON ist.issued_id = rs.issued_id

WHERE rs.return_id IS NULL;
```


## Task 13. Identify Members with Overdue Books

Objective:

Identify members with overdue books assuming a 30-day return period.

Display:

• Member ID

• Member Name

• Book Title

• Issue Date

• Days Overdue

```sql

SELECT

  ist.issued_member_id,
  
  m.member_name,
  
  bk.book_title,
  
  ist.issued_date,
  
  CURRENT_DATE - ist.issued_date AS over_due_days

FROM issued_status ist

JOIN members m

ON ist.issued_member_id = m.member_id

JOIN books bk

ON bk.isbn = ist.issued_book_isbn

LEFT JOIN return_status rs

ON rs.issued_id = ist.issued_id

WHERE rs.return_date IS NULL

AND (CURRENT_DATE - ist.issued_date) > 820

ORDER BY issued_member_id ASC;
```

## Task 14. Update Book Status on Return

Objective:

Update the book status when books are returned.

Manual Process:

```sql

UPDATE books

SET status='no'

WHERE isbn='978-0-451-52994-2';
```

Insert return record:

```sql

INSERT INTO return_status (return_id, issued_id, return_date)

VALUES ('RS125', 'IS130', CURRENT_DATE);
```

Update status:

```sql

UPDATE books

SET status='yes'

WHERE isbn='978-0-451-52994-2';
```


## Task 15. Create Branch Reports Table

Objective:

Generate a branch performance report.

```sql
CREATE TABLE branch_reports AS

SELECT

  b.branch_id,
  
  b.manager_id,
  
  COUNT(ist.issued_id) AS number_book_issued,
  
  COUNT(rs.return_id) AS number_of_book_return,
  
  SUM(bk.rental_price) AS total_revenue

FROM issued_status ist

JOIN employees e

ON e.emp_id = ist.issued_emp_id

JOIN branch b

ON e.branch_id = b.branch_id

LEFT JOIN return_status rs

ON rs.issued_id = ist.issued_id

JOIN books bk

ON ist.issued_book_isbn = bk.isbn

GROUP BY 1,2;
```

## Task 16. Create Table of Active Members

Objective:

Create a table containing members who issued books within the last 27 months.

```sql

CREATE TABLE active_members AS

SELECT *

FROM members

WHERE member_id IN

(

    SELECT DISTINCT
    
    issued_member_id
    
    FROM issued_status
    
    WHERE issued_date >= CURRENT_DATE - INTERVAL '27 month'

);
```

## Task 17. Employees Processing Most Book Issues

Objective:

Find employees who processed the highest number of book issues.

```sql

SELECT

  e.emp_name,
  
  b.*,
  
  COUNT(ist.issued_id)
  
  AS no_book_issued

FROM issued_status ist

JOIN employees e

ON e.emp_id = ist.issued_emp_id

JOIN branch b

ON e.branch_id = b.branch_id

GROUP BY 1,2;
```


 ## Task 18. Book Issuing Procedure

Objective:

Create a procedure to manage book issuance.

Procedure Logic:

• Check availability

• Issue books

• Update status

• Prevent duplicate issuing

• Notify users

Procedure:

```sql

CREATE OR REPLACE PROCEDURE issue_book(

  p_issued_id VARCHAR(20),
  
  p_issued_member_id VARCHAR(50),
  
  p_issued_book_isbn VARCHAR(60),
  
  p_issued_emp_id VARCHAR(50)

)
```
Solution - 

```sql

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(20), p_issued_member_id VARCHAR(50), p_issued_book_isbn VARCHAR(60), p_issued_emp_id VARCHAR(50) )
LANGUAGE plpgsql
AS $$

DECLARE
	v_status VARCHAR(10);

BEGIN
	-- Checking if book is avaiable 'yes'
	SELECT
		status
		INTO
		v_status
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN

		INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES
			(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);


		UPDATE books
			SET status = 'no'
		WHERE isbn = p_issued_book_isbn;

		RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


	ELSE
		RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn : %', p_issued_isbn;
	END IF;

END;
$$



SELECT * FROM books;
-- 978-0-141-44171-6 -- yes
-- 978-0-375-41398-8 -- no
SELECT * FROM issued_status;



CALL issue_book('IS155', 'C108', '978-0-141-44171-6', 'E104');


SELECT * FROM books
WHERE isbn = '978-0-141-44171-6';
```

## Findings :

### Branch Performance

Certain branches generate significantly higher rental revenue compared to others.

### Book Demand

Some books are issued much more frequently than others, indicating high demand categories.

### Revenue Analysis

Rental revenue varies by category and branch.

Tracking rental activity helps identify profitable categories.

### Membership Trends

New registrations provide insights into library growth.

Active members contribute substantially to overall library circulation.

### Overdue Books

Several books remain unreturned beyond the expected return period.

Tracking overdue books helps improve inventory management.

### Employee Insights

A small group of employees process the majority of book issues.

Performance analysis can support better workforce planning.

## Conclusion

This project demonstrates practical PostgreSQL development skills through the implementation of a Library Management System.

The project covers database design, CRUD operations, CTAS implementations, analytical SQL queries, business reporting, and automation through stored procedures.


## Author

Anand Kumar

Aspiring Data Analyst

PostgreSQL | SQL | Power BI | Data Analytics

This project is part of my portfolio showcasing SQL, PostgreSQL, data analysis, database design, and PL/pgSQL skills relevant for Data Analyst and Database Developer roles.

Feel free to connect, provide feedback, or collaborate on future projects.




