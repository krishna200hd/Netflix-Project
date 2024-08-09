select * from credits
select * from titles

---- What were the top 10 movies according to IMDB score?

with cte as
(select title,imdb_score,type,
row_number() over(order by imdb_score desc) as rn
from titles
where type = 'MOVIE' and imdb_score>=8.0
group by title,imdb_score,type)

select rn,imdb_score,title
from cte
where rn<=10

-- What were the top 10 shows according to IMDB score? 

with cte as
(select title,imdb_score,type,
row_number() over(order by imdb_score desc) as rn
from titles
where type = 'SHOW' and imdb_score>=8.0
group by title,imdb_score,type)

select rn,imdb_score,title
from cte
where rn<=10

-- What were the bottom 10 movies according to IMDB score? 

with cte as
(select title,imdb_score,type,
row_number() over(order by imdb_score ASC) as rn
from titles
where type = 'MOVIE' and imdb_score
 <=8.0
group by title,imdb_score,type)

select rn,imdb_score,title
from cte
where rn<=10

--What were the bottom 10 movies according to IMDB score?\

with cte as
(select title,imdb_score,type,
row_number() over(order by imdb_score ASC) as rn
from titles
where type = 'SHOW' and imdb_score
 <=8.0
group by title,imdb_score,type)

select rn,imdb_score,title
from cte
where rn<=10

--What were the average IMDB and TMDB scores for shows and movies? 

SELECT type, 
    ROUND(AVG(CAST(imdb_score AS INTEGER)), 2) AS avg_imdb_score,
    ROUND(AVG(CAST(tmdb_score AS INTEGER)), 2) AS avg_tmdb_score
FROM titles
WHERE type IN ('SHOW', 'MOVIE')
GROUP BY type;

--Count of movies and shows in each decade

SELECT type,
    COUNT(title) AS title_count,
    CASE
        WHEN EXTRACT(YEAR FROM release_year) BETWEEN 2010 AND 2019 THEN '2010 - 2019'
        WHEN EXTRACT(YEAR FROM release_year) BETWEEN 2000 AND 2009 THEN '2000 - 2009'
        WHEN EXTRACT(YEAR FROM release_year) BETWEEN 1990 AND 1999 THEN '1990 - 1999'
        WHEN EXTRACT(YEAR FROM release_year) BETWEEN 1980 AND 1989 THEN '1980 - 1989'
        WHEN EXTRACT(YEAR FROM release_year) BETWEEN 1970 AND 1979 THEN '1970 - 1979'
        WHEN EXTRACT(YEAR FROM release_year) BETWEEN 1960 AND 1969 THEN '1960 - 1969'
    END AS decade
FROM titles
where type = 'SHOW'
GROUP BY decade,type
ORDER BY decade;

--What were the average IMDB and TMDB scores for each production country?


select * from titles
SELECT production_countries,
    ROUND(AVG(CAST(imdb_score AS INTEGER)), 2) AS avg_imdb_score,
    ROUND(AVG(CAST(tmdb_score AS INTEGER)), 2) AS avg_tmdb_score
FROM titles
GROUP BY production_countries

--What were the average IMDB and TMDB scores for each age certification for shows and movies?

SELECT DISTINCT age_certification, 
ROUND(AVG(CAST(imdb_score AS INTEGER)), 2) AS avg_imdb_score,
    ROUND(AVG(CAST(tmdb_score AS INTEGER)), 2) AS avg_tmdb_score
FROM titles
GROUP BY  DISTINCT age_certification

-- What were the 5 most common age certifications for movies?

SELECT age_certification, 
COUNT(*) AS certification_count
FROM titles
WHERE type = 'MOVIE' 
AND age_certification <> 'N/A'
GROUP BY age_certification
ORDER BY certification_count DESC
LIMIT 5;

--Who were the top 20 actors that appeared the most in movies/shows? 

with cte as 
(select c.name as name,t.type as type,count(*) as apperance,
row_number() over (order by count(*) desc) as rn
from credits c join titles t on t.id=c.id
where role = 'ACTOR'
group by c.name,t.type
order by apperance desc)

select name,type,apperance 
from cte
where rn<=20

--Who were the top 20 directors that directed the most movies/shows? 

with cte as 
(select c.name as name,t.type as type,count(*) as directed,
row_number() over (order by count(*) desc) as rn
from credits c join titles t on t.id=c.id
where role = 'DIRECTOR'
group by c.name,t.type
order by directed desc)

select name,type,directed
from cte
where rn<=20

--Calculating the average runtime of movies and TV shows separately

--1st method
select round(avg(runtime),2) as run_time,type
from titles
where type in ('MOVIE','SHOW')
group by type

--2nd method using union all
SELECT 
type,
ROUND(AVG(runtime),2) AS avg_runtime_min
FROM titles
WHERE type = 'MOVIE'
GROUP BY type
UNION ALL
SELECT 
type,
ROUND(AVG(runtime),2) AS avg_runtime_min
FROM titles
WHERE type = 'SHOW'
group by type

--Finding the titles and  directors of movies released on or after 2010

select t.title,c.role ,t.release_year
from titles t
join credits c on c.id=t.id
where c.role= 'DIRECTOR' and release_year>='2010'

--Which shows on Netflix have the most seasons?

WITH seasons_cte as 
(SELECT SEASONS,TITLE ,
RANK() OVER(ORDER BY SEASONS DESC) AS RN
FROM TITLES
WHERE SEASONS IS NOT NULL
order by seasons desc)

select seasons,title
from seasons_cte
where rn<=5

--Which genres had the most movies and shows?

SELECT genres, 
COUNT(*) AS title_count
FROM titles 
WHERE type = 'MOVIE'
GROUP BY genres
ORDER BY title_count DESC

-- SHOWS

SELECT genres, 
COUNT(*) AS title_count
FROM titles 
WHERE type = 'SHOW'
GROUP BY genres
ORDER BY title_count DESC

--Titles and Directors of movies with high IMDB scores (>7.5) and high TMDB popularity scores (>80)

SELECT t.title, 
c.name 
FROM titles AS t
JOIN credits AS c 
ON t.id = c.id
WHERE t.type = 'MOVIE' 
AND t.imdb_score > 7.5 
AND t.tmdb_popularity > 80 
AND c.role = 'DIRECTOR'

--What were the total number of titles for each year? 

SELECT COUNT(*) AS TOTAL_TITLE,
RELEASE_YEAR
FROM TITLES
GROUP BY RELEASE_YEAR
ORDER BY RELEASE_YEAR DESC

--Actors who have starred in the most highly rated movies or shows

--1st method

select c.role as actor,c.name as name,COUNT(*) AS COUNT_POPULARITY
from titles t join credits c on c.id=t.id
where type in ('MOVIE','SHOW') 
AND IMDB_SCORE IS NOT NULL 
AND ROLE='ACTOR'
and t.tmdb_score>8.0
and t.imdb_score>8.0
GROUP BY c.role,c.name
order by count_popularity desc

--2nd method

SELECT c.name AS actor, 
COUNT(*) AS num_highly_rated_titles
FROM credits AS c
JOIN titles AS t 
ON c.id = t.id
WHERE c.role = 'ACTOR'
AND (t.type = 'MOVIE' OR t.type = 'SHOW')
AND t.imdb_score > 8.0
AND t.tmdb_score > 8.0
GROUP BY c.name
ORDER BY num_highly_rated_titles DESC;

--Which actors/actresses played the same character in multiple movies or TV shows? 

select c.role,t.type, count(distinct t.title) as num_title ,c.name,c.character
from credits c join titles t on t.id=c.id
where c.role in ('ACTOR','ACTRESS')  
group by c.role,t.type,c.character,c.name
having count(distinct t.title)>=2
order by count(distinct t.title) desc

--Avg Imdb score for leading actor and actress in movie and shows

select avg(t.imdb_score) as avg_score,c.role,c.name from credits c join titles t on c.id=t.id 
where c.role='ACTOR'  
group by c.role,c.name
having  avg(t.imdb_score) is not null
order by avg_score desc

