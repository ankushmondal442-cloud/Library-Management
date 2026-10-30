-- LIBRARY MANAGEMENT SYSTEM | DBMS PROJECT | GROUP G2
-- Requirements: MySQL 8.0+
-- Run this entire script in MySQL Workbench.
-- Sample data is fictional; fine policy is illustrative only.

DROP DATABASE IF EXISTS library_management_system;
CREATE DATABASE library_management_system
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE library_management_system;

CREATE TABLE authors (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  author_name VARCHAR(120) NOT NULL,
  nationality VARCHAR(60),
  birth_date DATE
);

CREATE TABLE publishers (
  publisher_id INT AUTO_INCREMENT PRIMARY KEY,
  publisher_name VARCHAR(150) NOT NULL UNIQUE,
  city VARCHAR(80),
  phone VARCHAR(20)
);

CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE books (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  isbn VARCHAR(20) UNIQUE,
  title VARCHAR(200) NOT NULL,
  publisher_id INT,
  category_id INT,
  publication_year YEAR,
  edition VARCHAR(40),
  language_name VARCHAR(40) NOT NULL DEFAULT 'English',
  CONSTRAINT fk_books_publisher FOREIGN KEY (publisher_id)
    REFERENCES publishers(publisher_id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_books_category FOREIGN KEY (category_id)
    REFERENCES categories(category_id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE book_authors (
  book_id INT NOT NULL,
  author_id INT NOT NULL,
  PRIMARY KEY (book_id, author_id),
  CONSTRAINT fk_ba_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ba_author FOREIGN KEY (author_id)
    REFERENCES authors(author_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE members (
  member_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(20),
  address VARCHAR(255),
  joined_on DATE NOT NULL DEFAULT (CURRENT_DATE),
  member_status ENUM('ACTIVE','SUSPENDED','CLOSED') NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE book_copies (
  copy_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT NOT NULL,
  accession_no VARCHAR(40) NOT NULL UNIQUE,
  shelf_location VARCHAR(60),
  copy_status ENUM('AVAILABLE','ISSUED','LOST','DAMAGED','WITHDRAWN')
    NOT NULL DEFAULT 'AVAILABLE',
  CONSTRAINT fk_copies_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE loans (
  loan_id INT AUTO_INCREMENT PRIMARY KEY,
  copy_id INT NOT NULL,
  member_id INT NOT NULL,
  issue_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  due_date DATE NOT NULL,
  return_date DATE NULL,
  loan_status ENUM('ISSUED','RETURNED','OVERDUE','LOST') NOT NULL DEFAULT 'ISSUED',
  issued_by VARCHAR(100),
  returned_by VARCHAR(100),
  active_copy_id INT GENERATED ALWAYS AS
    (CASE WHEN return_date IS NULL THEN copy_id ELSE NULL END) STORED,
  CONSTRAINT fk_loans_copy FOREIGN KEY (copy_id)
    REFERENCES book_copies(copy_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_loans_member FOREIGN KEY (member_id)
    REFERENCES members(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_due_date CHECK (due_date >= issue_date),
  UNIQUE KEY uq_one_active_loan_per_copy (active_copy_id),
  INDEX idx_loans_member_status (member_id, loan_status),
  INDEX idx_loans_due_date (due_date)
);

CREATE TABLE reservations (
  reservation_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT NOT NULL,
  member_id INT NOT NULL,
  reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reservation_status ENUM('WAITING','FULFILLED','CANCELLED') NOT NULL DEFAULT 'WAITING',
  notes VARCHAR(255),
  CONSTRAINT fk_res_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_res_member FOREIGN KEY (member_id)
    REFERENCES members(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_reservation_queue (book_id, reservation_status, reservation_date)
);

CREATE TABLE fines (
  fine_id INT AUTO_INCREMENT PRIMARY KEY,
  loan_id INT NOT NULL UNIQUE,
  amount DECIMAL(8,2) NOT NULL DEFAULT 0.00,
  reason VARCHAR(200) NOT NULL,
  assessed_on DATE NOT NULL DEFAULT (CURRENT_DATE),
  payment_status ENUM('UNPAID','PAID','WAIVED') NOT NULL DEFAULT 'UNPAID',
  paid_on DATE NULL,
  CONSTRAINT fk_fines_loan FOREIGN KEY (loan_id)
    REFERENCES loans(loan_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_fine_amount CHECK (amount >= 0)
);

-- SAMPLE DATA
INSERT INTO authors (author_name, nationality, birth_date) VALUES
('George Orwell','British','1903-06-25'),
('J. K. Rowling','British','1965-07-31'),
('R. K. Narayan','Indian','1906-10-10'),
('A. P. J. Abdul Kalam','Indian','1931-10-15'),
('Robert C. Martin','American','1952-12-05'),
('Silberschatz, Korth and Sudarshan','American',NULL);

INSERT INTO publishers (publisher_name, city, phone) VALUES
('Penguin Books','London',NULL),('Bloomsbury','London',NULL),
('Indian Thought Publications','Chennai',NULL),('Universities Press','Hyderabad',NULL),
('Pearson','London',NULL),('McGraw Hill','New York',NULL);

INSERT INTO categories (category_name) VALUES
('Fiction'),('Fantasy'),('Indian Literature'),('Biography'),('Programming'),('Database Systems');

INSERT INTO books (isbn,title,publisher_id,category_id,publication_year,edition,language_name) VALUES
('9780451524935','1984',1,1,1949,'Reprint','English'),
('9780747532699','Harry Potter and the Philosopher''s Stone',2,2,1997,'First','English'),
('9788185986173','Malgudi Days',3,3,1943,'Reprint','English'),
('9788173711466','Wings of Fire',4,4,1999,'Reprint','English'),
('9780132350884','Clean Code',5,5,2008,'First','English'),
('9780073523323','Database System Concepts',6,6,2019,'7th','English');

INSERT INTO book_authors (book_id,author_id) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),(6,6);

INSERT INTO members (full_name,email,phone,address,joined_on,member_status) VALUES
('Aarav Sen','aarav.sen@example.com','9000000001','Kolkata, West Bengal','2026-01-10','ACTIVE'),
('Mira Das','mira.das@example.com','9000000002','Barasat, West Bengal','2026-02-05','ACTIVE'),
('Rahul Roy','rahul.roy@example.com','9000000003','Habra, West Bengal','2026-03-12','ACTIVE'),
('Priya Ghosh','priya.ghosh@example.com','9000000004','Kolkata, West Bengal','2026-04-18','SUSPENDED');

INSERT INTO book_copies (book_id,accession_no,shelf_location,copy_status) VALUES
(1,'ACC-1984-001','A1-01','AVAILABLE'),
(1,'ACC-1984-002','A1-01','ISSUED'),
(2,'ACC-HP-001','B2-03','AVAILABLE'),
(3,'ACC-MD-001','C1-02','AVAILABLE'),
(4,'ACC-WOF-001','D1-04','AVAILABLE'),
(5,'ACC-CC-001','E3-01','ISSUED'),
(6,'ACC-DB-001','E3-02','AVAILABLE');

INSERT INTO loans (copy_id,member_id,issue_date,due_date,return_date,loan_status,issued_by,returned_by) VALUES
(2,1,'2026-10-01','2026-10-15',NULL,'ISSUED','Librarian A',NULL),
(6,2,'2026-09-01','2026-09-15','2026-09-20','RETURNED','Librarian A','Librarian B');

INSERT INTO reservations (book_id,member_id,reservation_status,notes) VALUES
(1,3,'WAITING','Notify member when a copy is available');

INSERT INTO fines (loan_id,amount,reason,assessed_on,payment_status) VALUES
(2,25.00,'Late return: 5 days at Rs. 5 per day','2026-09-20','UNPAID');

-- ============================================================
-- 200 SQL QUERIES: LIBRARY MANAGEMENT SYSTEM
-- MySQL 8.0+ | Run SELECT queries individually as required.
-- Query bank includes catalogue, members, inventory, circulation,
-- reservations, fines, dashboards, CTEs and window functions.
-- ============================================================

-- Q001. Complete book catalogue
SELECT b.book_id,b.title,b.isbn,c.category_name,p.publisher_name,b.publication_year,b.edition,b.language_name FROM books b LEFT JOIN categories c ON c.category_id=b.category_id LEFT JOIN publishers p ON p.publisher_id=b.publisher_id ORDER BY b.title;

-- Q002. Catalogue with author names
SELECT b.book_id,b.title,GROUP_CONCAT(a.author_name ORDER BY a.author_name SEPARATOR ', ') AS authors FROM books b LEFT JOIN book_authors ba ON ba.book_id=b.book_id LEFT JOIN authors a ON a.author_id=ba.author_id GROUP BY b.book_id,b.title ORDER BY b.title;

-- Q003. Books published after 2000
SELECT book_id,title,publication_year FROM books WHERE publication_year>2000 ORDER BY publication_year DESC;

-- Q004. Books published before 2000
SELECT book_id,title,publication_year FROM books WHERE publication_year<2000 ORDER BY publication_year;

-- Q005. Books with missing ISBN
SELECT book_id,title FROM books WHERE isbn IS NULL OR isbn='';

-- Q006. Books without a publisher
SELECT book_id,title FROM books WHERE publisher_id IS NULL;

-- Q007. Books without a category
SELECT book_id,title FROM books WHERE category_id IS NULL;

-- Q008. Books by English language
SELECT book_id,title FROM books WHERE language_name='English' ORDER BY title;

-- Q009. Books by non-English language
SELECT book_id,title,language_name FROM books WHERE language_name<>'English' ORDER BY language_name,title;

-- Q010. Books with title containing 'data'
SELECT book_id,title FROM books WHERE title LIKE '%data%';

-- Q011. Books with title starting with 'The'
SELECT book_id,title FROM books WHERE title LIKE 'The%';

-- Q012. Books with title ending in 's'
SELECT book_id,title FROM books WHERE title LIKE '%s';

-- Q013. Books with title length above 15
SELECT book_id,title,CHAR_LENGTH(title) AS title_length FROM books WHERE CHAR_LENGTH(title)>15 ORDER BY title_length DESC;

-- Q014. Books sorted newest first
SELECT book_id,title,publication_year FROM books ORDER BY publication_year DESC,title;

-- Q015. Books sorted oldest first
SELECT book_id,title,publication_year FROM books ORDER BY publication_year,title;

-- Q016. Distinct publication years
SELECT DISTINCT publication_year FROM books WHERE publication_year IS NOT NULL ORDER BY publication_year;

-- Q017. Books in selected publication-year range
SELECT book_id,title,publication_year FROM books WHERE publication_year BETWEEN 1990 AND 2025 ORDER BY publication_year;

-- Q018. Books with edition information
SELECT book_id,title,edition FROM books WHERE edition IS NOT NULL ORDER BY title;

-- Q019. Books grouped by language
SELECT language_name,COUNT(*) AS title_count FROM books GROUP BY language_name ORDER BY title_count DESC;

-- Q020. Book count by publication year
SELECT publication_year,COUNT(*) AS title_count FROM books GROUP BY publication_year ORDER BY publication_year;

-- Q021. All authors
SELECT * FROM authors ORDER BY author_name;

-- Q022. Authors with nationality
SELECT author_name,nationality FROM authors WHERE nationality IS NOT NULL ORDER BY nationality,author_name;

-- Q023. Indian authors
SELECT author_id,author_name FROM authors WHERE nationality='Indian';

-- Q024. British authors
SELECT author_id,author_name FROM authors WHERE nationality='British';

-- Q025. Authors born before 1950
SELECT author_name,birth_date FROM authors WHERE birth_date<'1950-01-01' ORDER BY birth_date;

-- Q026. Authors born after 1950
SELECT author_name,birth_date FROM authors WHERE birth_date>='1950-01-01' ORDER BY birth_date;

-- Q027. Authors with unknown birth date
SELECT author_id,author_name FROM authors WHERE birth_date IS NULL;

-- Q028. Author and book mapping
SELECT a.author_name,b.title FROM authors a JOIN book_authors ba ON ba.author_id=a.author_id JOIN books b ON b.book_id=ba.book_id ORDER BY a.author_name;

-- Q029. Number of books per author
SELECT a.author_name,COUNT(ba.book_id) AS book_count FROM authors a LEFT JOIN book_authors ba ON ba.author_id=a.author_id GROUP BY a.author_id,a.author_name ORDER BY book_count DESC;

-- Q030. Authors who have no books
SELECT a.author_id,a.author_name FROM authors a LEFT JOIN book_authors ba ON ba.author_id=a.author_id WHERE ba.book_id IS NULL;

-- Q031. All publishers
SELECT * FROM publishers ORDER BY publisher_name;

-- Q032. Publishers by city
SELECT city,COUNT(*) AS publisher_count FROM publishers GROUP BY city ORDER BY publisher_count DESC;

-- Q033. Publishers located in London
SELECT publisher_id,publisher_name FROM publishers WHERE city='London';

-- Q034. Publishers with phone numbers
SELECT publisher_id,publisher_name,phone FROM publishers WHERE phone IS NOT NULL;

-- Q035. Books per publisher
SELECT p.publisher_name,COUNT(b.book_id) AS title_count FROM publishers p LEFT JOIN books b ON b.publisher_id=p.publisher_id GROUP BY p.publisher_id,p.publisher_name ORDER BY title_count DESC;

-- Q036. Publishers with no books
SELECT p.publisher_id,p.publisher_name FROM publishers p LEFT JOIN books b ON b.publisher_id=p.publisher_id WHERE b.book_id IS NULL;

-- Q037. All categories
SELECT * FROM categories ORDER BY category_name;

-- Q038. Number of books in each category
SELECT c.category_name,COUNT(b.book_id) AS title_count FROM categories c LEFT JOIN books b ON b.category_id=c.category_id GROUP BY c.category_id,c.category_name ORDER BY title_count DESC;

-- Q039. Categories containing more than one title
SELECT c.category_name,COUNT(b.book_id) AS title_count FROM categories c JOIN books b ON b.category_id=c.category_id GROUP BY c.category_id,c.category_name HAVING COUNT(b.book_id)>1;

-- Q040. Categories with no books
SELECT c.category_id,c.category_name FROM categories c LEFT JOIN books b ON b.category_id=c.category_id WHERE b.book_id IS NULL;

-- Q041. All members
SELECT * FROM members ORDER BY full_name;

-- Q042. Active members
SELECT member_id,full_name,email FROM members WHERE member_status='ACTIVE' ORDER BY full_name;

-- Q043. Suspended members
SELECT member_id,full_name,email FROM members WHERE member_status='SUSPENDED';

-- Q044. Closed members
SELECT member_id,full_name,email FROM members WHERE member_status='CLOSED';

-- Q045. Members who joined in 2026
SELECT member_id,full_name,joined_on FROM members WHERE YEAR(joined_on)=2026 ORDER BY joined_on;

-- Q046. Members who joined in January
SELECT member_id,full_name,joined_on FROM members WHERE MONTH(joined_on)=1;

-- Q047. Members who joined in first half of year
SELECT member_id,full_name,joined_on FROM members WHERE MONTH(joined_on) BETWEEN 1 AND 6;

-- Q048. Members sorted by joining date
SELECT member_id,full_name,joined_on FROM members ORDER BY joined_on DESC;

-- Q049. Members with missing phone
SELECT member_id,full_name FROM members WHERE phone IS NULL OR phone='';

-- Q050. Members with an email from example.com
SELECT member_id,full_name,email FROM members WHERE email LIKE '%@example.com';

-- Q051. Members living in Kolkata
SELECT member_id,full_name,address FROM members WHERE address LIKE '%Kolkata%';

-- Q052. Members living in West Bengal
SELECT member_id,full_name,address FROM members WHERE address LIKE '%West Bengal%';

-- Q053. Member count by status
SELECT member_status,COUNT(*) AS member_count FROM members GROUP BY member_status;

-- Q054. Member count by city/address
SELECT address,COUNT(*) AS member_count FROM members GROUP BY address ORDER BY member_count DESC;

-- Q055. Members who have borrowed books
SELECT DISTINCT m.member_id,m.full_name FROM members m JOIN loans l ON l.member_id=m.member_id;

-- Q056. Members who never borrowed books
SELECT m.member_id,m.full_name FROM members m WHERE NOT EXISTS (SELECT 1 FROM loans l WHERE l.member_id=m.member_id);

-- Q057. Members with more than one loan
SELECT m.member_id,m.full_name,COUNT(l.loan_id) AS loan_count FROM members m JOIN loans l ON l.member_id=m.member_id GROUP BY m.member_id,m.full_name HAVING COUNT(l.loan_id)>1;

-- Q058. Member loan history
SELECT m.full_name,l.loan_id,l.issue_date,l.due_date,l.return_date,l.loan_status FROM members m JOIN loans l ON l.member_id=m.member_id ORDER BY m.full_name,l.issue_date DESC;

-- Q059. Members with unpaid fines
SELECT DISTINCT m.member_id,m.full_name FROM members m JOIN loans l ON l.member_id=m.member_id JOIN fines f ON f.loan_id=l.loan_id WHERE f.payment_status='UNPAID';

-- Q060. Members with no reservations
SELECT m.member_id,m.full_name FROM members m LEFT JOIN reservations r ON r.member_id=m.member_id WHERE r.reservation_id IS NULL;

-- Q061. Members who made reservations
SELECT DISTINCT m.member_id,m.full_name FROM members m JOIN reservations r ON r.member_id=m.member_id;

-- Q062. Member email domain summary
SELECT SUBSTRING_INDEX(email,'@',-1) AS email_domain,COUNT(*) AS members FROM members GROUP BY email_domain;

-- Q063. Search member by name keyword 'a'
SELECT member_id,full_name,email FROM members WHERE full_name LIKE '%a%';

-- Q064. Members joined in last 90 days
SELECT member_id,full_name,joined_on FROM members WHERE joined_on>=DATE_SUB(CURRENT_DATE,INTERVAL 90 DAY);

-- Q065. Members with longest membership
SELECT member_id,full_name,joined_on,DATEDIFF(CURRENT_DATE,joined_on) AS membership_days FROM members ORDER BY membership_days DESC;

-- Q066. All physical copies
SELECT bc.copy_id,b.title,bc.accession_no,bc.shelf_location,bc.copy_status FROM book_copies bc JOIN books b ON b.book_id=bc.book_id ORDER BY b.title,bc.copy_id;

-- Q067. Available copies
SELECT bc.copy_id,b.title,bc.accession_no FROM book_copies bc JOIN books b ON b.book_id=bc.book_id WHERE bc.copy_status='AVAILABLE' ORDER BY b.title;

-- Q068. Issued copies
SELECT bc.copy_id,b.title,bc.accession_no FROM book_copies bc JOIN books b ON b.book_id=bc.book_id WHERE bc.copy_status='ISSUED';

-- Q069. Lost copies
SELECT bc.copy_id,b.title,bc.accession_no FROM book_copies bc JOIN books b ON b.book_id=bc.book_id WHERE bc.copy_status='LOST';

-- Q070. Damaged copies
SELECT bc.copy_id,b.title,bc.accession_no FROM book_copies bc JOIN books b ON b.book_id=bc.book_id WHERE bc.copy_status='DAMAGED';

-- Q071. Withdrawn copies
SELECT bc.copy_id,b.title,bc.accession_no FROM book_copies bc JOIN books b ON b.book_id=bc.book_id WHERE bc.copy_status='WITHDRAWN';

-- Q072. Copy count by status
SELECT copy_status,COUNT(*) AS copy_count FROM book_copies GROUP BY copy_status;

-- Q073. Copy count by book
SELECT b.title,COUNT(bc.copy_id) AS total_copies FROM books b LEFT JOIN book_copies bc ON bc.book_id=b.book_id GROUP BY b.book_id,b.title ORDER BY total_copies DESC;

-- Q074. Available copy count by book
SELECT b.title,SUM(bc.copy_status='AVAILABLE') AS available_copies FROM books b LEFT JOIN book_copies bc ON bc.book_id=b.book_id GROUP BY b.book_id,b.title;

-- Q075. Books with zero physical copies
SELECT b.book_id,b.title FROM books b LEFT JOIN book_copies bc ON bc.book_id=b.book_id WHERE bc.copy_id IS NULL;

-- Q076. Books with at least one available copy
SELECT DISTINCT b.book_id,b.title FROM books b JOIN book_copies bc ON bc.book_id=b.book_id WHERE bc.copy_status='AVAILABLE';

-- Q077. Books with no available copies
SELECT b.book_id,b.title FROM books b WHERE NOT EXISTS (SELECT 1 FROM book_copies bc WHERE bc.book_id=b.book_id AND bc.copy_status='AVAILABLE');

-- Q078. Copies by shelf location
SELECT shelf_location,COUNT(*) AS copy_count FROM book_copies GROUP BY shelf_location ORDER BY shelf_location;

-- Q079. Copies on shelf A1-01
SELECT copy_id,accession_no,copy_status FROM book_copies WHERE shelf_location='A1-01';

-- Q080. Accession numbers in ascending order
SELECT accession_no,book_id,copy_status FROM book_copies ORDER BY accession_no;

-- Q081. Copies added for a selected book
SELECT bc.copy_id,bc.accession_no,bc.copy_status FROM book_copies bc WHERE bc.book_id=1;

-- Q082. Inventory summary by category
SELECT c.category_name,COUNT(bc.copy_id) AS physical_copies FROM categories c LEFT JOIN books b ON b.category_id=c.category_id LEFT JOIN book_copies bc ON bc.book_id=b.book_id GROUP BY c.category_id,c.category_name;

-- Q083. Inventory with publisher
SELECT b.title,p.publisher_name,bc.accession_no,bc.copy_status FROM book_copies bc JOIN books b ON b.book_id=bc.book_id LEFT JOIN publishers p ON p.publisher_id=b.publisher_id;

-- Q084. Copies whose status is not available
SELECT copy_id,accession_no,copy_status FROM book_copies WHERE copy_status<>'AVAILABLE';

-- Q085. Books with more than one copy
SELECT b.title,COUNT(bc.copy_id) AS copies FROM books b JOIN book_copies bc ON bc.book_id=b.book_id GROUP BY b.book_id,b.title HAVING COUNT(bc.copy_id)>1;

-- Q086. Books with exactly one copy
SELECT b.title,COUNT(bc.copy_id) AS copies FROM books b JOIN book_copies bc ON bc.book_id=b.book_id GROUP BY b.book_id,b.title HAVING COUNT(bc.copy_id)=1;

-- Q087. Inventory percentage by status
SELECT copy_status,COUNT(*) AS copies,ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM book_copies),2) AS percentage FROM book_copies GROUP BY copy_status;

-- Q088. Copies with accession number pattern ACC-1984
SELECT copy_id,accession_no FROM book_copies WHERE accession_no LIKE 'ACC-1984%';

-- Q089. Find duplicate shelf locations
SELECT shelf_location,COUNT(*) AS copies FROM book_copies WHERE shelf_location IS NOT NULL GROUP BY shelf_location HAVING COUNT(*)>1;

-- Q090. Inventory ordered by book and shelf
SELECT b.title,bc.shelf_location,bc.accession_no FROM book_copies bc JOIN books b ON b.book_id=bc.book_id ORDER BY b.title,bc.shelf_location;

-- Q091. All loan transactions
SELECT * FROM loans ORDER BY issue_date DESC;

-- Q092. Current active loans
SELECT l.loan_id,m.full_name,b.title,l.issue_date,l.due_date FROM loans l JOIN members m ON m.member_id=l.member_id JOIN book_copies bc ON bc.copy_id=l.copy_id JOIN books b ON b.book_id=bc.book_id WHERE l.return_date IS NULL;

-- Q093. Returned loans
SELECT l.loan_id,m.full_name,b.title,l.issue_date,l.return_date FROM loans l JOIN members m ON m.member_id=l.member_id JOIN book_copies bc ON bc.copy_id=l.copy_id JOIN books b ON b.book_id=bc.book_id WHERE l.return_date IS NOT NULL;

-- Q094. Overdue loans as of today
SELECT l.loan_id,m.full_name,b.title,l.due_date,DATEDIFF(CURRENT_DATE,l.due_date) AS days_overdue FROM loans l JOIN members m ON m.member_id=l.member_id JOIN book_copies bc ON bc.copy_id=l.copy_id JOIN books b ON b.book_id=bc.book_id WHERE l.return_date IS NULL AND l.due_date<CURRENT_DATE;

-- Q095. Loans due today
SELECT loan_id,member_id,copy_id,due_date FROM loans WHERE return_date IS NULL AND due_date=CURRENT_DATE;

-- Q096. Loans due in next 7 days
SELECT loan_id,member_id,copy_id,due_date FROM loans WHERE return_date IS NULL AND due_date BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE,INTERVAL 7 DAY);

-- Q097. Loans issued this month
SELECT loan_id,member_id,copy_id,issue_date FROM loans WHERE YEAR(issue_date)=YEAR(CURRENT_DATE) AND MONTH(issue_date)=MONTH(CURRENT_DATE);

-- Q098. Loans issued in 2026
SELECT loan_id,member_id,issue_date FROM loans WHERE YEAR(issue_date)=2026;

-- Q099. Loans returned late
SELECT loan_id,member_id,issue_date,due_date,return_date,DATEDIFF(return_date,due_date) AS days_late FROM loans WHERE return_date>due_date;

-- Q100. Loans returned on time
SELECT loan_id,member_id,issue_date,due_date,return_date FROM loans WHERE return_date IS NOT NULL AND return_date<=due_date;

-- Q101. Average loan duration
SELECT ROUND(AVG(DATEDIFF(return_date,issue_date)),2) AS avg_days FROM loans WHERE return_date IS NOT NULL;

-- Q102. Longest loan duration
SELECT loan_id,DATEDIFF(COALESCE(return_date,CURRENT_DATE),issue_date) AS duration_days FROM loans ORDER BY duration_days DESC LIMIT 1;

-- Q103. Loan count by status
SELECT loan_status,COUNT(*) AS loan_count FROM loans GROUP BY loan_status;

-- Q104. Loan count by member
SELECT m.member_id,m.full_name,COUNT(l.loan_id) AS total_loans FROM members m LEFT JOIN loans l ON l.member_id=m.member_id GROUP BY m.member_id,m.full_name ORDER BY total_loans DESC;

-- Q105. Loan count by month
SELECT DATE_FORMAT(issue_date,'%Y-%m') AS issue_month,COUNT(*) AS total_loans FROM loans GROUP BY issue_month ORDER BY issue_month;

-- Q106. Loan count by year
SELECT YEAR(issue_date) AS issue_year,COUNT(*) AS total_loans FROM loans GROUP BY YEAR(issue_date) ORDER BY issue_year;

-- Q107. Books most frequently borrowed
SELECT b.title,COUNT(l.loan_id) AS borrow_count FROM books b JOIN book_copies bc ON bc.book_id=b.book_id JOIN loans l ON l.copy_id=bc.copy_id GROUP BY b.book_id,b.title ORDER BY borrow_count DESC;

-- Q108. Members with active loans
SELECT DISTINCT m.member_id,m.full_name FROM members m JOIN loans l ON l.member_id=m.member_id WHERE l.return_date IS NULL;

-- Q109. Members with overdue loans
SELECT DISTINCT m.member_id,m.full_name FROM members m JOIN loans l ON l.member_id=m.member_id WHERE l.return_date IS NULL AND l.due_date<CURRENT_DATE;

-- Q110. Loans processed by each staff member
SELECT issued_by,COUNT(*) AS issued_count FROM loans GROUP BY issued_by ORDER BY issued_count DESC;

-- Q111. Returns processed by each staff member
SELECT returned_by,COUNT(*) AS return_count FROM loans WHERE returned_by IS NOT NULL GROUP BY returned_by;

-- Q112. Loans without a return staff entry
SELECT loan_id,copy_id,member_id FROM loans WHERE return_date IS NOT NULL AND returned_by IS NULL;

-- Q113. Loans with due date in current year
SELECT loan_id,member_id,due_date FROM loans WHERE YEAR(due_date)=YEAR(CURRENT_DATE);

-- Q114. Loan details with copy accession number
SELECT l.loan_id,m.full_name,b.title,bc.accession_no,l.issue_date,l.due_date,l.return_date FROM loans l JOIN members m ON m.member_id=l.member_id JOIN book_copies bc ON bc.copy_id=l.copy_id JOIN books b ON b.book_id=bc.book_id;

-- Q115. Members who borrowed a particular title
SELECT DISTINCT m.member_id,m.full_name FROM members m JOIN loans l ON l.member_id=m.member_id JOIN book_copies bc ON bc.copy_id=l.copy_id WHERE bc.book_id=1;

-- Q116. Books never borrowed
SELECT b.book_id,b.title FROM books b WHERE NOT EXISTS (SELECT 1 FROM book_copies bc JOIN loans l ON l.copy_id=bc.copy_id WHERE bc.book_id=b.book_id);

-- Q117. Loans with issue date before due date
SELECT loan_id,issue_date,due_date FROM loans WHERE issue_date<due_date;

-- Q118. Loan records with issue and return dates
SELECT loan_id,issue_date,return_date,DATEDIFF(return_date,issue_date) AS days_kept FROM loans WHERE return_date IS NOT NULL;

-- Q119. Members whose total loan count is above average
SELECT m.member_id,m.full_name,COUNT(l.loan_id) AS loan_count FROM members m JOIN loans l ON l.member_id=m.member_id GROUP BY m.member_id,m.full_name HAVING COUNT(l.loan_id)>(SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM loans GROUP BY member_id) x);

-- Q120. Latest 10 loan transactions
SELECT loan_id,member_id,copy_id,issue_date,loan_status FROM loans ORDER BY issue_date DESC LIMIT 10;

-- Q121. All reservations
SELECT r.reservation_id,m.full_name,b.title,r.reservation_date,r.reservation_status,r.notes FROM reservations r JOIN members m ON m.member_id=r.member_id JOIN books b ON b.book_id=r.book_id ORDER BY r.reservation_date;

-- Q122. Waiting reservations
SELECT r.reservation_id,m.full_name,b.title,r.reservation_date FROM reservations r JOIN members m ON m.member_id=r.member_id JOIN books b ON b.book_id=r.book_id WHERE r.reservation_status='WAITING' ORDER BY r.reservation_date;

-- Q123. Fulfilled reservations
SELECT reservation_id,book_id,member_id,reservation_date FROM reservations WHERE reservation_status='FULFILLED';

-- Q124. Cancelled reservations
SELECT reservation_id,book_id,member_id,reservation_date FROM reservations WHERE reservation_status='CANCELLED';

-- Q125. Reservation count by status
SELECT reservation_status,COUNT(*) AS total FROM reservations GROUP BY reservation_status;

-- Q126. Reservation count by book
SELECT b.title,COUNT(r.reservation_id) AS reservation_count FROM books b LEFT JOIN reservations r ON r.book_id=b.book_id GROUP BY b.book_id,b.title ORDER BY reservation_count DESC;

-- Q127. Reservation count by member
SELECT m.full_name,COUNT(r.reservation_id) AS reservation_count FROM members m LEFT JOIN reservations r ON r.member_id=m.member_id GROUP BY m.member_id,m.full_name ORDER BY reservation_count DESC;

-- Q128. Books with waiting list
SELECT DISTINCT b.book_id,b.title FROM books b JOIN reservations r ON r.book_id=b.book_id WHERE r.reservation_status='WAITING';

-- Q129. Members with waiting reservations
SELECT DISTINCT m.member_id,m.full_name FROM members m JOIN reservations r ON r.member_id=m.member_id WHERE r.reservation_status='WAITING';

-- Q130. Reservation queue for book ID 1
SELECT r.reservation_id,m.full_name,r.reservation_date FROM reservations r JOIN members m ON m.member_id=r.member_id WHERE r.book_id=1 AND r.reservation_status='WAITING' ORDER BY r.reservation_date;

-- Q131. Oldest waiting reservation
SELECT reservation_id,book_id,member_id,reservation_date FROM reservations WHERE reservation_status='WAITING' ORDER BY reservation_date LIMIT 1;

-- Q132. Reservations made this month
SELECT reservation_id,book_id,member_id,reservation_date FROM reservations WHERE YEAR(reservation_date)=YEAR(CURRENT_DATE) AND MONTH(reservation_date)=MONTH(CURRENT_DATE);

-- Q133. Reservations made in 2026
SELECT reservation_id,book_id,member_id,reservation_date FROM reservations WHERE YEAR(reservation_date)=2026;

-- Q134. Members who reserved and borrowed
SELECT DISTINCT m.member_id,m.full_name FROM members m JOIN reservations r ON r.member_id=m.member_id JOIN loans l ON l.member_id=m.member_id;

-- Q135. Waiting reservations for unavailable books
SELECT r.reservation_id,b.title,m.full_name FROM reservations r JOIN books b ON b.book_id=r.book_id JOIN members m ON m.member_id=r.member_id WHERE r.reservation_status='WAITING' AND NOT EXISTS (SELECT 1 FROM book_copies bc WHERE bc.book_id=b.book_id AND bc.copy_status='AVAILABLE');

-- Q136. Books having no reservations
SELECT b.book_id,b.title FROM books b LEFT JOIN reservations r ON r.book_id=b.book_id WHERE r.reservation_id IS NULL;

-- Q137. Reservations with member status
SELECT r.reservation_id,b.title,m.full_name,m.member_status,r.reservation_status FROM reservations r JOIN books b ON b.book_id=r.book_id JOIN members m ON m.member_id=r.member_id;

-- Q138. Average reservations per title
SELECT ROUND(AVG(res_count),2) AS avg_reservations FROM (SELECT b.book_id,COUNT(r.reservation_id) AS res_count FROM books b LEFT JOIN reservations r ON r.book_id=b.book_id GROUP BY b.book_id) x;

-- Q139. Reservation dates sorted newest first
SELECT reservation_id,book_id,member_id,reservation_date FROM reservations ORDER BY reservation_date DESC;

-- Q140. Members with more than one reservation
SELECT m.member_id,m.full_name,COUNT(r.reservation_id) AS total_reservations FROM members m JOIN reservations r ON r.member_id=m.member_id GROUP BY m.member_id,m.full_name HAVING COUNT(r.reservation_id)>1;

-- Q141. All fines with member and book
SELECT f.fine_id,m.full_name,b.title,f.amount,f.reason,f.payment_status FROM fines f JOIN loans l ON l.loan_id=f.loan_id JOIN members m ON m.member_id=l.member_id JOIN book_copies bc ON bc.copy_id=l.copy_id JOIN books b ON b.book_id=bc.book_id;

-- Q142. Unpaid fines
SELECT fine_id,loan_id,amount,reason FROM fines WHERE payment_status='UNPAID';

-- Q143. Paid fines
SELECT fine_id,loan_id,amount,paid_on FROM fines WHERE payment_status='PAID';

-- Q144. Waived fines
SELECT fine_id,loan_id,amount,reason FROM fines WHERE payment_status='WAIVED';

-- Q145. Total fine amount
SELECT COALESCE(SUM(amount),0) AS total_fines FROM fines;

-- Q146. Total unpaid fine amount
SELECT COALESCE(SUM(amount),0) AS unpaid_amount FROM fines WHERE payment_status='UNPAID';

-- Q147. Total paid fine amount
SELECT COALESCE(SUM(amount),0) AS paid_amount FROM fines WHERE payment_status='PAID';

-- Q148. Average fine amount
SELECT ROUND(AVG(amount),2) AS average_fine FROM fines;

-- Q149. Maximum fine amount
SELECT MAX(amount) AS highest_fine FROM fines;

-- Q150. Minimum fine amount
SELECT MIN(amount) AS lowest_fine FROM fines;

-- Q151. Fine count by payment status
SELECT payment_status,COUNT(*) AS fine_count FROM fines GROUP BY payment_status;

-- Q152. Fine amount by payment status
SELECT payment_status,SUM(amount) AS total_amount FROM fines GROUP BY payment_status;

-- Q153. Members with unpaid fine totals
SELECT m.member_id,m.full_name,SUM(f.amount) AS unpaid_total FROM members m JOIN loans l ON l.member_id=m.member_id JOIN fines f ON f.loan_id=l.loan_id WHERE f.payment_status='UNPAID' GROUP BY m.member_id,m.full_name;

-- Q154. Fines assessed this month
SELECT fine_id,loan_id,amount,assessed_on FROM fines WHERE YEAR(assessed_on)=YEAR(CURRENT_DATE) AND MONTH(assessed_on)=MONTH(CURRENT_DATE);

-- Q155. Fines assessed in 2026
SELECT fine_id,loan_id,amount,assessed_on FROM fines WHERE YEAR(assessed_on)=2026;

-- Q156. Fines assessed in last 30 days
SELECT fine_id,loan_id,amount,assessed_on FROM fines WHERE assessed_on>=DATE_SUB(CURRENT_DATE,INTERVAL 30 DAY);

-- Q157. Fines above Rs. 20
SELECT fine_id,loan_id,amount FROM fines WHERE amount>20 ORDER BY amount DESC;

-- Q158. Loans without fine records
SELECT l.loan_id,l.member_id,l.copy_id FROM loans l LEFT JOIN fines f ON f.loan_id=l.loan_id WHERE f.fine_id IS NULL;

-- Q159. Fines linked to late returns
SELECT f.fine_id,l.loan_id,f.amount,l.due_date,l.return_date FROM fines f JOIN loans l ON l.loan_id=f.loan_id WHERE l.return_date>l.due_date;

-- Q160. Fine payment completion details
SELECT fine_id,amount,payment_status,assessed_on,paid_on, DATEDIFF(COALESCE(paid_on,CURRENT_DATE),assessed_on) AS days_to_payment FROM fines;

-- Q161. Book availability dashboard
SELECT b.book_id,b.title,COUNT(bc.copy_id) AS total_copies,SUM(bc.copy_status='AVAILABLE') AS available_copies,SUM(bc.copy_status='ISSUED') AS issued_copies FROM books b LEFT JOIN book_copies bc ON bc.book_id=b.book_id GROUP BY b.book_id,b.title ORDER BY b.title;

-- Q162. Category-wise availability dashboard
SELECT c.category_name,COUNT(bc.copy_id) AS total_copies,SUM(bc.copy_status='AVAILABLE') AS available_copies FROM categories c LEFT JOIN books b ON b.category_id=c.category_id LEFT JOIN book_copies bc ON bc.book_id=b.book_id GROUP BY c.category_id,c.category_name;

-- Q163. Member activity dashboard
SELECT m.member_id,m.full_name,m.member_status,COUNT(DISTINCT l.loan_id) AS loans,COUNT(DISTINCT r.reservation_id) AS reservations,COUNT(DISTINCT f.fine_id) AS fines FROM members m LEFT JOIN loans l ON l.member_id=m.member_id LEFT JOIN reservations r ON r.member_id=m.member_id LEFT JOIN fines f ON f.loan_id=l.loan_id GROUP BY m.member_id,m.full_name,m.member_status;

-- Q164. Most popular category by loans
SELECT c.category_name,COUNT(l.loan_id) AS borrow_count FROM categories c JOIN books b ON b.category_id=c.category_id JOIN book_copies bc ON bc.book_id=b.book_id JOIN loans l ON l.copy_id=bc.copy_id GROUP BY c.category_id,c.category_name ORDER BY borrow_count DESC LIMIT 1;

-- Q165. Top 3 most borrowed titles
SELECT b.title,COUNT(l.loan_id) AS borrow_count FROM books b JOIN book_copies bc ON bc.book_id=b.book_id JOIN loans l ON l.copy_id=bc.copy_id GROUP BY b.book_id,b.title ORDER BY borrow_count DESC LIMIT 3;

-- Q166. Top 3 active borrowers
SELECT m.full_name,COUNT(l.loan_id) AS loan_count FROM members m JOIN loans l ON l.member_id=m.member_id GROUP BY m.member_id,m.full_name ORDER BY loan_count DESC LIMIT 3;

-- Q167. Books currently issued with member details
SELECT b.title,bc.accession_no,m.full_name,l.issue_date,l.due_date FROM loans l JOIN members m ON m.member_id=l.member_id JOIN book_copies bc ON bc.copy_id=l.copy_id JOIN books b ON b.book_id=bc.book_id WHERE l.return_date IS NULL;

-- Q168. Members eligible to borrow
SELECT member_id,full_name FROM members WHERE member_status='ACTIVE';

-- Q169. Active members with no outstanding loans
SELECT m.member_id,m.full_name FROM members m WHERE m.member_status='ACTIVE' AND NOT EXISTS (SELECT 1 FROM loans l WHERE l.member_id=m.member_id AND l.return_date IS NULL);

-- Q170. Active members with no unpaid fines
SELECT m.member_id,m.full_name FROM members m WHERE m.member_status='ACTIVE' AND NOT EXISTS (SELECT 1 FROM loans l JOIN fines f ON f.loan_id=l.loan_id WHERE l.member_id=m.member_id AND f.payment_status='UNPAID');

-- Q171. Books with copies and waiting reservations
SELECT b.title,COUNT(DISTINCT bc.copy_id) AS copies,COUNT(DISTINCT r.reservation_id) AS waiting_reservations FROM books b LEFT JOIN book_copies bc ON bc.book_id=b.book_id LEFT JOIN reservations r ON r.book_id=b.book_id AND r.reservation_status='WAITING' GROUP BY b.book_id,b.title;

-- Q172. Loan and fine combined report
SELECT l.loan_id,m.full_name,b.title,l.due_date,l.return_date,COALESCE(f.amount,0) AS fine_amount,COALESCE(f.payment_status,'NO FINE') AS fine_status FROM loans l JOIN members m ON m.member_id=l.member_id JOIN book_copies bc ON bc.copy_id=l.copy_id JOIN books b ON b.book_id=bc.book_id LEFT JOIN fines f ON f.loan_id=l.loan_id;

-- Q173. Publisher-wise inventory value count
SELECT p.publisher_name,COUNT(bc.copy_id) AS physical_copy_count FROM publishers p LEFT JOIN books b ON b.publisher_id=p.publisher_id LEFT JOIN book_copies bc ON bc.book_id=b.book_id GROUP BY p.publisher_id,p.publisher_name;

-- Q174. Books authored by multiple authors
SELECT b.title,COUNT(ba.author_id) AS author_count FROM books b JOIN book_authors ba ON ba.book_id=b.book_id GROUP BY b.book_id,b.title HAVING COUNT(ba.author_id)>1;

-- Q175. Books with no author mapping
SELECT b.book_id,b.title FROM books b LEFT JOIN book_authors ba ON ba.book_id=b.book_id WHERE ba.author_id IS NULL;

-- Q176. Member risk list: suspended with active loans
SELECT m.member_id,m.full_name,l.loan_id,l.due_date FROM members m JOIN loans l ON l.member_id=m.member_id WHERE m.member_status='SUSPENDED' AND l.return_date IS NULL;

-- Q177. Copy and loan status consistency check
SELECT bc.copy_id,bc.copy_status,l.loan_status,l.return_date FROM book_copies bc LEFT JOIN loans l ON l.copy_id=bc.copy_id AND l.return_date IS NULL WHERE (bc.copy_status='ISSUED' AND l.loan_id IS NULL) OR (bc.copy_status='AVAILABLE' AND l.loan_id IS NOT NULL);

-- Q178. Monthly circulation summary
SELECT DATE_FORMAT(issue_date,'%Y-%m') AS month,COUNT(*) AS issued, SUM(return_date IS NOT NULL) AS returned FROM loans GROUP BY month ORDER BY month;

-- Q179. Year-to-date fine collection
SELECT COALESCE(SUM(amount),0) AS collected_this_year FROM fines WHERE payment_status='PAID' AND YEAR(paid_on)=YEAR(CURRENT_DATE);

-- Q180. Books with high demand and low availability
SELECT b.title,COUNT(DISTINCT r.reservation_id) AS waiting_count,SUM(bc.copy_status='AVAILABLE') AS available_count FROM books b LEFT JOIN reservations r ON r.book_id=b.book_id AND r.reservation_status='WAITING' LEFT JOIN book_copies bc ON bc.book_id=b.book_id GROUP BY b.book_id,b.title HAVING waiting_count>available_count;

-- Q181. Rank books by borrowing frequency
WITH book_stats AS (SELECT b.book_id,b.title,COUNT(l.loan_id) AS borrow_count FROM books b LEFT JOIN book_copies bc ON bc.book_id=b.book_id LEFT JOIN loans l ON l.copy_id=bc.copy_id GROUP BY b.book_id,b.title) SELECT book_id,title,borrow_count,DENSE_RANK() OVER(ORDER BY borrow_count DESC) AS popularity_rank FROM book_stats ORDER BY popularity_rank,title;

-- Q182. Rank members by number of loans
WITH member_stats AS (SELECT m.member_id,m.full_name,COUNT(l.loan_id) AS loan_count FROM members m LEFT JOIN loans l ON l.member_id=m.member_id GROUP BY m.member_id,m.full_name) SELECT member_id,full_name,loan_count,RANK() OVER(ORDER BY loan_count DESC) AS member_rank FROM member_stats ORDER BY member_rank;

-- Q183. Running total of fines by assessment date
SELECT fine_id,assessed_on,amount,SUM(amount) OVER(ORDER BY assessed_on,fine_id) AS running_fine_total FROM fines ORDER BY assessed_on,fine_id;

-- Q184. Loan sequence for each member
SELECT loan_id,member_id,issue_date,ROW_NUMBER() OVER(PARTITION BY member_id ORDER BY issue_date) AS member_loan_sequence FROM loans ORDER BY member_id,member_loan_sequence;

-- Q185. Latest loan per member
WITH ranked_loans AS (SELECT l.*,ROW_NUMBER() OVER(PARTITION BY member_id ORDER BY issue_date DESC,loan_id DESC) AS rn FROM loans l) SELECT loan_id,member_id,copy_id,issue_date,due_date,loan_status FROM ranked_loans WHERE rn=1;

-- Q186. Books whose borrowing is above average
WITH counts AS (SELECT b.book_id,b.title,COUNT(l.loan_id) AS borrow_count FROM books b LEFT JOIN book_copies bc ON bc.book_id=b.book_id LEFT JOIN loans l ON l.copy_id=bc.copy_id GROUP BY b.book_id,b.title) SELECT * FROM counts WHERE borrow_count>(SELECT AVG(borrow_count) FROM counts);

-- Q187. Members with above-average fine amount
WITH member_fines AS (SELECT m.member_id,m.full_name,COALESCE(SUM(f.amount),0) AS total_fines FROM members m LEFT JOIN loans l ON l.member_id=m.member_id LEFT JOIN fines f ON f.loan_id=l.loan_id GROUP BY m.member_id,m.full_name) SELECT * FROM member_fines WHERE total_fines>(SELECT AVG(total_fines) FROM member_fines);

-- Q188. Combine member names and publisher names
SELECT full_name AS display_name,'MEMBER' AS record_type FROM members UNION ALL SELECT publisher_name,'PUBLISHER' FROM publishers ORDER BY record_type,display_name;

-- Q189. Books and categories with readable label
SELECT b.title,COALESCE(c.category_name,'Uncategorized') AS category FROM books b LEFT JOIN categories c ON c.category_id=b.category_id ORDER BY category,b.title;

-- Q190. Find members who borrowed every title in category 5
SELECT m.member_id,m.full_name FROM members m WHERE NOT EXISTS (SELECT b.book_id FROM books b WHERE b.category_id=5 AND NOT EXISTS (SELECT 1 FROM book_copies bc JOIN loans l ON l.copy_id=bc.copy_id WHERE bc.book_id=b.book_id AND l.member_id=m.member_id));

-- Q191. Daily issue count for the last 30 days
SELECT issue_date,COUNT(*) AS issued_count FROM loans WHERE issue_date>=DATE_SUB(CURRENT_DATE,INTERVAL 30 DAY) GROUP BY issue_date ORDER BY issue_date;

-- Q192. Fine collection rate
SELECT ROUND(100.0*SUM(payment_status='PAID')/NULLIF(COUNT(*),0),2) AS paid_fine_record_percentage FROM fines;

-- Q193. Member status label using CASE
SELECT member_id,full_name,CASE member_status WHEN 'ACTIVE' THEN 'Can borrow' WHEN 'SUSPENDED' THEN 'Borrowing blocked' ELSE 'Membership closed' END AS borrowing_eligibility FROM members;

-- Q194. Copy status label using CASE
SELECT copy_id,accession_no,CASE copy_status WHEN 'AVAILABLE' THEN 'Ready to issue' WHEN 'ISSUED' THEN 'With member' WHEN 'LOST' THEN 'Missing' WHEN 'DAMAGED' THEN 'Needs repair' ELSE 'Removed from circulation' END AS status_description FROM book_copies;

-- Q195. Fine payment label using CASE
SELECT fine_id,amount,CASE WHEN payment_status='PAID' THEN 'Settled' WHEN payment_status='UNPAID' THEN 'Payment pending' ELSE 'Waived' END AS payment_label FROM fines;

-- Q196. Books published in leap years
SELECT book_id,title,publication_year FROM books WHERE MOD(publication_year,400)=0 OR (MOD(publication_year,4)=0 AND MOD(publication_year,100)<>0);

-- Q197. Members with same joining date
SELECT joined_on,COUNT(*) AS members_joined FROM members GROUP BY joined_on HAVING COUNT(*)>1;

-- Q198. Check duplicate book titles
SELECT LOWER(TRIM(title)) AS normalized_title,COUNT(*) AS duplicate_count FROM books GROUP BY LOWER(TRIM(title)) HAVING COUNT(*)>1;

-- Q199. Check duplicate member phone numbers
SELECT phone,COUNT(*) AS duplicate_count FROM members WHERE phone IS NOT NULL GROUP BY phone HAVING COUNT(*)>1;

-- Q200. Overall library statistics
SELECT (SELECT COUNT(*) FROM books) AS total_titles,(SELECT COUNT(*) FROM book_copies) AS total_copies,(SELECT COUNT(*) FROM members) AS total_members,(SELECT COUNT(*) FROM loans) AS total_loans,(SELECT COUNT(*) FROM reservations) AS total_reservations,(SELECT COUNT(*) FROM fines) AS total_fine_records;
