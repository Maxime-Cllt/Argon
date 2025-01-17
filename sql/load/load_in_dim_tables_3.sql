-- Remplissage de la table dim_business
INSERT INTO dim_business (business_id, name, address, city, state, postal_code, review_count)
SELECT business_id,
       name,
       address,
       city,
       state,
       postal_code,
       review_count
FROM business;

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
      FROM business_hours) AS combined;


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
INSERT INTO dim_tips (user_id, business_id, compliment_count, text, date)
SELECT t1.user_id,
       t1.business_id,
       t1.compliment_count,
       t1.text,
       DATE(t1.date)
FROM tips AS t1;


-- Remplissage de la table dim_categories
INSERT INTO dim_categories (category)
SELECT key
FROM business_attributes
GROUP BY key;

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