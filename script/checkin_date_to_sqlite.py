import json
import os
import sqlite3

if __name__ == '__main__':
    absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    file = os.path.join(absolute_path, "data/yelp_academic_dataset_checkin.json")
    db_path = os.path.join(absolute_path, "argon.db")

    conn = sqlite3.connect(db_path)
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

    with open(file, "r") as file:
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

    print("yelp_academic_dataset_checkin.json  inséré en base de données")
