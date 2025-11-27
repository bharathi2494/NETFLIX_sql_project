-- Business problem solutions

/* 1. Count the number of Movies vs TV Shows */

SELECT type, COUNT(*) AS no_of_records
FROM netflix
GROUP BY type;

/* 2. Find the most common rating for movies and TV shows */

SELECT
	type,rating
FROM
(
SELECT 
	type, 
	rating, 
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix 
GROUP BY 1, 2
ORDER BY 1,3 DESC
)
WHERE ranking=1

/* 3. List all movies released in a specific year (e.g., 2020) */

SELECT title
FROM netflix
WHERE type='Movie' AND release_year=2020

/* 4. Find the top 5 countries with the most content on Netflix */

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, 
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

/* 5. Identify the longest movie */

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC


/* 6. Find content added in the last 5 years */

SELECT *
FROM netflix 
WHERE date_added >= (SELECT CURRENT_DATE - interval '5 years')

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT type, title, director 
FROM netflix 
WHERE director ilike '%Rajiv Chilaka%' 

/* Here using ilike operator to perform case-insensitive pattern matching. */

--8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;

--9. Count the number of content items in each genre

SELECT
 UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS Genre,
 COUNT(show_id)
FROM netflix
GROUP BY 1

-- 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release! 

SELECT 
	EXTRACT(YEAR FROM date_added) as year,
	count(*),
	ROUND(
	count(*)::numeric/(select count(*) from netflix where country= 'India')::numeric *100
	,2) as avg_content
FROM netflix WHERE country='India'
GROUP BY 1


--11. List all movies that are documentaries

SELECT *
FROM (
    SELECT 
        title,
        type,
        TRIM(unnest(string_to_array(listed_in, ','))) AS docum
    FROM netflix
) AS t
WHERE type = 'Movie'
AND docum = 'Documentaries';


--12. Find all content without a director

SELECT * 
FROM netflix 
WHERE director IS NULL;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * 
FROM netflix 
WHERE casts ILIKE '%salman Khan%' 
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
	UNNEST(string_to_array(casts, ',')) AS actors, 
	COUNT(*) AS no_of_movies
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10


/* 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category. */

WITH new_table
AS(
SELECT 
	*,
	CASE 
	WHEN 
		description ILIKE '%kill%'
		OR	description ILIKE '%violence' 
		THEN 'bad_content'
	    ELSE 'good_content' 
	END as category
FROM netflix)
	SELECT category, 
		COUNT(*) as total_content
	FROM new_table
	GROUP BY 1
	ORDER BY category DESC
	
	

