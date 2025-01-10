DROP TABLE IF EXISTS dim_business;
DROP TABLE IF EXISTS dim_user;
DROP TABLE IF EXISTS dim_category;
DROP TABLE IF EXISTS dim_business_attributes;
DROP TABLE IF EXISTS dim_business_hours;
DROP TABLE IF EXISTS dim_parking;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS fact_checkin;
DROP TABLE IF EXISTS fact_tips;
DROP TABLE IF EXISTS fact_category;
DROP TABLE IF EXISTS fact_attribute;


CREATE TABLE dim_business
(
    business_id  VARCHAR(22) PRIMARY KEY,
    name         VARCHAR(64),
    address      VARCHAR(118),
    city         VARCHAR(43),
    state        VARCHAR(3),
    postal_code  VARCHAR(8),
    latitude     REAL,
    longitude    REAL,
    review_count INTEGER,
    is_open      INTEGER
);

CREATE TABLE dim_date
(
    date_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date    DATE
);

CREATE TABLE dim_category
(
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category    VARCHAR(35)
);

CREATE TABLE dim_business_hours
(
    business_id VARCHAR(22),
    monday      VARCHAR(20),
    tuesday     VARCHAR(20),
    wednesday   VARCHAR(20),
    thursday    VARCHAR(20),
    friday      VARCHAR(20),
    saturday    VARCHAR(20),
    sunday      VARCHAR(20),
    PRIMARY KEY (business_id)
);

CREATE TABLE dim_parking
(
    business_id VARCHAR(22) PRIMARY KEY,
    garage      INTEGER,
    street      INTEGER,
    validated   INTEGER,
    lot         INTEGER,
    valet       INTEGER
);

CREATE TABLE dim_business_attributes
(
    business_id VARCHAR(22),
    key         VARCHAR(255),
    value       VARCHAR(255),
    PRIMARY KEY (business_id, key)
);

CREATE TABLE dim_user
(
    user_id VARCHAR(22) PRIMARY KEY,
    name    VARCHAR(64)
);


-- CREATE TABLE fact_checkin
-- (
--     checkin_id    INTEGER PRIMARY KEY AUTOINCREMENT,
--     business_id   VARCHAR(22),
--     date_id       INTEGER,
--     FOREIGN KEY (business_id) REFERENCES dim_business (business_id),
--     FOREIGN KEY (date_id) REFERENCES dim_date (date_id)
-- );

CREATE TABLE fact_tips
(
    tip_id           INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id      VARCHAR(22),
    user_id          VARCHAR(255),
    compliment_count INTEGER,
    tip_date         DATE,
    text             TEXT,
    FOREIGN KEY (business_id) REFERENCES dim_business (business_id),
    FOREIGN KEY (user_id) REFERENCES dim_user (user_id)
);

CREATE TABLE fact_category
(
    business_id VARCHAR(22),
    category_id INTEGER,
    FOREIGN KEY (business_id) REFERENCES dim_business (business_id),
    FOREIGN KEY (category_id) REFERENCES dim_category (category_id)
);

CREATE TABLE fact_attribute
(
    business_id VARCHAR(22),
    key         VARCHAR(255),
    value       VARCHAR(255),
    PRIMARY KEY (business_id, key),
    FOREIGN KEY (business_id) REFERENCES dim_business (business_id)
);