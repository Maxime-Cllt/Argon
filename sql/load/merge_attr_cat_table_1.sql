-- A EXECUTER APRES LES AUTRES SCRIPTS DE CLEAN


-- Fusion de la table business_categories avec la table business_attributes
INSERT INTO business_attributes (business_id, key, value)
SELECT business_id, 'Categorie', category
FROM business_categories;
DROP TABLE business_categories;