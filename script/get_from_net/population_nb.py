import requests
import sqlite3
import os
from dotenv import load_dotenv
import pandas as pd

file_path = "../../argon.db"

conn = sqlite3.connect(file_path)

cities = pd.read_sql_query("SELECT city FROM business group by city", conn)["city"].tolist()

cities = [x for x in cities if x != '']

print(f"Les villes sont : {cities}")
print(f"Nombre de villes : {len(cities)}")

load_dotenv()

username = os.getenv("GEONAMES_USERNAME")

data = {}

# 100 cities
for city in cities:
    response = requests.get(
        f"http://api.geonames.org/search?q={city}&maxRows=1&type=json&username={username}", verify=False
    ).json()
    try:
        data[city] = (response["geonames"][0]["population"], response["geonames"][0]["countryCode"])
        print(f"La population de {city} est de {data[city]} habitants")
    except Exception  as e:
        print(f"Erreur pour la ville {city} : {e}")

# create table
conn.execute("DROP TABLE IF EXISTS population")
conn.execute("CREATE TABLE population (city TEXT, population INTEGER, country_code TEXT)")

# insert data
for city, population in data.items():
    conn.execute("INSERT INTO population (city, population, country_code) VALUES (?, ?, ?)",
                 (city, population[0], population[1]))

conn.commit()
conn.close()
