DROP TABLE IF EXISTS dim_business CASCADE;
DROP TABLE IF EXISTS dim_business_attributes CASCADE;
DROP TABLE IF EXISTS dim_business_hours CASCADE;
DROP TABLE IF EXISTS dim_amenagement CASCADE;
DROP TABLE IF EXISTS dim_tips CASCADE;
DROP TABLE IF EXISTS dim_attributs CASCADE;
DROP TABLE IF EXISTS dim_categories CASCADE;
DROP TABLE IF EXISTS dim_hours CASCADE;
DROP TABLE IF EXISTS dim_checkin CASCADE;
DROP TABLE IF EXISTS dim_city CASCADE;
DROP TABLE IF EXISTS fact_business CASCADE;

-- Create the dim_business table
CREATE TABLE dim_business
(
    business_id   VARCHAR(22) PRIMARY KEY,
    name          VARCHAR(64)  DEFAULT NULL,
    address       VARCHAR(118) DEFAULT NULL,
    city          VARCHAR(43)  DEFAULT NULL,
    state         VARCHAR(3)   DEFAULT NULL,
    postal_code   VARCHAR(8)   DEFAULT NULL,
    review_count  INTEGER      DEFAULT NULL,
    checkin_count INTEGER      DEFAULT NULL
);

-- Create the dim_hours table
CREATE TABLE dim_hours
(
    id_hours SERIAL PRIMARY KEY,
    hours    VARCHAR(20) NOT NULL
);

-- Create the dim_business_hours table
CREATE TABLE dim_business_hours
(
    business_id        VARCHAR(22) PRIMARY KEY,
    id_hours_monday    INTEGER REFERENCES dim_hours (id_hours),
    id_hours_tuesday   INTEGER REFERENCES dim_hours (id_hours),
    id_hours_wednesday INTEGER REFERENCES dim_hours (id_hours),
    id_hours_thursday  INTEGER REFERENCES dim_hours (id_hours),
    id_hours_friday    INTEGER REFERENCES dim_hours (id_hours),
    id_hours_saturday  INTEGER REFERENCES dim_hours (id_hours),
    id_hours_sunday    INTEGER REFERENCES dim_hours (id_hours),
    CONSTRAINT fk_business FOREIGN KEY (business_id) REFERENCES dim_business (business_id)
);

-- Create the dim_amenagement table
CREATE TABLE dim_amenagement
(
    business_id VARCHAR(22) PRIMARY KEY,
    garage    int2 DEFAULT NULL,
    street    int2 DEFAULT NULL,
    validated int2 DEFAULT NULL,
    lot       int2 DEFAULT NULL,
    valet     int2 DEFAULT NULL,
    CONSTRAINT fk_amenagement_business FOREIGN KEY (business_id) REFERENCES dim_business (business_id)
);

-- Create the dim_tips table
CREATE TABLE dim_tips
(
    tips_id          SERIAL PRIMARY KEY,
    user_id          VARCHAR(22) NOT NULL,
    business_id      VARCHAR(22) NOT NULL,
    compliment_count INTEGER   DEFAULT NULL,
    text             TEXT      DEFAULT NULL,
    date             TIMESTAMP DEFAULT NULL,
    CONSTRAINT fk_tips_business FOREIGN KEY (business_id) REFERENCES dim_business (business_id)
);

-- Create the dim_categories table
CREATE TABLE dim_categories
(
    category_id SERIAL PRIMARY KEY,
    category    VARCHAR(64) NOT NULL
);

CREATE TABLE dim_checkin
(
    checkin_id  SERIAL PRIMARY KEY,
    business_id VARCHAR(22) NOT NULL,
    date TIMESTAMP NOT NULL,
    FOREIGN KEY (business_id) REFERENCES dim_business (business_id)
);


-- Create the dim_attributs table
CREATE TABLE dim_city
(
    city_id    SERIAL PRIMARY KEY,
    city_name  VARCHAR(32),
    population INTEGER,
    state      VARCHAR(2)
);


-- Create the fact_business table
CREATE TABLE fact_business
(
    fact_business_id SERIAL PRIMARY KEY,
    business_id      VARCHAR(22) NOT NULL,
    category_id      INTEGER REFERENCES dim_categories (category_id),
    review_count     INTEGER     DEFAULT NULL,
    city             VARCHAR(43) DEFAULT NULL,
    postal_code      VARCHAR(8)  DEFAULT NULL,
    state            VARCHAR(3)  DEFAULT NULL,
    value            VARCHAR     DEFAULT NULL,
    CONSTRAINT fk_fact_business FOREIGN KEY (business_id) REFERENCES dim_business (business_id),
    CONSTRAINT fk_fact_category FOREIGN KEY (category_id) REFERENCES dim_categories (category_id)
);
