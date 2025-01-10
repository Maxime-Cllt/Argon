-- Remplissage des dimensions
INSERT INTO dim_business (business_id, name, address, city, state, postal_code, latitude, longitude, review_count,
                          is_open)
SELECT business_id,
       name,
       address,
       city,
       state,
       postal_code,
       latitude,
       longitude,
       review_count,
       is_open
FROM business;

INSERT INTO dim_date (date)
SELECT DISTINCT date
FROM checkin_date;

INSERT INTO dim_category (category)
SELECT DISTINCT category
FROM business_categories;

-- INSERT INTO dim_user (user_id, name)
-- SELECT user_id,
--        name
-- FROM users;

INSERT INTO dim_business_hours (business_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday)
SELECT business_id,
       monday,
       tuesday,
       wednesday,
       thursday,
       friday,
       saturday,
       sunday
FROM business_hours;

INSERT INTO dim_parking (business_id, garage, street, validated, lot, valet)
SELECT business_id,
       garage,
       street,
       validated,
       lot,
       valet
FROM business_parking;

-- Remplissage de la table de faits centralisée fact_business

-- Insertion des checkins
-- INSERT INTO fact_business (fact_type, business_id, date_id)
-- SELECT 'checkin' AS fact_type,
--        business_id,
--        (SELECT date_id FROM dim_date WHERE date = checkin_date.date) AS date_id
-- FROM checkin_date
-- GROUP BY business_id, checkin_date.date;

-- Insertion des tips
INSERT INTO fact_business (fact_type, business_id, user_id, compliment_count, text, date_id)
SELECT 'tip'                                                 AS fact_type,
       business_id,
       user_id,
       CAST(compliment_count AS INTEGER),
       text,
       (SELECT date_id FROM dim_date WHERE date = tips.date) AS date_id
FROM tips
LIMIT 1000;

-- Insertion des catégories
INSERT INTO fact_business (fact_type, business_id, category_id)
SELECT 'category' AS fact_type,
       business_id,
       category_id
FROM business_categories AS t1
         INNER JOIN dim_category AS t2
                    ON t1.category = t2.category
LIMIT 1000;

-- Insertion des attributs
INSERT INTO fact_business (fact_type, business_id, key, value)
SELECT 'attribute' AS fact_type,
       business_id,
       key,
       value
FROM business_attributes
LIMIT 1000;
