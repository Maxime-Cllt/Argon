UPDATE city
SET city_name = TRIM(city_name)
WHERE city_name GLOB '* '
   OR city_name GLOB ' *';