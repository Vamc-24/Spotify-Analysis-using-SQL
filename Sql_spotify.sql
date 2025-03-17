-- EDA

SELECT * from spotify
LIMIT 10;

SELECT count(*) from spotify

select count(distinct artist) from spotify

select count(distinct album) from spotify

select distinct album_type from spotify

select avg(duration_min) from spotify

select max(duration_min) from spotify

select min(duration_min) from spotify

select * from spotify
WHERE duration_min=0

delete from spotify
where duration_min=0

select count(distinct channel) from spotify

select max ( views) from spotify

select min ( views) from spotify

SELECT max (likes) from spotify

SELECT min (likes) from spotify

select count(licensed) from spotify
where licensed='True'

select count(licensed) from spotify
where licensed='False'

select count(Official_video) from spotify
where Official_video='True'

select count(Official_video) from spotify
where Official_video='False'


select distinct(most_played_on) from spotify

select count(distinct(title))from spotify

-- ----------------------------------------------------------------
--  Data Analysis      Easy level
-- ----------------------------------------------------------------
/* 
1. Retrieve the names of all tracks that have more than 1 billion streams.
2. List all albums along with their respective artists.
3. Get the total number of comments for tracks where licensed = TRUE.
4. Find all tracks that belong to the album type single.
5. Count the total number of tracks by each artist.
*/


-- 1.  Retrieve the names of all tracks that have more than 1 billion streams.

SELECT track from spotify
where stream > 1000000

SELECT count(track) as number_of_tracks_more_than_billion from spotify
where stream > 1000000

-- 2. List all albums along with their respective artists.

SELECT distinct album,artist from spotify
ORDER BY 1

-- 3. Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) as Total_number_of_comments from spotify
where licensed='True'

-- 4.  Find all tracks that belong to the album type single.

select track,album_type from spotify
where album_type='single'

select count(track) from spotify
where album_type='single'


-- 5. Count the total number of tracks by each artist.

SELECT artist,count(track) as total_no_tracks
 from spotify
 GROUP BY 1
 ORDER by 2 desc

-- -----------------------------------------------------------------
--      Data Analysis      Medium level
-- -----------------------------------------------------------------

/*
1. Calculate the average danceability of tracks in each album.
2. Find the top 5 tracks with the highest energy values.
3. List all tracks along with their views and likes where official_video = TRUE.
4. For each album, calculate the total views of all associated tracks.
5. Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- 1.  Calculate the average danceability of tracks in each album.

select 
    album, 
    Avg(danceability) as average_danceability
from spotify
GROUP BY 1
ORDER BY 2 desc

-- 2.  Find the top 5 tracks with the highest energy values.

SELECT 
    track,
    max(energy) from spotify
GROUP BY track
ORDER BY 2 desc
LIMIT 5

-- 3. List all tracks along with their views and likes where official_video = TRUE.

SELECT 
     track,
    sum(views) as Total_views,
    sum(likes) as Total_likes 
from spotify
where official_video='True'
GROUP BY 1
ORDER BY 2 desc

-- 4. For each album, calculate the total views of all associated tracks.

SELECT 
    album ,
    track, 
    sum(views)as Total_views 
from spotify
GROUP BY 1,2
ORDER BY 3 desc

-- 5.  Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT track,stream ,most_played_on from spotify

select * 
from (SELECT
            track,
            coalesce (Sum(case when most_played_on ='Youtube' Then stream End),0 )streamed_on_youtube,
            coalesce (Sum(case when most_played_on ='Spotify' Then stream End),0 )streamed_on_spotify
        from spotify
        GROUP BY 1
    ) as t1

WHERE streamed_on_spotify > streamed_on_youtube
    and streamed_on_youtube <> 0



-- ---------------------------------------------------------------------
--      Data Analysis      Hard level
-- ---------------------------------------------------------------------

/* 
1. Find the top 3 most-viewed tracks for each artist using window functions.
2. Write a query to find tracks where the liveness score is above the average.
3. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

-- 1. Find the top 3 most-viewed tracks for each artist using window functions.

with ranking_aritist as (SELECT 
    track,
    artist,
    sum(views),
    Dense_rank() Over( Partition by artist ORDER BY sum(views)) as rank
from spotify

GROUP BY 2,1
ORDER BY 2,4)

SELECT * from ranking_aritist
where rank<=3

-- 2. Write a query to find tracks where the liveness score is above the average.

SELECT
     track,
     liveness
from spotify
where liveness>(select avg(liveness) from spotify)

-- 3. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

With Energy_table as (SELECT 
    album,
    Max(energy) as highest_energy,
    Min(energy) as Lowest_energy
From spotify
GROUP BY 1
)
SELECT highest_energy-Lowest_energy as difference_of_energy from Energy_table
ORDER BY 1 desc 
 
-- 4. Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT 
    track ,
    energy_liveness
from spotify
where energy_liveness >1.2
ORDER BY 2 desc


-- 5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT
    track,
    sum(likes) as Total_likes,
    sum(views) as Total_views
From spotify
GROUP BY 1
ORDER BY 3 desc

WITH cte AS (
    SELECT 
        track,
        SUM(likes) OVER (ORDER BY views DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sum
    FROM spotify
)
SELECT * FROM cte;