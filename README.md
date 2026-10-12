# Books Dataset SQL Project

A SQLite project that turns raw CSV files into a clean, normalized
database and answers questions about book popularity, ratings and
reader preferences using SQL.

## Dataset

**Books Dataset** (Kaggle), compiled by Cai-Nicolas Ziegler in 2004

- Source: <https://www.kaggle.com/datasets/saurabhbagchi/books-dataset>
- Files: `books.csv`, `users.csv`, `ratings.csv`
- Ratings: 1-10 are explicit, 0 is implicit

## How to run

1. Download the CSV files from Kaggle and place them in a `data/` folder.
2. Run the Python script that repairs broken quotes in the CSV files:
   `python fix_csv.py`
3. Start SQLite and run the scripts in order:

```
   sqlite3 books.db
   .read sql/01_staging.sql
   .read sql/02_schema.sql
   .read sql/03_clean_insert.sql
   .read sql/04_queries.sql
```

## Schema

- `books` (isbn, title, author, year, publisher)
- `users` (user_id, location, age)
- `ratings` (user_id, isbn, rating)

## Data cleaning

Raw data is loaded into temporary `stg_*` tables, then cleaned while being copied into the final tables.

- Broken quotes in the CSV files are repaired with `fix_csv.py`.
- Impossible years and ages (outside 1000-2026 and 5-100) are set to `NULL`.
- About 118,000 ratings that point to books missing from `Books.csv` are excluded.
- Ratings of 0 (implicit) are counted as interactions but left out of averages.

## Queries

All queries are in `sql/04_queries.sql`.

1. Top 10 most-rated books (explicit and implicit ratings counted).
2. Top 10 highest-rated books (explicit ratings only, at least 50 ratings).
3. Top 3 highest-rated books for each publication year.
4. Top 10 most-rated books for each age group.
5. Book recommendations for the 5 most active users, based on their favorite authors.

## Known limitations

- The same book can appear under several ISBNs (editions) and slightly different titles or author spellings.
- About 40% of users have no age, so they are left out of query 4.
- Recommendations in query 5 are ordered alphabetically, not by relevance.