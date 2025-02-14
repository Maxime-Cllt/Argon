-- **************************
-- ANALYSE SUR LES COMMERCES
-- **************************

-- Les type de commerces avec leur catégorie et des informations sur générales
SELECT t2.name,
       STRING_AGG(
               (SELECT t6.category
                FROM dim_categories AS t6
                WHERE t6.category_id = t1.category_id
                  AND t6.category != 'Categorie'
                LIMIT 1), ', ') AS attributes,
       STRING_AGG(
               (SELECT t1.value
                FROM dim_categories AS t6
                WHERE t6.category_id = t1.category_id
                  AND t6.category = 'Categorie'
                LIMIT 1), ', ') AS categories,
       t1.review_count,
       t2.checkin_count,
       t2.avg_stars,
       t1.city
FROM fact_business AS t1
         INNER JOIN dim_business AS t2 ON t1.business_id = t2.business_id
GROUP BY t1.business_id, t2.name, t1.review_count, t2.checkin_count, t2.avg_stars, t1.city;


-- Répartition des business par catégorie
SELECT value, COUNT(business_id) AS count_business
FROM fact_business AS t1
         INNER JOIN dim_categories AS t2
                    ON t1.category_id = t2.category_id
WHERE t2.category = 'Categorie'
GROUP BY value
ORDER BY count_business DESC;

-- Les business les mieux notés
SELECT t1.name, avg(t2.stars) AS avg_stars, count(t2.stars) AS count_reviews
FROM dim_business AS t1
         INNER JOIN dim_reviews AS t2 ON t1.business_id = t2.business_id
WHERE t2.stars = (SELECT MAX(stars) FROM dim_reviews)
GROUP BY t1.name
ORDER BY count_reviews DESC;

-- **************************
-- ANALYSE SUR LA GEOGRAPHIE
-- **************************

-- Les 20 villes avec le plus de business
WITH RankedCities AS (SELECT city,
                             t1.state,
                             COUNT(fact_business_id)                                   AS count_business,
                             ROW_NUMBER() OVER (ORDER BY COUNT(fact_business_id) DESC) AS rank
                      FROM fact_business AS t1
                               INNER JOIN dim_city AS t2 ON upper(t1.city) = t2.city_name
                      WHERE population > 0
                      GROUP BY city)
SELECT city,
       state,
       count_business
FROM RankedCities
WHERE rank <= 20
ORDER BY rank;


-- Ratio d'habitants par ville / nombre de business
SELECT t2.city, t1.population, COUNT(t2.business_id) AS count_business
FROM dim_city AS t1
         INNER JOIN fact_business AS t2
                    ON t1.city_name = upper(t2.city)
WHERE population > 0
GROUP BY t2.city, t1.population;


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
       sum(t2.compliment_count) AS max_compliment_count
FROM fact_business AS t1
         INNER JOIN dim_tips AS t2
                    ON t1.business_id = t2.business_id
         INNER JOIN dim_city AS t3 ON upper(t1.city) = t3.city_name
WHERE t2.compliment_count IS NOT NULL
  AND t2.compliment_count > 0
  AND t3.population > 0
  AND t1.city IS NOT NULL
  AND length(t1.city) > 0
GROUP BY t3.city_id
ORDER BY max_compliment_count DESC;

-- Les states qui font en moyenne le plus de checkins
SELECT t1.state,
       AVG(t2.checkin_count) AS avg_checkin_count
FROM fact_business AS t1
         INNER JOIN dim_business AS t2
                    ON t1.business_id = t2.business_id
WHERE t2.checkin_count > 0
  AND t2.checkin_count IS NOT NULL
  AND t1.state IS NOT NULL
GROUP BY t1.state
ORDER BY avg_checkin_count DESC;


-- Les notes moyennes par ville
SELECT t1.city,
       AVG(t2.checkin_count) AS avg_checkin_count,
       AVG(t2.avg_stars)     AS avg_stars,
       COUNT(t1.business_id) AS count_business
FROM fact_business AS t1
         INNER JOIN dim_business AS t2
                    ON t1.business_id = t2.business_id
         INNER JOIN dim_city AS t3 ON upper(t1.city) = t3.city_name
WHERE t2.checkin_count > 0
  AND t2.checkin_count IS NOT NULL
  AND t3.population > 0
GROUP BY t1.city
ORDER BY avg_checkin_count DESC;


-- Les villes qui ont le plus de reviews
SELECT t2.city, count(t2.business_id) AS count_reviews
FROM dim_reviews AS t1
         INNER JOIN dim_business AS t2 ON t1.business_id = t2.business_id
         INNER JOIN dim_city AS t3 ON upper(t2.city) = t3.city_name
WHERE t3.population > 0
GROUP BY t2.city
ORDER BY count_reviews DESC;

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
                        GROUP BY h.hours),
     RankedHours AS (SELECT day_of_week,
                            common_hours,
                            frequency,
                            ROW_NUMBER() OVER (PARTITION BY day_of_week ORDER BY frequency DESC) AS rank
                     FROM HoursFrequency)
SELECT day_of_week,
       common_hours,
       frequency AS max_frequency
FROM RankedHours
WHERE rank = 1
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
WITH CategoryCount AS (SELECT t1.city,
                              t2.category,
                              COUNT(*) AS category_count
                       FROM fact_business AS t1
                                INNER JOIN dim_categories AS t2
                                           ON t1.category_id = t2.category_id
                                INNER JOIN dim_city AS t3
                                           ON upper(t1.city) = t3.city_name
                       WHERE t1.category_id IS NOT NULL
                         AND t2.category != 'Categorie'
                         AND length(t2.category) > 0
                         AND t3.population > 0
                       GROUP BY t1.city, t2.category)
   , MaxCategory AS (SELECT city,
                            category,
                            category_count,
                            ROW_NUMBER() OVER (PARTITION BY city ORDER BY category_count DESC) AS rn
                     FROM CategoryCount)
SELECT city,
       category,
       category_count
FROM MaxCategory
WHERE rn = 1
ORDER BY city;


-- Les attributs les plus communes à Las Vegas
SELECT t2.category,
       t2.category_id AS count_category
FROM fact_business AS t1
         INNER JOIN dim_categories AS t2
                    ON t1.category_id = t2.category_id
         INNER JOIN dim_city AS t3 ON upper(t1.city) = t3.city_name
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
         INNER JOIN dim_city AS t4 ON upper(t1.city) = t4.city_name
WHERE t2.category = 'Categorie'
  AND length(t1.value) > 0
  AND t4.population > 0
GROUP BY t4.city_id, t1.value
ORDER BY total_compliments DESC;

-- Les villes qui ont le plus de business avec l'attribut 'French'
SELECT t3.city,
       COUNT(t1.city) AS count_business
FROM fact_business AS t1
         INNER JOIN dim_categories AS t2
                    ON t1.category_id = t2.category_id
         INNER JOIN dim_business AS t3
                    ON t1.business_id = t3.business_id
         INNER JOIN dim_city AS t4 ON upper(t3.city) = t4.city_name
WHERE t2.category = 'Categorie'
  AND t1.value IS NOT NULL
  AND length(t1.value) > 0
  AND t1.value = 'French'
  AND t4.population > 0
GROUP BY t4.city_id
ORDER BY count_business DESC;

-- **************************
-- ANALYSE SUR LES DATES
-- **************************


-- La courbe de tendance de l'utilisation de l'application
WITH temp AS (SELECT date,
                     COUNT(checkin_id) AS source_checkin,
                     0                 AS count_tips,
                     0                 AS rewiew_count
              FROM dim_checkin
              WHERE date > '2014-01-01'

              GROUP BY date
              UNION ALL
              SELECT date,
                     0              AS source_checkin,
                     COUNT(tips_id) AS count_tips,
                     0              AS rewiew_count
              FROM dim_tips
              WHERE date > '2014-01-01'
              GROUP BY date
              UNION ALL
              SELECT date,
                     0                AS source_checkin,
                     0                AS rewiew_count,
                     COUNT(review_id) AS rewiew_count
              FROM dim_reviews
              WHERE date > '2014-01-01'
              GROUP BY date)
SELECT date,
       SUM(source_checkin + count_tips + rewiew_count) AS total
FROM temp
GROUP BY date
ORDER BY date;


-- Les jours de l'année avec le plus de checkins
SELECT strftime('%m-%d', date) AS month_day, COUNT(checkin_id) AS checkin_count
FROM dim_checkin
GROUP BY month_day;


-- Les jours de l'année avec le plus de reviews
SELECT to_char(date, 'MM-DD') AS month_day, COUNT(review_id) AS rewiew_count
FROM dim_reviews
GROUP BY month_day;


-- Les jours de l'année avec le plus de tips
SELECT strftime('%m-%d', date) AS month_day, COUNT(tips_id) AS checkin_count
FROM dim_tips
GROUP BY month_day
ORDER BY month_day;


-- Les jours de l'année avec le plus de checkins, reviews et tips
WITH temp AS (SELECT TO_CHAR(date, 'MM-DD') AS month_day,
                     COUNT(checkin_id)      AS source_checkin,
                     0                      AS count_tips,
                     0                      AS rewiew_count
              FROM dim_checkin
              GROUP BY month_day
              UNION ALL
              SELECT TO_CHAR(date, 'MM-DD') AS month_day,
                     0                      AS source_checkin,
                     COUNT(tips_id)         AS count_tips,
                     0                      AS rewiew_count
              FROM dim_tips
              GROUP BY month_day
              UNION ALL
              SELECT TO_CHAR(date, 'MM-DD') AS month_day,
                     0                      AS source_checkin,
                     0                      AS rewiew_count,
                     COUNT(review_id)       AS rewiew_count
              FROM dim_reviews
              GROUP BY month_day)
SELECT month_day,
       SUM(source_checkin) AS source_checkin,
       SUM(count_tips)     AS count_tips,
       SUM(rewiew_count)   AS rewiew_count
FROM temp
GROUP BY month_day
ORDER BY month_day;


-- Nombre de checkins total
SELECT count(checkin_id)
FROM dim_checkin;

-- Nombre de reviews total
SELECT count(review_id)
FROM dim_reviews;

-- Nombre de tips total
SELECT count(tips_id)
FROM dim_tips;


-- **************************
-- ANALYSE AVEC IA
-- **************************

-- Les business en general avec une analyse sentimentale
SELECT t2.name,
       COUNT(*) FILTER (WHERE sentiment = 'POSITIVE') AS positive_count,
       COUNT(*) FILTER (WHERE sentiment = 'NEGATIVE') AS negative_count,
       COUNT(*) FILTER (WHERE sentiment = 'NEUTRAL')  AS neutral_count
FROM dim_sentimental_analysis AS t1
         INNER JOIN dim_business AS t2
                    ON t1.business_id = t2.business_id
where t2.name IS NOT NULL
  AND length(t2.name) > 0
  AND t1.confidence > 0.5
GROUP BY t2.business_id, t2.name;

-- Vue pour les analyses sentimentales (meilleure performance)
CREATE MATERIALIZED VIEW vue_sentimental_analysis AS
SELECT t2.name,
       COUNT(*) FILTER (WHERE sentiment = 'POSITIVE') AS positive_count,
       COUNT(*) FILTER (WHERE sentiment = 'NEGATIVE') AS negative_count,
       COUNT(*) FILTER (WHERE sentiment = 'NEUTRAL')  AS neutral_count
FROM dim_sentimental_analysis AS t1
         INNER JOIN dim_business AS t2
                    ON t1.business_id = t2.business_id
where t2.name IS NOT NULL
  AND length(t2.name) > 0
  AND t1.confidence > 0.5
GROUP BY t2.business_id, t2.name;

SELECT *
FROM vue_sentimental_analysis;


-- **************************
-- AUTRES ANALYSES
-- **************************

-- Taille des tables sur Postgres
SELECT n.nspname || '.' || c.relname                 AS table_name,
       pg_size_pretty(pg_total_relation_size(c.oid)) AS size_pretty,
       pg_total_relation_size(c.oid) / 1024 / 1024   AS size_mb,
       t.row_count
FROM pg_class c
         JOIN
     pg_namespace n ON n.oid = c.relnamespace
         LEFT JOIN
     (SELECT relid,
             n_live_tup AS row_count
      FROM pg_stat_user_tables) t
     ON t.relid = c.oid
WHERE c.relkind = 'r'
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY size_mb DESC;


-- Taille de la base de données sur Postgres
SELECT pg_size_pretty(pg_database_size(current_database())) AS total_size,
       pg_database_size(current_database()) / 1024 / 1024   AS total_size_mb;


-- Taille des tables sur SQLite
SELECT table_size_bytes
FROM (SELECT name        AS table_name,
             SUM(pgsize) AS table_size_bytes
      FROM dbstat
      WHERE name IN
            ('dim_amenagement', 'dim_hours', 'dim_business', 'dim_city', 'dim_tips',
             'dim_checkin', 'dim_reviews', 'fact_business', 'dim_business_hours', 'dim_categories',
             'dim_sentimental_analysis'));