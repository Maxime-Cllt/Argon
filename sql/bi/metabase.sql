SELECT t1.name,
       AVG(t2.compliment_count) AS avg_compliment_count,
       t1.city
FROM dim_business AS t1
         INNER JOIN dim_tips AS t2
                    ON t1.business_id = t2.business_id
GROUP BY t1.business_id
ORDER BY avg_compliment_count DESC
LIMIT 100;


SELECT city, COUNT(fact_business_id) AS cout_business
FROM fact_business
GROUP BY city
ORDER BY cout_business DESC
LIMIT 20;