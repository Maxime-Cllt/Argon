-- Suppression des lignes de checkin_date qui ne sont pas liées à un business
DELETE
FROM checkin_date
WHERE length(business_id) != 22
   OR business_id GLOB '* *'
   OR business_id IS NULL;

-- Suppression des lignes où la date n'est pas au format YYYY-MM-DD HH:MM:SS
DELETE
FROM checkin_date
WHERE length(date) != 19
   OR date NOT GLOB '????-??-?? ??:??:??'
   OR date IS NULL;
