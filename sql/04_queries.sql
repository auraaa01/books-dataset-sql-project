.headers on
.mode box

--Q1: Top 10 most-rated books
--A book appearing in ratings means a user interacted with it, so the number
--of entries is taken as an indicator of how widely it was read.
--Explicit (1-10) and implicit (0) ratings are both included.

SELECT 'Top 10 most-rated books' AS info;

SELECT title, author, nr_of_ratings FROM (
    SELECT  title, author, nr_of_ratings,
    ROW_NUMBER() OVER (ORDER BY nr_of_ratings DESC) AS row_nr FROM (
        SELECT isbn, COUNT(rating) AS nr_of_ratings FROM ratings GROUP BY isbn) r
    JOIN books b ON r.isbn = b.isbn) FinalTable
WHERE row_nr <= 10;

--Q2: Top 10 highest-rated books
--Only explicit ratings (1-10) are used, so implicit ratings (0) are excluded
--from the average. Books with fewer than 50 explicit ratings are left out,
--to avoid a book with a handful of high ratings ranking first.
--Min and max are shown next to the average to see how much opinions vary.

SELECT 'Top 10 highest-rated books' AS info;

SELECT title, author, min(rating) as min_rating,
max(rating) as max_rating,
round(avg(rating), 2) as avg_rating FROM
ratings JOIN books ON ratings.isbn = books.isbn
WHERE rating > 0
GROUP BY ratings.isbn
HAVING COUNT(*) >= 50
ORDER BY avg_rating DESC, title
LIMIT 10;

--Q3: Top 3 highest-rated books for each publication year
--Same rules as Q2 (explicit ratings only, at least 50 ratings per book),
--but ranked separately within each year. Books with unknown year are excluded.
--DENSE_RANK keeps ties, so a year can have more than 3 rows (e.g. 1996).

SELECT 'Top 3 highest-rated books per year' AS info;

SELECT year, rank_number, title, author, avg_rating FROM (
	SELECT year, title, author, avg_rating,
	DENSE_RANK() OVER (PARTITION BY year ORDER BY avg_rating DESC) AS rank_number FROM (
	    SELECT title, author, year, ROUND(AVG(rating), 2) AS avg_rating
	    FROM books JOIN ratings ON books.isbn = ratings.isbn
	    WHERE rating > 0 AND year IS NOT NULL
	    GROUP BY books.isbn
	    HAVING COUNT(*) >= 50
    ) Avg_Table
) Rank_Table WHERE rank_number <= 3
ORDER BY year, rank_number;

--Q4: Top 10 most-rated books for each age group
--Same popularity measure as Q1 (explicit and implicit ratings both counted).
--Users with unknown age are excluded. Ages were limited to 5-100 during
--cleaning, so every remaining user falls into exactly one group.
--DENSE_RANK keeps ties, so a group can have more than 10 rows.

SELECT 'Top 10 most-rated books per age group' AS info;

SELECT age_group, title, author, year, nr_ratings, rank_number FROM (
    SELECT age_group, isbn, nr_ratings,
    DENSE_RANK() OVER (PARTITION BY age_group ORDER BY nr_ratings DESC) AS rank_number FROM(
        SELECT
        CASE
            WHEN age BETWEEN 5 AND 17 THEN 'Under 18'
            WHEN age BETWEEN 18 AND 25 THEN '18-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 49 THEN '36-49'
            WHEN age BETWEEN 50 AND 100 THEN '50+'
        END AS age_group,
        isbn,
        COUNT(*) AS nr_ratings
        FROM ratings JOIN users ON users.user_id = ratings.user_id
        WHERE age IS NOT NULL
        GROUP BY age_group, isbn
    ) CountRatings
) RankTable
JOIN books ON books.isbn = RankTable.isbn
WHERE rank_number <= 10
ORDER BY
CASE age_group
    WHEN 'Under 18' THEN 1
	WHEN '18-25' THEN 2
	WHEN '26-35' THEN 3
	WHEN '36-49' THEN 4
	WHEN '50+' THEN 5
END,
rank_number;

--Q5: Book recommendations for the 5 most active users
--Activity is measured by total number of ratings (explicit and implicit).
--Step 1: for each of these users, find their top 3 authors, ranked by the
--average of their explicit ratings (rating > 0); ties are broken by the
--number of rated books, then alphabetically.
--Step 2: for each top author, recommend up to 3 books (ordered alphabetically)
--that the user has not rated yet (any rating, including 0).
--Authors and titles are normalized with UPPER(TRIM(...)) to merge spelling
--variants; some duplicate editions with different subtitles remain
--(e.g. "Where or When" vs "Where or When: A Novel").

SELECT 'Recommendations for the 5 most active users' AS info;

SELECT user_id, top_author, author_n, book_nr, title_n
FROM (
SELECT user_id, top_author, author_n,
ROW_NUMBER() OVER (PARTITION BY user_id, author_n ORDER BY title_n) as book_nr, title_n
FROM (
SELECT fa.user_id, fa.author_n, fa.top_author, upper(trim(b.title)) AS title_n
FROM (
	SELECT user_id, author_n, top_author
	FROM (
		SELECT user_id, author_n,
		ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY avg_rating DESC, nr_books DESC, author_n) AS top_author,
		avg_rating, nr_books
		FROM (
			SELECT user_id, upper(trim(author)) AS author_n,
			avg(rating) AS avg_rating,
			COUNT(*) AS nr_books
			FROM ratings
			JOIN books ON ratings.isbn = books.isbn
			WHERE rating > 0 AND user_id IN (
			    SELECT user_id FROM (
			        SELECT user_id, ROW_NUMBER() OVER (ORDER BY nr_ratings desc) AS row_nr FROM (
			            SELECT user_id, COUNT(rating) AS nr_ratings FROM ratings GROUP BY user_id))
			    WHERE row_nr <= 5)
			GROUP BY user_id, upper(trim(author))
		)
	) WHERE top_author <= 3
) fa
JOIN books b ON fa.author_n = upper(trim(b.author))
WHERE NOT EXISTS (
	SELECT 1 FROM ratings r2
	WHERE r2.isbn = b.isbn AND r2.user_id = fa.user_id)
GROUP BY fa.user_id, fa.author_n, fa.top_author, upper(trim(b.title))
)
) WHERE book_nr <= 3
ORDER BY user_id, top_author, book_nr;