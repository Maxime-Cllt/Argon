-- **************************
-- ANALYSE SUR LES COMMERCES
-- **************************

-- Les 200 business avec le plus de compliments
SELECT t1.name,
       count(t2.compliment_count) AS total_compliments,
       t1.city,
       t1.state
FROM dim_business AS t1
         INNER JOIN dim_tips AS t2
                    ON t1.business_id = t2.business_id
WHERE t2.compliment_count IS NOT NULL
GROUP BY t1.business_id
ORDER BY total_compliments DESC
LIMIT 200;


-- Répartition des business par catégorie
SELECT value, COUNT(business_id) AS count_business
FROM fact_business AS t1
         INNER JOIN dim_categories AS t2
                    ON t1.category_id = t2.category_id
WHERE t2.category = 'Categorie'
GROUP BY value
ORDER BY count_business DESC;



-- **************************
-- ANALYSE SUR LA GEOGRAPHIE
-- **************************

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


-- Ratio d'habitants par ville / nombre de business
SELECT t1.city_name, t1.population, COUNT(t2.business_id) AS count_business
FROM dim_city AS t1
         INNER JOIN fact_business AS t2
                    ON t1.city_name = t2.city
WHERE population > 0
GROUP BY t1.city_name, t1.population;


-- Répartition des catégories de business par ville avec le nombre de business
SELECT city, value, COUNT(business_id) AS count_business
FROM fact_business AS t1
         INNER JOIN dim_categories AS t2
                    ON t1.category_id = t2.category_id
WHERE t2.category = 'Categorie'
  AND value IS NOT NULL
  AND length(value) > 0
  AND city IS NOT NULL
  AND length(city) > 0
GROUP BY city, value
ORDER BY count_business DESC;


-- Les villes qui font le plus de tips
SELECT t1.city,
       count(t2.compliment_count) AS max_compliment_count
FROM fact_business AS t1
         INNER JOIN dim_tips AS t2
                    ON t1.business_id = t2.business_id
WHERE t2.compliment_count IS NOT NULL
GROUP BY t1.city
ORDER BY max_compliment_count DESC;

-- Les states qui font en moyenne le plus de checkins
SELECT t1.state,
       AVG(t2.checkin_count) AS avg_checkin_count
FROM fact_business AS t1
         INNER JOIN dim_business AS t2
                    ON t1.business_id = t2.business_id
WHERE t2.checkin_count > 0
  AND t2.checkin_count IS NOT NULL
GROUP BY t1.state
ORDER BY avg_checkin_count DESC;


-- Les city qui font en moyenne le plus de checkins
SELECT t1.city,
       AVG(t2.checkin_count) AS avg_checkin_count
FROM fact_business AS t1
         INNER JOIN dim_business AS t2
                    ON t1.business_id = t2.business_id
WHERE t2.checkin_count > 0
  AND t2.checkin_count IS NOT NULL
GROUP BY t1.city
ORDER BY avg_checkin_count DESC;

-- **************************
-- ANALYSE SUR LES HORAIRES
-- **************************

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
  AND h.hours NOT NULL
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


-- **************************
-- ANALYSE SUR LES ATTRIBUTS
-- **************************

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


-- Les attributs les plus communes à Las Vegas
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


-- Les attributs qui plaisent le plus
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
GROUP BY c.category
ORDER BY total_compliments DESC;

-- Les catégories qui reçoivent le plus de compliments
SELECT t1.value,
       SUM(t3.compliment_count) AS total_compliments
FROM fact_business AS t1
         INNER JOIN dim_categories AS t2
                    ON t1.category_id = t2.category_id
         INNER JOIN dim_tips AS t3
                    ON t1.business_id = t3.business_id
WHERE t2.category = 'Categorie'
  AND compliment_count > 0
GROUP BY t1.value
ORDER BY total_compliments DESC;


-- Les catégories qui plaisent le plus en fonction de la ville
SELECT t1.city,
       t1.value,
       AVG(t3.compliment_count) AS total_compliments
FROM fact_business AS t1
         INNER JOIN dim_categories AS t2
                    ON t1.category_id = t2.category_id
         INNER JOIN dim_tips AS t3
                    ON t1.business_id = t3.business_id
WHERE t2.category = 'Categorie'
  AND length(t1.value) > 0
GROUP BY t1.city, t1.value
ORDER BY total_compliments DESC;

-- Les villes qui ont le plus de business avec l'attribut 'French'
SELECT t3.city, COUNT(t1.city) AS count_business
FROM fact_business AS t1
         INNER JOIN dim_categories AS t2
                    ON t1.category_id = t2.category_id
         INNER JOIN dim_business AS t3
                    ON t1.business_id = t3.business_id
WHERE t2.category = 'Categorie'
  AND t1.value IS NOT NULL
  AND length(t1.value) > 0
  AND t1.value = 'French'
GROUP BY t3.city
ORDER BY count_business DESC;


-- **************************
-- ANALYSE SUR LES DATES
-- **************************


-- L'historique des checkins sur toute la période
SELECT date,
       COUNT(date) AS total_checkins
FROM dim_checkin
WHERE date > '2019-01-01'
GROUP BY date;

-- Les jours de l'année avec le plus de checkins
SELECT strftime('%m-%d', date) AS month_day, COUNT(checkin_id) AS checkin_count
FROM dim_checkin
GROUP BY month_day;

-- Les jours de l'année avec le plus de tips
SELECT strftime('%m-%d', date) AS month_day, COUNT(tips_id) AS checkin_count
FROM dim_tips
GROUP BY month_day
ORDER BY month_day;