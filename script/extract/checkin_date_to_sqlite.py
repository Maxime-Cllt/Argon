import json
import os
import sqlite3

if __name__ == '__main__':
    try:
        absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        nom_fichier = "yelp_academic_dataset_checkin.json"
        file = os.path.join(absolute_path, "data", nom_fichier)
        db_path = os.path.join(absolute_path, "argon.db")

        if not os.path.exists(file):
            raise Exception(f"Le fichier {nom_fichier} est introuvable.")

        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        try:
            cursor.execute("""
                DROP TABLE IF EXISTS checkin_date
                """)
            conn.commit()
        except Exception as e:
            print(e)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS checkin_date (
                business_id VARCHAR(22),
                date DATETIME,
                FOREIGN KEY (business_id) REFERENCES business (business_id)
            )
            """)

        conn.commit()

        prepared_statement = """
            INSERT INTO checkin_date (business_id, date)
            VALUES (?, ?)
            """

        with open(file, "r") as file:
            for line in file:
                data = json.loads(line.strip())
                business_id = data.get("business_id")
                dates = data.get("date", "").split(", ")

                for date in dates:
                    cursor.execute(prepared_statement, (business_id, date))

        conn.commit()
        conn.close()

        print("yelp_academic_dataset_checkin.json  inséré en base de données")

    except Exception as e:
        print(e)
