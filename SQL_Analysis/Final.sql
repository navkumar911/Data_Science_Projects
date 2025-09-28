USE imdb;

-- Q1. Find the total number of rows in each table of the schema?
SELECT COUNT(*) FROM director_mapping;
SELECT COUNT(*) FROM genre;
SELECT COUNT(*) FROM movie;
SELECT COUNT(*) FROM names;
SELECT COUNT(*) FROM ratings;
SELECT COUNT(*) FROM role_mapping;


-- Q2. Which columns in the 'movie' table have null values?
SELECT
  SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS null_title,
  SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS null_year,
  SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS null_date_published,
  SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS null_duration,
  SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country,
  SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS null_income,
  SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS null_languages,
  SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS null_production_company
FROM movie;

/* In Solution 2 above, id in each case statement has been used as a counter to count the number of null values. Whenever a value
   is null for a column, the id increments by 1. */

/* There are 20 nulls in country; 3724 nulls in worlwide_gross_income; 194 nulls in languages; 528 nulls in production_company.
   Notice that we do not need to check for null values in the 'id' column as it is a primary key.

-- As you can see, four columns of the 'movie' table have null values. Let's look at the movies released in each year. 

-- Q3. Find the total number of movies released in each year. How does the trend look month-wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	   2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	  1			|	    134			|
|	  2			|	    231			|
|	  .			|		 .			|
+---------------+-------------------+ */

-- Type your code below:
SELECT year, COUNT(*) AS number_of_movies FROM movie GROUP BY year;
SELECT MONTH(date_published) AS month_num, COUNT(*) AS number_of_movies from movie GROUP BY MONTH(date_published) ORDER BY month_num;


/* The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the
'movies' table. 
We know that USA and India produce a huge number of movies each year. Lets find the number of movies produced by USA
or India in the last year. */
  
-- Q4. How many movies were produced in the USA or India in the year 2019?
-- Type your code below:
SELECT COUNT(*) AS num_of_movies FROM movie WHERE (country LIKE '%USA%' OR country LIKE '%India%') AND year = 2019 ;


/* USA and India produced more than a thousand movies (you know the exact number!) in the year 2019.
Exploring the table 'genre' will be fun, too.
Let’s find out the different genres in the dataset. */

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT DISTINCT genre FROM genre;

/* So, RSVP Movies plans to make a movie on one of these genres.
Now, don't you want to know in which genre were the highest number of movies produced?
Combining both the 'movie' and the 'genre' table can give us interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
SELECT genre, COUNT(*) AS Number_of_Movies FROM movie m INNER JOIN genre g on m.id=g.movie_id GROUP BY g.genre ORDER BY Number_of_Movies DESC;


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
SELECT COUNT(*) AS single_genre_movies
FROM (
  SELECT movie_id
  FROM genre
  GROUP BY movie_id
  HAVING COUNT(genre) = 1
) AS one_genre_movies;

/* There are more than three thousand movies which have only one genre associated with them.
This is a significant number.
Now, let's find out the ideal duration for RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	Thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT g.genre, ROUND(AVG(m.duration),0) AS avg_duration
FROM movie m 
JOIN genre g 
ON m.id=g.movie_id
GROUP BY genre
ORDER BY avg_duration DESC;


/* Note that using an outer join is important as we are dealing with a large number of null values. Using
   an inner join will slow down query processing. */


/* Now you know that movies of genre 'Drama' (produced highest in number in 2019) have an average duration of
106.77 mins.
Let's find where the movies of genre 'thriller' lie on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the rank function)


/* Output format:
+---------------+-------------------+---------------------+
|   genre		|	 movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|   drama		|	   2312			|			2		  |
+---------------+-------------------+---------------------+*/

-- Type your code below:
WITH list_genre AS (SELECT g.genre, COUNT(m.title) AS movie_count,
  RANK() OVER (ORDER BY COUNT(m.title) DESC) AS genre_rank
FROM movie m
JOIN genre g ON m.id = g.movie_id
GROUP BY g.genre
)

SELECT * FROM list_genre WHERE genre LIKE "%thriller%";


-- Thriller movies are in the top 3 among all genres in terms of the number of movies.


-- --------------------------------------------------------------------------------------------------------------
/* In the previous segment, you analysed the 'movie' and the 'genre' tables. 
   In this segment, you will analyse the 'ratings' table as well.
   To start with, let's get the minimum and maximum values of different columns in the table */

-- Segment 2:

-- Q10.  Find the minimum and maximum values for each column of the 'ratings' table except the movie_id column.


/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|max_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

-- Type your code below:
SELECT
  MIN(avg_rating) AS min_avg_rating,
  MAX(avg_rating) AS max_avg_rating,
  MIN(total_votes) AS min_total_votes,
  MAX(total_votes) AS max_total_votes,
  MIN(median_rating) AS min_median_rating,
  MAX(median_rating) AS max_median_rating
FROM ratings;



/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating. */

-- Q11. What are the top 10 movies based on average rating?

/* Output format:
+---------------+-------------------+---------------------+
|     title		|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
|     Fan		|		9.6			|			5	  	  |
|	  .			|		 .			|			.		  |
|	  .			|		 .			|			.		  |
|	  .			|		 .			|			.		  |
+---------------+-------------------+---------------------+*/

-- Type your code below:
-- Keep in mind that multiple movies can be at the same rank. You only have to find out the top 10 movies (if there are multiple movies at the 10th place, consider them all.)
WITH ranked_movies AS (
  SELECT 
    m.title,
    r.avg_rating,
    DENSE_RANK() OVER (ORDER BY r.avg_rating DESC) AS movie_rank,
    ROW_NUMBER() OVER (ORDER BY r.avg_rating DESC) AS row_num
  FROM movie m
  JOIN ratings r ON m.id = r.movie_id
  WHERE r.avg_rating IS NOT NULL
)

SELECT *
FROM ranked_movies
WHERE movie_rank <= 10 OR row_num <= 10;





-- Try using DENSE_RANK() and ROW_NUMBER() functions instead of RANK(). What difference do you observe?

/* Do you find the movie 'Fan' in the top 10 movies with an average rating of 9.6? If not, please check your code
again.
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight. */

-- Q12. Summarise the ratings table based on the movie counts by median ratings.

/* Output format:
+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

-- Type your code below:
SELECT median_rating, COUNT(*) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;




-- It is a good practice to use the 'ORDER BY' clause.

/* Movies with a median rating of 7 are the highest in number. 
Now, let's find out the production house with which RSVP Movies should look to partner with for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)?

/* Output format:
+------------------+-------------------+----------------------+
|production_company|    movie_count	   |    prod_company_rank |
+------------------+-------------------+----------------------+
| The Archers	   |		1		   |			1	  	  |
+------------------+-------------------+----------------------+*/

-- Type your code below:
SELECT production_company, COUNT(*) AS movie_count,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS prod_company_rank
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE r.avg_rating > 8 AND m.production_company IS NOT NULL
GROUP BY production_company;



-- It's okay to use RANK() or DENSE_RANK() as well.
-- The answer can be either Dream Warrior Pictures or National Theatre Live or both.

-- Q14. How many movies released in each genre in March 2017 in the USA had more than 1,000 votes?

/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

-- Type your code below:
SELECT g.genre, COUNT(*) AS movie_count
FROM movie m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE MONTH(date_published) = 3
  AND YEAR(date_published) = 2017
  AND country LIKE '%USA%'
  AND r.total_votes > 1000
GROUP BY g.genre;




-- Lets try analysing the 'imdb' database using a unique problem statement.

-- Q15. Find the movies in each genre that start with the characters ‘The’ and have an average rating > 8.

/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

-- Type your code below:
SELECT m.title, r.avg_rating, g.genre
FROM movie m
JOIN ratings r ON m.id = r.movie_id
JOIN genre g ON m.id = g.movie_id
WHERE m.title LIKE 'The%' AND r.avg_rating > 8;




-- You should also try out the same for median rating and check whether the ‘median rating’ column gives any
-- significant insights.

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

-- Type your code below:
SELECT COUNT(*) AS movie_count
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE r.median_rating = 8
  AND date_published BETWEEN '2018-04-01' AND '2019-04-01';



-- Now, let's see the popularity of movies in different languages.

-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
SELECT
  SUM(CASE WHEN m.languages LIKE '%German%' THEN r.total_votes ELSE 0 END) AS german_votes,
  SUM(CASE WHEN m.languages LIKE '%Italian%' THEN r.total_votes ELSE 0 END) AS italian_votes
FROM movie m
JOIN ratings r ON m.id = r.movie_id;



-- ----------------------------------------------------------------------------------------------------------------

/* Now that you have analysed the 'movie', 'genre' and 'ratings' tables, let us analyse another table - the 'names'
table. 
Let’s begin by searching for null values in the table. */

-- Segment 3:

-- Q18. Find the number of null values in each column of the 'names' table, except for the 'id' column.

/* Hint: You can find the number of null values for individual columns or follow below output format

+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/

-- Type your code below:
SELECT
  SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
  SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
  SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS dob_nulls,
  SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM names;



/* The director is the most important person in a movie crew. 
   Let’s find out the top three directors each in the top three genres who can be hired by RSVP Movies. */

-- Q19. Who are the top three directors in each of the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)

/* Output format:
+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
WITH top_genres AS (
  SELECT genre
  FROM genre g
  JOIN ratings r ON g.movie_id = r.movie_id
  WHERE r.avg_rating > 8
  GROUP BY genre
  ORDER BY COUNT(*) DESC
  LIMIT 3
),
director_counts AS (
  SELECT n.name AS director_name, g.genre, COUNT(*) AS movie_count,
         RANK() OVER (PARTITION BY g.genre ORDER BY COUNT(*) DESC) AS director_rank
  FROM director_mapping d
  JOIN names n ON d.name_id = n.id
  JOIN genre g ON d.movie_id = g.movie_id
  JOIN ratings r ON d.movie_id = r.movie_id
  WHERE r.avg_rating > 8 AND g.genre IN (SELECT genre FROM top_genres)
  GROUP BY n.name, g.genre
)
SELECT * FROM director_counts WHERE director_rank <= 3;




-- Q20. Who are the top two actors whose movies have a median rating >= 8?

/* Output format:
+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christian Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
SELECT n.name AS actor_name, COUNT(*) AS movie_count
FROM role_mapping rm
JOIN names n ON rm.name_id = n.id
JOIN ratings r ON rm.movie_id = r.movie_id
WHERE rm.category = 'actor' AND r.median_rating >= 8
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2;



-- Q21. Which are the top three production houses based on the number of votes received by their movies?

/* Output format:
+-------------------+-------------------+---------------------+
|production_company |   vote_count		|	prod_comp_rank    |
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|		.		      |
|	.				|		.			|		.		  	  |
+-------------------+-------------------+---------------------+*/
SELECT production_company, SUM(r.total_votes) AS vote_count,
       RANK() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE production_company IS NOT NULL
GROUP BY production_company
ORDER BY vote_count DESC
LIMIT 3;


/*Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies is looking to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be. */

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the
-- list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes
-- should act as the tie breaker.)

/* Output format:
+---------------+---------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes	|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+---------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|		3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|		.		|	       .		  |	   .	    		 |		.	       |
|		.		|		.		|	       .		  |	   .	    		 |		.	       |
+---------------+---------------+---------------------+----------------------+-----------------+*/

-- Type your code below:
WITH actor_data AS (
  SELECT n.name AS actor_name, COUNT(*) AS movie_count,
         SUM(r.total_votes) AS total_votes,
         SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS actor_avg_rating
  FROM names n
  JOIN role_mapping rm ON n.id = rm.name_id
  JOIN movie m ON rm.movie_id = m.id
  JOIN ratings r ON m.id = r.movie_id
  WHERE rm.category = 'actor'
    AND m.country LIKE '%India%'
  GROUP BY n.name
  HAVING COUNT(*) >= 5
)
SELECT *, RANK() OVER (ORDER BY actor_avg_rating DESC, total_votes DESC) AS actor_rank
FROM actor_data;



-- Q23.Find the top five actresses in Hindi movies released in India based on their average ratings.
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes
-- should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- Type your code below:
WITH actress_data AS (
  SELECT n.name AS actress_name, COUNT(*) AS movie_count,
         SUM(r.total_votes) AS total_votes,
         SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS actress_avg_rating
  FROM names n
  JOIN role_mapping rm ON n.id = rm.name_id
  JOIN movie m ON rm.movie_id = m.id
  JOIN ratings r ON m.id = r.movie_id
  WHERE rm.category = 'actress'
    AND m.country LIKE '%India%'
    AND m.languages LIKE '%Hindi%'
  GROUP BY n.name
  HAVING COUNT(*) >= 3
)
SELECT *, RANK() OVER (ORDER BY actress_avg_rating DESC, total_votes DESC) AS actress_rank
FROM actress_data
LIMIT 5;


-- Now let us divide all the thriller movies in the following categories and find out their numbers.
/* Q24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories:  

			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop
	
    Note: Sort the output by average ratings (descending).
--------------------------------------------------------------------------------------------*/
/* Output format:
+---------------+-------------------+
| movie_name	|	movie_category	|
+---------------+-------------------+
|	Get Out		|			Hit		|
|		.		|			.		|
|		.		|			.		|
+---------------+-------------------+*/
SELECT m.title AS movie_name,
  CASE
    WHEN r.avg_rating > 8 THEN 'Superhit'
    WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit'
    WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch'
    ELSE 'Flop'
  END AS movie_category
FROM movie m
JOIN ratings r ON m.id = r.movie_id
JOIN genre g ON m.id = g.movie_id
WHERE g.genre = 'Thriller' AND r.total_votes >= 25000
ORDER BY r.avg_rating DESC;


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment. */

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to get the output according to the output format given below.)

/* Output format:
+---------------+-------------------+----------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration   |
+---------------+-------------------+----------------------+----------------------+
|	comedy		|			145		|	       106.2	   |	   128.42	      |
|		.		|			.		|	       .		   |	   .	    	  |
|		.		|			.		|	       .		   |	   .	    	  |
|		.		|			.		|	       .		   |	   .	    	  |
+---------------+-------------------+----------------------+----------------------+*/
WITH genre_duration AS (
  SELECT g.genre, ROUND(AVG(m.duration), 2) AS avg_duration
  FROM genre g
  JOIN movie m ON g.movie_id = m.id
  GROUP BY g.genre
),
ranked AS (
  SELECT *, ROW_NUMBER() OVER (ORDER BY genre) AS rn
  FROM genre_duration
)
SELECT a.genre, a.avg_duration,
       SUM(b.avg_duration) AS running_total_duration,
       ROUND(AVG(b.avg_duration), 2) AS moving_avg_duration
FROM ranked a
JOIN ranked b ON b.rn <= a.rn
GROUP BY a.genre, a.avg_duration, a.rn
ORDER BY a.rn;


-- Q26. Which are the five highest-grossing movies in each year for each of the top three genres?
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- Type your code below:
WITH genre_count AS (
  SELECT genre, COUNT(*) AS count
  FROM genre
  GROUP BY genre
  ORDER BY count DESC
  LIMIT 3
),
income_data AS (
  SELECT g.genre, m.year, m.title AS movie_name,
         CAST(REPLACE(REPLACE(worlwide_gross_income, '$', ''), ',', '') AS UNSIGNED) AS gross
  FROM genre g
  JOIN movie m ON g.movie_id = m.id
  WHERE g.genre IN (SELECT genre FROM genre_count)
    AND worlwide_gross_income IS NOT NULL
),
ranked AS (
  SELECT *, RANK() OVER (PARTITION BY genre, year ORDER BY gross DESC) AS movie_rank
  FROM income_data
)
SELECT * FROM ranked
WHERE movie_rank <= 5;

-- Top 3 Genres based on most number of movies
SELECT genre, COUNT(*) AS count
  FROM genre
  GROUP BY genre
  ORDER BY count DESC;

/*Q27. What are the top two production houses that have produced the highest number of hits (median rating >= 8) among
multilingual movies? */

/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
SELECT 
  m.production_company,
  COUNT(*) AS hit_movie_count,
  RANK() OVER (ORDER BY COUNT(*) DESC) AS company_rank
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE r.median_rating >= 8
  AND m.languages LIKE '%,%'  -- indicates multilingual (more than one language)
  AND m.production_company IS NOT NULL
GROUP BY m.production_company
ORDER BY hit_movie_count DESC
LIMIT 2;

-- Q28. Who are the top 3 actresses based on the number of Super Hit movies (Superhit movie: average rating of movie > 8) in 'drama' genre?

-- Note: Consider only superhit movies to calculate the actress average ratings.
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes
-- should act as the tie breaker. If number of votes are same, sort alphabetically by actress name.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	  actress_avg_rating |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.6000		     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
WITH superhit_drama_movies AS (
  SELECT m.id AS movie_id, r.avg_rating, r.total_votes
  FROM movie m
  JOIN ratings r ON m.id = r.movie_id
  JOIN genre g ON m.id = g.movie_id
  WHERE r.avg_rating > 8 AND g.genre = 'Drama'
),
actress_data AS (
  SELECT 
    n.name AS actress_name,
    COUNT(*) AS movie_count,
    SUM(r.total_votes) AS total_votes,
    ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 4) AS actress_avg_rating
  FROM superhit_drama_movies r
  JOIN role_mapping rm ON r.movie_id = rm.movie_id
  JOIN names n ON rm.name_id = n.id
  WHERE rm.category = 'actress'
  GROUP BY n.name
),
ranked_actresses AS (
  SELECT *,
         RANK() OVER (
           ORDER BY actress_avg_rating DESC, total_votes DESC, actress_name ASC
         ) AS actress_rank
  FROM actress_data
)
SELECT *
FROM ranked_actresses
WHERE actress_rank <= 3;



/* Q29. Get the following details for top 9 directors (based on number of movies):

Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
Total movie duration

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
WITH director_movies AS (
  SELECT 
    d.name_id AS director_id,
    n.name AS director_name,
    m.id AS movie_id,
    m.date_published,
    m.duration,
    r.avg_rating,
    r.total_votes
  FROM director_mapping d
  JOIN names n ON d.name_id = n.id
  JOIN movie m ON d.movie_id = m.id
  JOIN ratings r ON m.id = r.movie_id
),
movie_with_gaps AS (
  SELECT *,
    DATEDIFF(date_published, LAG(date_published) OVER (PARTITION BY director_id ORDER BY date_published)) AS inter_movie_gap
  FROM director_movies
),
aggregated AS (
  SELECT
    director_id,
    director_name,
    COUNT(*) AS number_of_movies,
    ROUND(AVG(inter_movie_gap), 0) AS avg_inter_movie_days,
    ROUND(AVG(avg_rating), 2) AS avg_rating,
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration
  FROM movie_with_gaps
  GROUP BY director_id, director_name
)
SELECT *
FROM aggregated
ORDER BY number_of_movies DESC
LIMIT 9;
