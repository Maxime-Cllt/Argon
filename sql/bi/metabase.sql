SELECT t1.name,
       AVG(t2.compliment_count) AS avg_compliment_count,
       t1.city
FROM dim_business AS t1
         INNER JOIN dim_tips AS t2
                    ON t1.business_id = t2.business_id
GROUP BY t1.business_id
ORDER BY avg_compliment_count DESC
LIMIT 100;

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