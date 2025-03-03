-- Remplissage de la table dim_business
PRAGMA temp_store = MEMORY;

-- Remplissage de la table dim_checkin
INSERT INTO dim_checkin (business_id, date)
SELECT t1.business_id,
       date(t1.date)
FROM checkin_date AS t1;

-- Remplissage de la table dim_business
INSERT INTO dim_business (business_id,
                          name,
                          address,
                          city,
                          state,
                          postal_code,
                          review_count, latitude, longitude)
SELECT b.business_id,
       b.name,
       b.address,
       b.city,
       b.state,
       b.postal_code,
       b.review_count,
       b.latitude,
       b.longitude
FROM business b;

UPDATE dim_business
SET checkin_count = cc.checkin_count
FROM (SELECT business_id,
             COUNT(date) AS checkin_count
      FROM dim_checkin
      GROUP BY business_id) cc
WHERE dim_business.business_id = cc.business_id;


-- Remplissage de la table dim_hours
INSERT INTO dim_hours (hours)
SELECT DISTINCT time_range AS all_dates
FROM (SELECT monday AS time_range
      FROM business_hours
      UNION
      SELECT tuesday
      FROM business_hours
      UNION
      SELECT wednesday
      FROM business_hours
      UNION
      SELECT thursday
      FROM business_hours
      UNION
      SELECT friday
      FROM business_hours)
WHERE all_dates IS NOT NULL
  AND all_dates <> '';


-- Remplissage de la table dim_business_hours
INSERT INTO dim_business_hours (business_id, id_hours_monday, id_hours_tuesday, id_hours_wednesday, id_hours_thursday,
                                id_hours_friday, id_hours_saturday, id_hours_sunday)
SELECT bh.business_id,
       dh_monday.id_hours    AS id_hours_monday,
       dh_tuesday.id_hours   AS id_hours_tuesday,
       dh_wednesday.id_hours AS id_hours_wednesday,
       dh_thursday.id_hours  AS id_hours_thursday,
       dh_friday.id_hours    AS id_hours_friday,
       dh_saturday.id_hours  AS id_hours_saturday,
       dh_sunday.id_hours    AS id_hours_sunday
FROM business_hours bh
         LEFT JOIN dim_hours dh_monday ON bh.monday = dh_monday.hours
         LEFT JOIN dim_hours dh_tuesday ON bh.tuesday = dh_tuesday.hours
         LEFT JOIN dim_hours dh_wednesday ON bh.wednesday = dh_wednesday.hours
         LEFT JOIN dim_hours dh_thursday ON bh.thursday = dh_thursday.hours
         LEFT JOIN dim_hours dh_friday ON bh.friday = dh_friday.hours
         LEFT JOIN dim_hours dh_saturday ON bh.saturday = dh_saturday.hours
         LEFT JOIN dim_hours dh_sunday ON bh.sunday = dh_sunday.hours;

-- Remplissage de la table dim_amenagement
INSERT INTO dim_amenagement (business_id, garage, street, validated, lot, valet)
SELECT business_id,
       garage,
       street,
       validated,
       lot,
       valet
FROM business_parking;

-- Remplissage de la table dim_tips
INSERT INTO dim_tips (business_id, compliment_count, text, date)
SELECT t1.business_id,
       t1.compliment_count,
       t1.text,
       DATE(t1.date)
FROM tips AS t1;


-- Remplissage de la table dim_categories
INSERT INTO dim_categories (category)
SELECT key
FROM business_attributes
GROUP BY key;

-- Remplissage de la table dim_city
INSERT INTO dim_city (city_name, population, state)
SELECT upper(city_name) AS city_name
     , population
     , state
FROM city
GROUP BY population
ORDER BY city_name;

-- Remplissage de la table dim_reviews
INSERT INTO dim_reviews (business_id, stars, date)
SELECT business_id,
       stars,
       DATE(date)
FROM reviews;

-- Remplissage de la table dim_sentimental_analysis
INSERT INTO dim_sentimental_analysis (business_id, sentiment, confidence)
SELECT business_id,
       sentiment,
       confidence
FROM review_sentiment;

INSERT INTO dim_sentimental_analysis (business_id, sentiment, confidence)
SELECT business_id,
       sentiment,
       confidence
FROM tips_sentiment;

-- Remplissage de la table fact_business
INSERT INTO fact_business (business_id, category_id, review_count, city, postal_code, state, value)
SELECT t1.business_id,
       t3.category_id,
       t1.review_count,
       t1.city,
       t1.postal_code,
       t1.state,
       t2.value
FROM business AS t1
         INNER JOIN business_attributes AS t2 ON t1.business_id = t2.business_id
         LEFT JOIN dim_categories AS t3 ON t2.key = t3.category;