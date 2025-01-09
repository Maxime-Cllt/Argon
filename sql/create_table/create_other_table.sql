-- A EXECUTER APRES LES AUTRES SCRIPTS DE CLEAN

-- Fusion de la table business_hours avec la table attributes
INSERT INTO attributes (business_id, key, value)
SELECT business_id, 'Categorie', category
FROM business_categories;

DROP TABLE business_categories;


-- Fusion de la table checkin_date avec la table attributes
INSERT INTO attributes (business_id, key, value)
SELECT business_id, 'Checkin', date
FROM checkin_date;

DROP TABLE checkin_date;

-- Création de la table commerces (table de faits)
DROP TABLE IF EXISTS commerces;
CREATE TABLE commerces
(
    business_id VARCHAR(22) PRIMARY KEY,
    review_id   INTEGER,
    checkin_id  INTEGER,
    parking_id  INTEGER,
    category_id INTEGER,
    attribut_id INTEGER,
    tips_id     INTEGER
);