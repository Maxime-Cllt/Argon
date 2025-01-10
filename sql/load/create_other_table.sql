-- A EXECUTER APRES LES AUTRES SCRIPTS DE CLEAN


-- Création de la table attributes avec les clés uniques
DROP TABLE IF EXISTS attributes;
CREATE TABLE attributes
(
    id_attribut INTEGER PRIMARY KEY AUTOINCREMENT,
    key         VARCHAR(255)
);

INSERT INTO attributes (key)
SELECT DISTINCT key
FROM business_attributes;


-- Fusion de la table business_hours avec la table business_attributes
INSERT INTO business_attributes (business_id, key, value)
SELECT business_id, 'Categorie', category
FROM business_categories;

DROP TABLE business_categories;


-- Fusion de la table checkin_date avec la table business_attributes
INSERT INTO business_attributes (business_id, key, value)
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

-- INSERT INTO commerces (business_id, review_id, checkin_id, parking_id, category_id, attribut_id, tips_id)
-- SELECT business_id, review_id, checkin_id, parking_id, category_id, attribut_id, tips_id
-- FROM business
--          JOIN checkin_date USING (business_id)
--          JOIN business_parking USING (business_id)
--          JOIN business_categories USING (business_id)
--          JOIN business_attributes USING (business_id)
--          JOIN tips USING (business_id);