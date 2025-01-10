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
SELECT date
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

INSERT INTO dim_business_attributes (business_id, key, value)
SELECT business_id,
       key,
       value
FROM business_attributes;


-- INSERT INTO fact_checkin (business_id, date_id)
-- SELECT business_id,
--        (SELECT date_id FROM dim_date WHERE date = checkin_date.date) AS date_id
-- FROM checkin_date
-- GROUP BY business_id, checkin_date.date
-- LIMIT 100;

INSERT INTO fact_tips (business_id, user_id, compliment_count, tip_date, text)
SELECT business_id,
       user_id,
       CAST(compliment_count AS INTEGER),
       date,
       text
FROM tips;

INSERT INTO fact_category (business_id, category_id)
SELECT business_id, category_id
FROM business_categories AS t1
         INNER JOIN dim_category AS t2
                    ON t1.category = t2.category;

INSERT INTO fact_attribute (business_id, key, value)
SELECT business_id,
       key,
       value
FROM business_attributes;


-- example of query that uses multiple fact tables
-- SELECT dim_business.business_id,
--        t2.user_id,
--        t2.text,
--        t2.tip_date
-- FROM fact_tips
--          INNER JOIN dim_business ON fact_tips.business_id = dim_business.business_id
--          LEFT JOIN fact_tips AS t2 ON fact_tips.business_id = t2.business_id
-- LIMIT 100;