-- Les 200 business avec le plus de compliments
SELECT t1.name,
       AVG(t2.compliment_count) AS avg_compliment_count,
       t1.city,
       t1.state
FROM dim_business AS t1
         INNER JOIN dim_tips AS t2
                    ON t1.business_id = t2.business_id
WHERE t2.compliment_count > 0
  AND t2.compliment_count IS NOT NULL
GROUP BY t1.business_id
ORDER BY avg_compliment_count DESC
LIMIT 200;


-- Les 20 villes avec le plus de business
WITH RankedCities AS (SELECT city,
                             COUNT(fact_business_id)                                   AS count_business,
                             ROW_NUMBER() OVER (ORDER BY COUNT(fact_business_id) DESC) AS rank
                      FROM fact_business
                      GROUP BY city)
SELECT city,
       count_business
FROM RankedCities
WHERE rank <= 20
ORDER BY rank;


-- Les villes qui donnent en moyenne le plus de compliments
SELECT t1.city,
       AVG(t2.compliment_count) AS avg_compliment_count
FROM dim_business AS t1
         INNER JOIN dim_tips AS t2
                    ON t1.business_id = t2.business_id
WHERE t2.compliment_count > 0
  AND t2.compliment_count IS NOT NULL
GROUP BY t1.city
ORDER BY avg_compliment_count DESC
LIMIT 50;

-- Les heures d'ouverture les plus communes sur une semaine
SELECT h.hours  AS common_hours,
       COUNT(*) AS frequency
FROM dim_business_hours bh
         INNER JOIN
     dim_hours h
     ON
         h.id_hours = bh.id_hours_monday
             OR h.id_hours = bh.id_hours_tuesday
             OR h.id_hours = bh.id_hours_wednesday
             OR h.id_hours = bh.id_hours_thursday
             OR h.id_hours = bh.id_hours_friday
             OR h.id_hours = bh.id_hours_saturday
             OR h.id_hours = bh.id_hours_sunday
WHERE length(h.hours) > 0
AND h.hours NOT IN ('0:0-0:0')
GROUP BY h.hours
ORDER BY frequency DESC;

-- Les heures d'ouverture les plus communes par jour de la semaine
WITH HoursFrequency AS (SELECT 'Monday' AS day_of_week,
                               h.hours  AS common_hours,
                               COUNT(*) AS frequency
                        FROM dim_business_hours bh
                                 JOIN dim_hours h ON h.id_hours = bh.id_hours_monday
                        WHERE h.hours NOT IN ('', '0:0-0:0')
                        GROUP BY h.hours
                        UNION ALL
                        SELECT 'Tuesday', h.hours, COUNT(*)
                        FROM dim_business_hours bh
                                 JOIN dim_hours h ON h.id_hours = bh.id_hours_tuesday
                        WHERE h.hours NOT IN ('', '0:0-0:0')
                        GROUP BY h.hours
                        UNION ALL
                        SELECT 'Wednesday', h.hours, COUNT(*)
                        FROM dim_business_hours bh
                                 JOIN dim_hours h ON h.id_hours = bh.id_hours_wednesday
                        WHERE h.hours NOT IN ('', '0:0-0:0')
                        GROUP BY h.hours
                        UNION ALL
                        SELECT 'Thursday', h.hours, COUNT(*)
                        FROM dim_business_hours bh
                                 JOIN dim_hours h ON h.id_hours = bh.id_hours_thursday
                        WHERE h.hours NOT IN ('', '0:0-0:0')
                        GROUP BY h.hours
                        UNION ALL
                        SELECT 'Friday', h.hours, COUNT(*)
                        FROM dim_business_hours bh
                                 JOIN dim_hours h ON h.id_hours = bh.id_hours_friday
                        WHERE h.hours NOT IN ('', '0:0-0:0')
                        GROUP BY h.hours
                        UNION ALL
                        SELECT 'Saturday', h.hours, COUNT(*)
                        FROM dim_business_hours bh
                                 JOIN dim_hours h ON h.id_hours = bh.id_hours_saturday
                        WHERE h.hours NOT IN ('', '0:0-0:0')
                        GROUP BY h.hours
                        UNION ALL
                        SELECT 'Sunday', h.hours, COUNT(*)
                        FROM dim_business_hours bh
                                 JOIN dim_hours h ON h.id_hours = bh.id_hours_sunday
                        WHERE h.hours NOT IN ('', '0:0-0:0')
                        GROUP BY h.hours)
SELECT day_of_week,
       common_hours,
       MAX(frequency) AS max_frequency
FROM HoursFrequency
GROUP BY day_of_week
ORDER BY CASE day_of_week
             WHEN 'Monday' THEN 1
             WHEN 'Tuesday' THEN 2
             WHEN 'Wednesday' THEN 3
             WHEN 'Thursday' THEN 4
             WHEN 'Friday' THEN 5
             WHEN 'Saturday' THEN 6
             WHEN 'Sunday' THEN 7
             END;

-- Combien de business sont ouverts 24h/24 7j/7
SELECT COUNT(business_id) AS count_business
FROM dim_business_hours
WHERE id_hours_monday = 1
  AND id_hours_tuesday = 1
  AND id_hours_wednesday = 1
  AND id_hours_thursday = 1
  AND id_hours_friday = 1
  AND id_hours_saturday = 1
  AND id_hours_sunday = 1;


-- Les states qui font en moyenne le plus de checkins
SELECT t1.state,
       AVG(t2.checkin_count) AS avg_checkin_count
FROM fact_business AS t1
         INNER JOIN dim_business AS t2
                    ON t1.business_id = t2.business_id
WHERE t2.checkin_count > 0
GROUP BY t1.state
ORDER BY avg_checkin_count DESC;


-- Les catégories les plus communes par ville
SELECT t1.city,
       t2.category
FROM fact_business AS t1
         INNER JOIN dim_categories AS t2
                    ON t1.category_id = t2.category_id
WHERE t1.category_id IS NOT NULL
  AND t2.category != 'Categorie'
  AND length(t2.category) > 0
  AND length(t1.city) > 0
GROUP BY t1.city;


-- Les catégories les plus communes à Las Vegas
SELECT t2.category,
       t2.category_id AS count_category
FROM fact_business AS t1
         INNER JOIN dim_categories AS t2
                    ON t1.category_id = t2.category_id
WHERE t1.category_id IS NOT NULL
  AND t1.city = 'Las Vegas'
  AND t2.category != 'Categorie'
GROUP BY count_category
ORDER BY count_category DESC;


-- Les catégories qui plaisent le plus
SELECT c.category,
       SUM(t.compliment_count) AS total_compliments
FROM dim_tips t
         JOIN
     fact_business b ON t.business_id = b.business_id
         JOIN
     dim_categories c ON b.category_id = c.category_id
WHERE c.category != 'Categorie'
  AND t.compliment_count IS NOT NULL
  AND c.category IS NOT NULL
  AND t.compliment_count > 0
GROUP BY c.category
ORDER BY total_compliments DESC;