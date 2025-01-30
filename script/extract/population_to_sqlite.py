import os
import sqlite3

import pandas as pd

if __name__ == '__main__':
    try:
        absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

        nom_fichier = "population.csv"
        file = os.path.join(absolute_path, "data", nom_fichier)

        if not os.path.exists(file):
            raise Exception(f"Le fichier {nom_fichier} est introuvable.")

        # compter le nombre de lignes dans le fichier
        with open(file) as f:
            num_lines = sum(1 for line in f)

        print(f"Le fichier contient {num_lines} lignes.")

        df = pd.read_csv(file, on_bad_lines='skip')

        num_lines_df = df.shape[0]
        print(f"Le DataFrame contient {num_lines_df} lignes.")
        print(f"Difference: {num_lines - num_lines_df} soit {num_lines_df * 100 / num_lines:.2f}%.")

        db_path = os.path.join(absolute_path, "argon.db")

        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        try:
            cursor.execute("""
            DROP TABLE IF EXISTS city;
            """)
            conn.commit()
        except Exception as e:
            print(e)

        cursor.execute("""
        CREATE TABLE city
        (
            city_id INTEGER PRIMARY KEY,
            city_name VARCHAR(100),
            population INTEGER,
            state VARCHAR(100)   
        )
        """)

        conn.commit()

        df.to_sql("city", conn, if_exists="replace", index=False)

        conn.close()

        print(f"{nom_fichier} a été importé avec succès en bd.")

    except Exception as e:
        print(e)
