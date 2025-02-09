PRAGMA temp_store = MEMORY;
DROP TABLE IF EXISTS dim_business;
DROP TABLE IF EXISTS dim_business_attributes;
DROP TABLE IF EXISTS dim_business_hours;
DROP TABLE IF EXISTS dim_amenagement;
DROP TABLE IF EXISTS dim_tips;
DROP TABLE IF EXISTS dim_attributs;
DROP TABLE IF EXISTS dim_city;
DROP TABLE IF EXISTS dim_categories;
DROP TABLE IF EXISTS dim_hours;
DROP TABLE IF EXISTS dim_checkin;
DROP TABLE IF EXISTS dim_reviews;
DROP TABLE IF EXISTS fact_business;

CREATE TABLE dim_business
(
    business_id   VARCHAR(22) PRIMARY KEY,
    name          VARCHAR(64)  DEFAULT NULL,
    address       VARCHAR(118) DEFAULT NULL,
    city          VARCHAR(43)  DEFAULT NULL,
    state         VARCHAR(3)   DEFAULT NULL,
    postal_code   VARCHAR(8)   DEFAULT NULL,
    review_count  INTEGER      DEFAULT NULL,
    checkin_count INTEGER DEFAULT NULL,
    avg_stars     FLOAT   DEFAULT NULL,
    latitude      FLOAT   DEFAULT NULL,
    longitude     FLOAT   DEFAULT NULL
);

CREATE TABLE dim_reviews
(
    review_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id VARCHAR(22) NOT NULL,
    date        DATE    DEFAULT NULL,
    stars       INTEGER DEFAULT NULL
);

CREATE TABLE dim_hours
(
    id_hours INTEGER PRIMARY KEY AUTOINCREMENT,
    hours    VARCHAR(20) DEFAULT NULL
);

CREATE TABLE dim_business_hours
(
    business_id        VARCHAR(22) PRIMARY KEY NOT NULL,
    id_hours_monday    INTEGER DEFAULT NULL,
    id_hours_tuesday   INTEGER DEFAULT NULL,
    id_hours_wednesday INTEGER DEFAULT NULL,
    id_hours_thursday  INTEGER DEFAULT NULL,
    id_hours_friday    INTEGER DEFAULT NULL,
    id_hours_saturday  INTEGER DEFAULT NULL,
    id_hours_sunday    INTEGER DEFAULT NULL,
    FOREIGN KEY (business_id) REFERENCES dim_business (business_id),
    FOREIGN KEY (id_hours_monday) REFERENCES dim_hours (id_hours),
    FOREIGN KEY (id_hours_tuesday) REFERENCES dim_hours (id_hours),
    FOREIGN KEY (id_hours_wednesday) REFERENCES dim_hours (id_hours),
    FOREIGN KEY (id_hours_thursday) REFERENCES dim_hours (id_hours),
    FOREIGN KEY (id_hours_friday) REFERENCES dim_hours (id_hours),
    FOREIGN KEY (id_hours_saturday) REFERENCES dim_hours (id_hours),
    FOREIGN KEY (id_hours_sunday) REFERENCES dim_hours (id_hours)
);

CREATE TABLE dim_amenagement
(
    business_id VARCHAR(22) PRIMARY KEY NOT NULL,
    garage      INTEGER DEFAULT NULL,
    street      INTEGER DEFAULT NULL,
    validated   INTEGER DEFAULT NULL,
    lot         INTEGER DEFAULT NULL,
    valet       INTEGER DEFAULT NULL,
    FOREIGN KEY (business_id) REFERENCES dim_business (business_id)
);

CREATE TABLE dim_tips
(
    tips_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id      VARCHAR(22) NOT NULL,
    compliment_count INTEGER  DEFAULT NULL,
    text             TEXT     DEFAULT NULL,
    date             DATETIME DEFAULT NULL,
    FOREIGN KEY (business_id) REFERENCES dim_business (business_id)
);

CREATE TABLE dim_categories
(
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category    VARCHAR(64) NOT NULL
);

CREATE TABLE dim_checkin
(
    checkin_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id VARCHAR(22) NOT NULL,
    date        DATETIME    NOT NULL,
    FOREIGN KEY (business_id) REFERENCES dim_business (business_id)
);

CREATE TABLE dim_city
(
    city_id INTEGER PRIMARY KEY AUTOINCREMENT,
    city_name  VARCHAR(32),
    population INTEGER,
    state      VARCHAR(2)
);

CREATE TABLE dim_sentimental_analysis
(
    sentimental_analysis_id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id             VARCHAR(22) NOT NULL,
    sentiment               VARCHAR(10) DEFAULT NULL,
    confidence              FLOAT       DEFAULT NULL,
    FOREIGN KEY (business_id) REFERENCES dim_business (business_id)
);

CREATE TABLE fact_business
(
    fact_business_id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id      VARCHAR(22) NOT NULL,      -- Clé étrangère vers dim_business
    category_id      INTEGER      DEFAULT NULL, -- Clé étrangère pour le lien avec une catégorie
    review_count     INTEGER      DEFAULT NULL, -- Nombre d'avis
    city             VARCHAR(43)  DEFAULT NULL, -- Ville
    postal_code      VARCHAR(8)   DEFAULT NULL, -- Code postal
    state            VARCHAR(3)   DEFAULT NULL, -- Etat
    value            VARCHAR(170) DEFAULT NULL, -- Valeur associée au fait
    FOREIGN KEY (business_id) REFERENCES dim_business (business_id),
    FOREIGN KEY (category_id) REFERENCES dim_categories (category_id)
);