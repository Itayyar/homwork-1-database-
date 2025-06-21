-- Homework #1 - Database Programming
-- Student: [ibrahim mashhour ismail]
-- University ID: [202311475]

-- ======================
-- Q1.A - DDL Definition
-- ======================

CREATE TABLE Publisher (
    publisher_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE Member (
    member_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);

CREATE TABLE Book (
    book_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    publisher_id INT,
    FOREIGN KEY (publisher_id) REFERENCES Publisher(publisher_id)
);

CREATE TABLE Borrowed (
    member_id INT,
    book_id INT,
    borrow_date DATE,
    PRIMARY KEY (member_id, book_id),
    FOREIGN KEY (member_id) REFERENCES Member(member_id),
    FOREIGN KEY (book_id) REFERENCES Book(book_id)
);

-- ======================
-- Q1.B - SQL Queries
-- ======================

-- (a) Members who borrowed at least one book from 'Penguin'
SELECT DISTINCT m.member_id, m.name
FROM Member m
JOIN Borrowed b ON m.member_id = b.member_id
JOIN Book bk ON b.book_id = bk.book_id
JOIN Publisher p ON bk.publisher_id = p.publisher_id
WHERE p.name = 'Penguin';

-- (b) Members who borrowed every book from 'Penguin'
SELECT m.member_id, m.name
FROM Member m
WHERE NOT EXISTS (
    SELECT bk.book_id
    FROM Book bk
    JOIN Publisher p ON bk.publisher_id = p.publisher_id
    WHERE p.name = 'Penguin'
    EXCEPT
    SELECT b.book_id
    FROM Borrowed b
    WHERE b.member_id = m.member_id
);

-- (c) Members who borrowed more than 5 books per publisher
SELECT p.name AS publisher_name, m.member_id, m.name
FROM Member m
JOIN Borrowed b ON m.member_id = b.member_id
JOIN Book bk ON b.book_id = bk.book_id
JOIN Publisher p ON bk.publisher_id = p.publisher_id
GROUP BY p.name, m.member_id, m.name
HAVING COUNT(*) > 5;

-- (d) Average number of books borrowed per member (including members who borrowed none)
SELECT 
    CAST(SUM(b_count) AS FLOAT) / COUNT(*) AS avg_books_borrowed
FROM (
    SELECT m.member_id, COUNT(b.book_id) AS b_count
    FROM Member m
    LEFT JOIN Borrowed b ON m.member_id = b.member_id
    GROUP BY m.member_id
) AS stats;

-- ======================
-- Q2 - SQL Window Functions
-- ======================

-- (A) Cumulative sum of qty per product
SELECT 
    product_id,
    sale_date,
    qty,
    SUM(qty) OVER (PARTITION BY product_id ORDER BY sale_date) AS cumulative_qty
FROM demand;

-- (B) Two worst-performing days per product by qty sold
SELECT product_id, sale_date, qty
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY qty ASC, sale_date) AS rn
    FROM demand
) AS ranked
WHERE rn <= 2;
