-- Création de la table des categories
DROP TABLE IF EXISTS categories;
CREATE TABLE categories
(
    id_category INTEGER PRIMARY KEY AUTOINCREMENT,
    category    VARCHAR(200) DEFAULT ''
);


-- Insertion des données dans la table des categories
INSERT INTO categories (category);
SELECT DISTINCT category
FROM business_categories;