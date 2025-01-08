import json
import sqlite3

# Nom du fichier JSON
file_name = "../data/yelp_academic_dataset_checkin.json"

conn = sqlite3.connect("../argon.db")
cursor = conn.cursor()

cursor.execute("""
DROP TABLE IF EXISTS checkin_date
""")


cursor.execute("""
CREATE TABLE IF NOT EXISTS checkin_date (
    business_id VARCHAR(22),
    date DATETIME,
    FOREIGN KEY (business_id) REFERENCES business (business_id)
)
""")

conn.commit()

with open(file_name, "r") as file:
    for line in file:
        data = json.loads(line.strip())
        business_id = data.get("business_id")
        dates = data.get("date", "").split(", ")

        for date in dates:
            cursor.execute("""
            INSERT INTO checkin_date (business_id, date)
            VALUES (?, ?)
            """, (business_id, date))

conn.commit()
conn.close()

print("Données insérées avec succès dans la base SQLite3.")
