
Kaggle link to the dataset:
https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows

DROP TABLE IF EXISTS imdb_top_movies;

CREATE TABLE IF NOT EXISTS imdb_top_movies (
    Poster_Link     VARCHAR(4000),
    Series_Title    VARCHAR(1000),
    Released_Year   VARCHAR(10),
    Certificate     VARCHAR(10),
    Runtime         VARCHAR(20),
    Genre           VARCHAR(50),
    IMDB_Rating     DECIMAL,
    Overview        VARCHAR(4000),
    Meta_score      INT,
    Director        VARCHAR(200),
    Star1           VARCHAR(200),
    Star2           VARCHAR(200),
    Star3           VARCHAR(200),
    Star4           VARCHAR(200),
    No_of_Votes     BIGINT,
    Gross           MONEY
);



-- Solve the below problems using IMDB dataset:

1) Fetch all data from imdb table 

SELECT *
FROM imdb_top_movies;


2) Fetch only the name and release year for all movies.

SELECT series_title, released_year
FROM imdb_top_movies;


3) Fetch the name, release year and imdb rating of movies which are UA certified.

SELECT series_title, released_year, imdb_rating
FROM imdb_top_movies
WHERE certificate = 'UA';


4) Fetch the name and genre of movies which are UA certified and have a Imdb rating of over 8.

SELECT series_title, genre
FROM imdb_top_movies
WHERE certificate = 'UA' AND imdb_rating > 8;


5) Find out how many movies are of Drama genre.

SELECT COUNT(*)
FROM imdb_top_movies
WHERE genre LIKE '%Drama%';


6) How many movies are directed by "Quentin Tarantino", "Steven Spielberg", "Christopher Nolan" and "Rajkumar Hirani".

SELECT COUNT(*)
FROM imdb_top_movies
WHERE director IN ('Quentin Tarantino', 'Steven Spielberg', 'Christopher Nolan', 'Rajkumar Hirani');


7) What is the highest imdb rating given so far?

SELECT MAX(imdb_rating) as max_rating
FROM imdb_top_movies;


8) What is the highest and lowest imdb rating given so far?

SELECT MAX(imdb_rating) as max_rating, MIN(imdb_rating) as min_rating
FROM imdb_top_movies;


8a) Solve the above problem but display the results in different rows.

SELECT MAX(imdb_rating) as max_rating
FROM imdb_top_movies

UNION ALL

SELECT MIN(imdb_rating) as min_rating
FROM imdb_top_movies;


8b) Solve the above problem but display the results in different rows. And have a column which indicates the value as lowest and highest.

SELECT MAX(imdb_rating) as movie_rating, 'Highest rating' as high_low
FROM imdb_top_movies
UNION 
SELECT MIN(imdb_rating) , 'Lowest rating' as high_low
FROM imdb_top_movies;


9) Find out the average imdb rating of movies which are neither directed by "Quentin Tarantino", "Steven Spielberg", "Christopher Nolan" and are not acted by any of these stars "Christian Bale", "Liam Neeson", "Heath Ledger", "Leonardo DiCaprio", "Anne Hathaway".

SELECT AVG(imdb_rating) as avg_rating
FROM imdb_top_movies
WHERE director NOT IN ('Quentin Tarantino', 'Steven Spielberg', 'Christopher Nolan')
AND (star1 NOT IN ('Christian Bale', 'Liam Neeson', 'Heath Ledger', 'Leonardo DiCaprio', 'Anne Hathaway') 
	AND star2 NOT IN ('Christian Bale', 'Liam Neeson', 'Heath Ledger', 'Leonardo DiCaprio', 'Anne Hathaway') 
	AND star3 NOT IN ('Christian Bale', 'Liam Neeson', 'Heath Ledger', 'Leonardo DiCaprio', 'Anne Hathaway') 
	AND star4 NOT IN ('Christian Bale', 'Liam Neeson', 'Heath Ledger', 'Leonardo DiCaprio', 'Anne Hathaway') 
	);


10) Mention the movies involving both "Steven Spielberg" and "Tom Cruise".

SELECT series_title
FROM imdb_top_movies
WHERE director = 'Steven Spielberg'
AND (star1 = 'Tom Cruise'
	OR star2 = 'Tom Cruise'
	OR star3 = 'Tom Cruise'
	OR star4 = 'Tom Cruise');


11) Display the movie name and watch time (in both mins and hours) which have over 9 imdb rating.

SELECT
	series_title,
	runtime as runtime_mins,
	CAST(REPLACE (runtime, ' min', '') as decimal)/60  as runtime_hrs,
	ROUND(REPLACE (runtime, ' min', '')::decimal /60,2)  as runtime_hrs
FROM imdb_top_movies
WHERE imdb_rating > 9;


12) What is the average imdb rating of movies which are released in the last 10 years and have less than 2 hrs of runtime.

SELECT ROUND(AVG(imdb_rating),2) as avg_rating
FROM imdb_top_movies
WHERE released_year <> 'PG'
AND EXTRACT(YEAR FROM CURRENT_DATE ) - released_year::int <= 10
AND ROUND(REPLACE(RUNTIME, ' min', '')::decimal /60,2) < 2;


13) Identify the Batman movie which is not directed by "Christopher Nolan".

SELECT *
FROM imdb_top_movies
WHERE certificate IN ('A', 'UA')
  AND (director IN ('Steven Spielberg', 'Christopher Nolan')
        OR 
	  (director NOT IN ('Steven Spielberg', 'Christopher Nolan')
        AND imdb_rating > 8)
      );


14) Display all the A and UA certified movies which are either directed by "Steven Spielberg", "Christopher Nolan" or which are directed by other directors but have a rating of over 8.

SELECT *
FROM imdb_top_movies
WHERE certificate IN ('A', 'UA')
  AND (director IN ('Steven Spielberg', 'Christopher Nolan')
        OR (director NOT IN ('Steven Spielberg', 'Christopher Nolan')
        AND imdb_rating > 8)
      );


15) What are the different certificates given to movies?

SELECT DISTINCT certificate
FROM imdb_top_movies
ORDER BY 1;

SELECT DISTINCT certificate
FROM imdb_top_movies
ORDER BY certificate;


16) Display all the movies acted by Tom Cruise in the order of their release. Consider only movies which have a meta score.

SELECT *
FROM imdb_top_movies
WHERE meta_score IS NOT NULL
  AND (
        star1 = 'Tom Cruise'
        OR star2 = 'Tom Cruise'
        OR star3 = 'Tom Cruise'
        OR star4 = 'Tom Cruise'
      )
ORDER BY released_year;


17) Segregate all the Drama and Comedy movies released in the last 10 years as per their runtime. Movies shorter than 1 hour should be termed as short film. Movies longer than 2 hrs should be termed as longer movies. All others can be termed as Good watch time.

SELECT *
FROM imdb_top_movies
WHERE released_year = 'PG';

SELECT 
    series_title AS movie_name,
    CASE 
        WHEN ROUND(REPLACE(runtime, ' min', '')::DECIMAL / 60, 2) < 1 THEN 'Short film'
        WHEN ROUND(REPLACE(runtime, ' min', '')::DECIMAL / 60, 2) > 2 THEN 'Longer Movies'
        ELSE 'Good watch time'
    END AS category
FROM imdb_top_movies
WHERE released_year <> 'PG'
  AND EXTRACT(YEAR FROM CURRENT_DATE) - released_year::INT <= 10
  AND (
        UPPER(genre) LIKE '%DRAMA%' 
        OR LOWER(genre) LIKE '%comedy%'
      )
ORDER BY category;


18) Write a query to display the "Christian Bale" movies which released in odd year and even year. Sort the data as per Odd year at the top.

SELECT 
    series_title AS movie_name,
    released_year,
    CASE 
        WHEN released_year::INT % 2 = 0 THEN 'Even year'
        ELSE 'Odd year'
    END AS odd_or_even
FROM imdb_top_movies
WHERE released_year <> 'PG'
  AND (
        star1 = 'Christian Bale'
        OR star2 = 'Christian Bale'
        OR star3 = 'Christian Bale'
        OR star4 = 'Christian Bale'
      )
ORDER BY odd_or_even DESC;


19) Re-write problem #18 without using case statement.

SELECT 
    series_title AS movie_name, 
    'Short film' AS category,
    ROUND(REPLACE(runtime, ' min', '')::DECIMAL / 60, 2) AS runtime
FROM imdb_top_movies
WHERE released_year <> 'PG'
  AND EXTRACT(YEAR FROM CURRENT_DATE) - released_year::INT <= 10
  AND (
        UPPER(genre) LIKE '%DRAMA%' 
        OR LOWER(genre) LIKE '%comedy%'
      )
  AND ROUND(REPLACE(runtime, ' min', '')::DECIMAL / 60, 2) < 1

UNION ALL

SELECT 
    series_title AS movie_name, 
    'Longer Movies' AS category,
    ROUND(REPLACE(runtime, ' min', '')::DECIMAL / 60, 2) AS runtime
FROM imdb_top_movies
WHERE released_year <> 'PG'
  AND EXTRACT(YEAR FROM CURRENT_DATE) - released_year::INT <= 10
  AND (
        UPPER(genre) LIKE '%DRAMA%' 
        OR LOWER(genre) LIKE '%comedy%'
      )
  AND ROUND(REPLACE(runtime, ' min', '')::DECIMAL / 60, 2) > 2

UNION ALL

SELECT 
    series_title AS movie_name, 
    'Good watch time' AS category,
    ROUND(REPLACE(runtime, ' min', '')::DECIMAL / 60, 2) AS runtime
FROM imdb_top_movies
WHERE released_year <> 'PG'
  AND EXTRACT(YEAR FROM CURRENT_DATE) - released_year::INT <= 10
  AND (
        UPPER(genre) LIKE '%DRAMA%' 
        OR LOWER(genre) LIKE '%comedy%'
      )
  AND ROUND(REPLACE(runtime, ' min', '')::DECIMAL / 60, 2) BETWEEN 1 AND 2

ORDER BY category;


