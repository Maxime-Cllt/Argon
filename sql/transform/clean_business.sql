-- Suppression des business_id non conformes
DELETE
FROM business
WHERE length(business_id) != 22
   OR business_id GLOB '* *'
   OR business_id IS NULL;

UPDATE business
SET name = TRIM(name)
WHERE name GLOB '* '
   OR name GLOB ' *';

UPDATE business
SET city = TRIM(city)
WHERE city GLOB '* '
   OR city GLOB ' *';

DELETE
FROM business_attributes
WHERE length(business_id) != 22
   OR business_id GLOB '* *'
   OR business_id IS NULL;


DELETE
FROM business_hours
WHERE length(business_id) != 22
   OR business_id GLOB '* *'
   OR business_id IS NULL;


DELETE
FROM business_parking
WHERE length(business_id) != 22
   OR business_id GLOB '* *'
   OR business_id IS NULL;

DELETE
FROM business_categories
WHERE length(business_id) != 22
   OR business_id GLOB '* *'
   OR business_id IS NULL;