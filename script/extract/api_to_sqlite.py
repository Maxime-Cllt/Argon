import os
import sqlite3

import pandas as pd
import requests

if __name__ == '__main__':

    absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    db_path = os.path.join(absolute_path, "argon.db")
    conn = sqlite3.connect(db_path)

    cities = pd.read_sql_query(f"""SELECT trim(city) as city
                                        FROM business
                                        WHERE city NOT IN (SELECT city_name FROM city WHERE city_name IS NOT NULL OR city_name != '')
                                          AND city IS NOT NULL
                                          AND city != ''
                                        GROUP BY city""", conn)["city"].tolist()

    cities = [x for x in cities if x != '']

    print(f"Nombre de villes : {len(cities)}")

    username = "m2bdia"

    data = {}

    prepared_insert = "INSERT INTO city (city_name, population, country) VALUES (?, ?, ?)"

    for city in cities:
        try:
            url = f"http://api.geonames.org/search?q={city}&maxRows=1&type=json&username={username}"
            url = requests.utils.requote_uri(url)

            response = requests.get(url, verify=False).json()

            if len(response["geonames"]) == 0:
                print(f"Pas de résultat pour la ville {city} : {response}")
                continue

            data[city] = (response["geonames"][0]["population"], response["geonames"][0]["countryCode"])
            print(f"La population de {city} est de {data[city]} habitants")
        except Exception as e:
            print(f"Erreur pour la ville {city} : {e}")

    # insert data
    for city, population in data.items():
        conn.execute(prepared_insert, (city, population[0], population[1]))

    conn.commit()
    conn.close()
