show databases;
create database Library;
select database();
use library;
create table books(
	book_id int auto_increment primary key,
    title varchar(30) not null,
    author varchar(20) not null,
    total_copies int not null check(total_copies >= 0),
    available_copies int not null check(available_copies >= 0)
);
create table users(
	user_id int auto_increment Primary key,
    user_name varchar(20) not null,
    email varchar(20) not null,
    phone varchar(20)
);

create table transactions(
	trans_id int auto_increment primary key,
    book_id int not	null,
    user_id int not null,
    issue_date date not null default (curdate()),
    due_date date not null,
    return_date date default null,
    status varchar(20) default 'Issued' check(status in ('Issued', 'Returned', 'Overdue')),
    foreign key (book_id) references books(book_id),
    foreign key (user_id) references users(user_id)
);

--  Insert values to books table:

insert into books values
(1,"Atomic Habits","James Clear",5,5),
(2,"The Power of Habit","Charles Duhigg",4,4),
(3,"The Psychology of Money","Morgan Housel",4,4),
(4,"Rich Dad Poor Dad","Robert T. Kiyosaki",5,5);

show tables;
select * from books;

insert into users values
(1,"Selvakumar","selva@email.com","9876543210"),
(2,"Suren","suren@email.com","1234567890"),
(3,"Hari","hari@email.com","8529637410");

select * from users;

start transaction;

insert into transactions(book_id,user_id,issue_date,due_date,status) values
(1,1,curdate(),curdate() + interval 14 day,"Issued");

select * from transactions;

-- Lending a Book

update books
set available_copies = available_copies - 1
where book_id = 1 and available_copies>0;

commit;

-- Return a Book

start transaction;

update transactions
set return_date = curdate(), status = "Returned"
where trans_id = 1 and status = 'Issued';

select * from books;
select * from transactions;

update books
set available_copies = available_copies + 1
where book_id = (select book_id from transactions where trans_id =1);

commit;

SELECT 
    t.trans_id,
    user_name,
    u.email AS user_email,
    b.title AS book_title,
    t.issue_date,
    t.due_date,
    (CURRENT_DATE - t.due_date) AS days_overdue
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
JOIN Books b ON t.book_id = b.book_id
WHERE t.status = 'Issued' AND t.due_date < CURRENT_DATE;