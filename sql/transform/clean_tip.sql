SELECT COUNT(*)
FROM tips;

-- Suppression où le business_id  et user_id ne sont pas de longueur 22 ou contiennent un espace
DELETE
FROM tips
WHERE length(business_id) != 22
   OR business_id GLOB '* *'
   OR length(user_id) != 22
   OR user_id GLOB '* *';

-- Suppression où le compliment_count n'est pas un nombre
DELETE
FROM tips
WHERE compliment_count GLOB '*[^0-9]*';

-- Suppression où la date n'est pas au format YYYY-MM-DD HH:MM:SS
DELETE
FROM tips
WHERE length(date) != 19
   OR date NOT GLOB '????-??-?? ??:??:??';;

SELECT COUNT(*)
FROM tips;