DROP TABLE IF EXISTS stg_books;
DROP TABLE IF EXISTS stg_ratings;
DROP TABLE IF EXISTS stg_users;

CREATE TABLE stg_books(
    isbn TEXT,
    title TEXT,
    author TEXT,
    year TEXT,
    publisher TEXT,
    image_s TEXT,
    image_m TEXT,
    image_l TEXT
);

CREATE TABLE stg_ratings(
    user_id TEXT,
    isbn TEXT,
    rating TEXT
);

CREATE TABLE stg_users(
    user_id TEXT,
    location TEXT,
    age TEXT
);

.mode csv
.separator ";"
.import --skip 1 data/books_clean.csv stg_books
.import --skip 1 data/ratings_clean.csv stg_ratings
.import --skip 1 data/users_clean.csv stg_users