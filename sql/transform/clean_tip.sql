SELECT COUNT(*)
FROM tips;

-- Suppression où le business_id  et user_id ne sont pas de longueur 22 ou contiennent un espace
DELETE
FROM tips
WHERE length(business_id) != 22
   OR business_id GLOB '* *'
   OR length(user_id) != 22
   OR user_id GLOB '* *'
   OR user_id IS NULL
   OR business_id IS NULL;

-- Suppression où le compliment_count n'est pas un nombre
DELETE
FROM tips
WHERE compliment_count GLOB '*[^0-9]*'
   OR compliment_count IS NULL;

-- Suppression où la date n'est pas au format YYYY-MM-DD HH:MM:SS
DELETE
FROM tips
WHERE length(date) != 19
   OR date NOT GLOB '????-??-?? ??:??:??'
   OR date IS NULL;

SELECT COUNT(*)
FROM tips;