-- LIBRARY SYSTEM MANAGEMENT SQL PROJECT

-- Create table 'Branch'

DROP TABLE IF EXISTS branch;
CREATE TABLE branch (
	branch_id VARCHAR(15) PRIMARY KEY,
	manager_id VARCHAR(15),
	branch_address VARCHAR(30),
	contact_no VARCHAR(15)
);

-- Create table 'Employee'

DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
	emp_id VARCHAR(50)PRIMARY KEY,
	emp_name VARCHAR(50),
	position VARCHAR(50),
	salary DECIMAL(10, 2),
	branch_id VARCHAR(20)
);

-- Create table 'Members'

DROP TABLE IF EXISTS members;
CREATE TABLE members (
	member_id VARCHAR(15) PRIMARY KEY,
	member_name VARCHAR(50),
	member_address VARCHAR(50),
	reg_date DATE
);
select * from members;

-- Create table 'Books'

DROP TABLE IF EXISTS books;
CREATE TABLE books (
	isbn VARCHAR(60) PRIMARY KEY,
	book_title VARCHAR(100),
	category VARCHAR(50),
	rental_price DECIMAL(10, 2),
	status VARCHAR(20),
	author VARCHAR(50),
	publisher VARCHAR(50)
);

-- Create table 'Issue_status'

DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status (
	issued_id VARCHAR(20) PRIMARY KEY,
	issued_member_id VARCHAR(50),
	issued_book_name VARCHAR(50),
	issued_date DATE,
	issued_book_isbn VARCHAR(60),
	issued_emp_id VARCHAR(50)
);
ALTER TABLE issued_status
ALTER COLUMN issued_book_name TYPE VARCHAR(100);

select * from issued_status;

-- Create table 'Return_status'

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status (
	return_id VARCHAR(20) PRIMARY KEY,
	issued_id VARCHAR(50),
	return_book_name VARCHAR(100),
	return_date DATE,
	return_book_isbn VARCHAR(60)
);

-- ADD FOREIGN KEYS -- >>

ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);


-- INSERT DATA & PROBLEMS

-- books table -- >> done
-- branch table -->> done
-- employee table -- >> done
-- members table -- >> done
-- issued_status and return_status table have some issues

SELECT *
FROM issued_status
WHERE issued_id='IS101';

DELETE FROM issued_status
WHERE   issued_id =   'IS101';


-- >>> RETRIEVE ALL DATA 

SELECT * FROM books;
SELECT * FROM branch;ys
SELECT * FROM employees;
SELECT * FROM members;
SELECT * FROM issued_status;
SELECT * FROM return_status;


-- >> SOLVE THE PROBLEMS -- >>

-- >>> Intermediate Questions

-- TASK 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;

-- TASK 2.  Update an Existing Member's Address

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

SELECT * FROM members;

-- TASK 3 Delete a Record from the Issued Status Table --

DELETE FROM issued_status
WHERE issued_id = 'IS121';

SELECT * FROM issued_status;


-- TASK 4 Retrieve All Books Issued by a Specific Employee - issued_emp_id = 'E101'
SELECT * FROM issued_status;

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- TASK 5 List Members Who Have Issued More Than One Book

SELECT
	issued_emp_id,
	COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;


-- CTAS (Create Table As Select)

-- TASK 6 -- >> Create Summary Tables

CREATE TABLE book_issued_cnt AS
SELECT
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) AS issue_count
FROM issued_status AS ist
JOIN books AS b
ON ist.issued_book_isbn = b.isbn
GROUP BY
	b.isbn,
	b.book_title;

SELECT * FROM book_issued_cnt;

-- TASK 7 -- > Retrieve All Books in a Specific Category

SELECT * FROM books
WHERE category = 'Classic';


-- TASK 8 ->> Find Total Rental Income by Category:

SELECT
	b.category,
	SUM(b.rental_price) AS total_price,
	COUNT(*) AS total_count
FROM books b
JOIN issued_status ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;


-- TASK 9 - >> List Members Who Registered in the Last 180 Days: (because this has no data so first add data)

INSERT INTO members (member_id, member_name, member_address, reg_date)
VALUES
	('C150', 'Sam', '145 Main St', '2026-04-02'),
	('C151', 'Kitty', '145 Main Mt', '2026-05-05');  -- Now run query

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 DAYS';


-- TASK 10 - >> List Employees with Their Branch Manager's Name and their branch details:

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


-- TASK 11 -- >> Create a Table of Books with Rental Price Above a Certain Threshold( > $7)

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7;

SELECT * FROM expensive_books;


-- TASK 12 -- >> Retrieve the List of Books Not Yet Returned

SELECT *
FROM issued_status ist
LEFT JOIN return_status rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;



-- >>> ADVANCE Type Questions <<<<<>>>>>

-- TASK 13. Identify Members with Overdue Books
	/*Write a query to identify members who have overdue books
	(assume a 30-day return period). 
	Display the member's_id, member's name, book title, issue date, and days overdue.*/

	-- issued_status == members == books == return_status
	-- filter books which is returned
	-- overdue > 30 days -- >> BUT i am writing this query almost 3 years later so days count shoould be more
select * from issued_status;
select * from members;
select * from books;
select * from return_status;

SELECT 
	ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	-- rs.return_date,
	CURRENT_DATE - ist.issued_date AS over_due_days
FROM issued_status ist
JOIN members m
ON ist.issued_member_id = m.member_id
JOIN books bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL AND (CURRENT_DATE - ist.issued_date) > 820
ORDER BY issued_member_id ASC;


-- TASK 14. -->> Update Book Status on Return

	/*Write a query to update the status of books 
	in the books table to "Yes" when they are returned 
	(based on entries in the return_status table).*/


select * from issued_status;
select * from books;
select * from return_status;

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-451-52994-2';

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM return_status
WHERE issued_id = 'IS130';

--
INSERT INTO return_status (return_id, issued_id, return_date)
VALUES
	('RS125', 'IS130', CURRENT_DATE)
	
SELECT * FROM return_status
WHERE issued_id = 'IS130';

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

-- >>> write with STORE PROCEDURE -- >>

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(20) , p_issued_id VARCHAR(20))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(60);
	v_book_name VARCHAR(100);

BEGIN
	INSERT INTO return_status (return_id, issued_id, return_date)
	VALUES
		(p_return_id, p_issued_id, CURRENT_DATE);

	SELECT
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;
	
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$

CALL add_return_records()



-- testing functions -- >> add_return_records()

issued_id = IS135
ibsn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135'


-- Calling function and adding record

CALL add_return_records('RS138', 'IS135');


-- testing records

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';


SELECT * FROM books
where isbn = '978-0-330-25864-8' -- it's status is 'yes'

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-330-25864-8'

CALL add_return_records('RS148', 'IS140');


SELECT * FROM books
WHERE isbn = '978-0-330-25864-8';



-- TASK 15 - >>  Branch Performance Report

	/* Create a query that generates a performance report for each branch,
	showing the number of books issued, the number of books returned, 
	and the total revenue generated from book rentals.
	*/

SELECT * FROM branch;

SELECT * FROM issued_status;

SELECT * FROM employees;

SELECT * FROM books;

SELECT * FROM return_status;




CREATE TABLE branch_reports AS
SELECT
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) AS number_book_issued,
	COUNT(rs.return_id) AS number_of_book_return,
	SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees e
ON e.emp_id = ist.issued_emp_id
JOIN branch b
ON e.branch_id = b.branch_id
LEFT JOIN return_status rs
ON rs.issued_id = ist.issued_id
JOIN books bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2

SELECT * FROM branch_reports;



-- TASK 16 -- >> CTAS : Create a Table of Active Members

	/*Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
	who have issued at least one book in the last 2 months.(i am writing query after 2.5 years so i took 27 months) */ 

SELECT CURRENT_DATE - INTERVAL '27 month'

CREATE TABLE active_members AS
SELECT * 
FROM members
WHERE member_id IN
(
	SELECT 
		DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL ' 27 month'
);

SELECT * FROM active_members;


-- TASK 17 -- >> Find Employees with the Most Book Issues Processed

	/* Write a query to find the top 3 employees who have processed the most book issues.
	Display the employee name, number of books processed, and their branch.*/

SELECT
	e.emp_name,
	b.*,
	COUNT(ist.issued_id) AS no_book_issued
FROM issued_status ist
JOIN employees e
ON e.emp_id = ist.issued_emp_id
JOIN branch b
ON e.branch_id = b.branch_id
GROUP BY 1, 2




-- TASK 18 -- >> Stored Procedure Objective: 
	
	/* Create a stored procedure to manage the status of books in a library system. 
	
	Description:
	
		Write a stored procedure that updates the status of a book in the library based on its issuance. 
	
	The procedure should function as follows: 
	
		The stored procedure should take the book_id as an input parameter. 
		
		The procedure should first check if the book is available (status = 'yes'). 
		
		If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
		
		If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
	*/

SELECT * FROM books;

SELECT * FROM issued_status;


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



--- >>>> END PROJECT <<<<<-----



