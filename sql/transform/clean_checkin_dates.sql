-- Suppression des lignes de checkin_date qui ne sont pas liées à un business
DELETE
FROM checkin_date
WHERE length(business_id) != 22;

-- Suppression des lignes où la date n'est pas au format YYYY-MM-DD HH:MM:SS
DELETE
FROM checkin_date
WHERE length(date) != 19;
