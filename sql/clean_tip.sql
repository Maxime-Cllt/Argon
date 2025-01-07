-- Suppression où le business_id n'est pas un id valide
DELETE
FROM tip
WHERE length(business_id) != 22;

-- Suppression où le user_id n'est pas un id valide
DELETE
FROM tip
WHERE length(user_id) != 22;

-- Suppression où le compliment_count n'est pas un nombre
DELETE
FROM tip
WHERE compliment_count GLOB '*[^0-9]*';

-- Suppression où la date n'est pas au format YYYY-MM-DD HH:MM:SS
DELETE
FROM tip
WHERE length(date) != 19;

SELECT COUNT(*)
FROM tip;