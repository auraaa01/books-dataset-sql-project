DELETE FROM ratings;
DELETE FROM users;
DELETE FROM books;

INSERT INTO books (isbn, title, author, year, publisher)
SELECT isbn,
    TRIM(REPLACE(title, '&amp;', '&'), '"'),
    author,
    CASE WHEN cast(year as INTEGER) between 1000 and 2026
    THEN cast(year as INTEGER) END,
    REPLACE(publisher, '&amp;', '&')
FROM stg_books;

INSERT INTO users (user_id, location, age)
SELECT cast(user_id as INTEGER),
       location,
       CASE WHEN cast(age as INTEGER) between 5 and 100
       THEN cast(age as INTEGER) END
FROM stg_users;

INSERT INTO ratings (user_id, isbn, rating)
SELECT cast(user_id as INTEGER),
       isbn,
       cast(rating as INTEGER)
FROM stg_ratings
WHERE isbn in (SELECT isbn from books)
AND cast(user_id as INTEGER) in (SELECT user_id from users);