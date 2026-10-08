CREATE DATABASE IF NOT EXISTS LibraryManagement;
USE LibraryManagement;

-- 1. Create Books Table
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    published_year INT,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    membership_date DATE NOT NULL,
    status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active'
);

-- 3. Create Transactions Table
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status ENUM('Issued', 'Returned', 'Overdue') DEFAULT 'Issued',
    fine_amount DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Insert Sample Books
INSERT INTO Books (title, author, isbn, published_year, total_copies, available_copies) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', 1925, 5, 4),
('To Kill a Mockingbird', 'Harper Lee', '9780061120084', 1960, 3, 3),
('1984', 'George Orwell', '9780451524935', 1949, 4, 3),
('The Hobbit', 'J.R.R. Tolkien', '9780547928227', 1937, 2, 2);

select * from books;

-- Insert Sample Users
INSERT INTO Users (first_name, last_name, email, phone, membership_date, status) VALUES
('John', 'Doe', 'john.doe@email.com', '555-0192', '2025-01-15', 'Active'),
('Jane', 'Smith', 'jane.smith@email.com', '555-0193', '2025-03-22', 'Active'),
('Robert', 'Johnson', 'robert.j@email.com', '555-0194', '2024-11-05', 'Suspended');

select * from users;

-- Insert Sample Transactions
INSERT INTO Transactions (book_id, user_id, issue_date, due_date, return_date, status, fine_amount) VALUES
(1, 1, '2026-10-01', '2026-10-15', NULL, 'Issued', 0.00),
(3, 2, '2026-09-15', '2026-09-29', '2026-09-28', 'Returned', 0.00);

select * from transactions;

-- Issuing a Book

-- Step A: Log the transaction
INSERT INTO Transactions (book_id, user_id, issue_date, due_date, status) 
VALUES (2, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Issued');

-- Step B: Update book availability
UPDATE Books 
SET available_copies = available_copies - 1 
WHERE book_id = 2 AND available_copies > 0;

-- Returning a book

-- Step A: Update the transaction entry
UPDATE Transactions 
SET return_date = CURDATE(), 
    status = 'Returned',
    fine_amount = IF(CURDATE() > due_date, DATEDIFF(CURDATE(), due_date) * 1.50, 0.00) -- $1.50 fine per day over due date
WHERE transaction_id = 1;

-- Step B: Re-add the copy to inventory
UPDATE Books 
SET available_copies = available_copies + 1 
WHERE book_id = (SELECT book_id FROM Transactions WHERE transaction_id = 1);

-- Tracking Status
 
-- View all books currently checked out and who has them
SELECT 
    t.transaction_id,
    b.title AS 'Book Title',
    CONCAT(u.first_name, ' ', u.last_name) AS 'Borrower',
    t.issue_date AS 'Issued On',
    t.due_date AS 'Due Date'
FROM Transactions t
JOIN Books b ON t.book_id = b.book_id
JOIN Users u ON t.user_id = u.user_id
WHERE t.status = 'Issued';

-- Find overdue books
SELECT 
    t.transaction_id,
    b.title,
    CONCAT(u.first_name, ' ', u.last_name) AS 'Borrower',
    t.due_date,
    DATEDIFF(CURDATE(), t.due_date) AS 'Days Overdue'
FROM Transactions t
JOIN Books b ON t.book_id = b.book_id
JOIN Users u ON t.user_id = u.user_id
WHERE t.status = 'Issued' AND CURDATE() > t.due_date;