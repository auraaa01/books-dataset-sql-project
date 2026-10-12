DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS users;

CREATE TABLE books(
    isbn TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT,
    year INTEGER,
    publisher TEXT
);

CREATE TABLE users(
    user_id INTEGER PRIMARY KEY,
    location TEXT,
    age INTEGER CHECK (age >= 0)
);

CREATE TABLE ratings(
    user_id INTEGER,
    isbn TEXT,
    rating INTEGER CHECK (rating between 0 and 10),
    PRIMARY KEY (user_id, isbn),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (isbn) REFERENCES books(isbn)
);

