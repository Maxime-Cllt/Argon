import os
import sqlite3

import pandas as pd

if __name__ == '__main__':
    try:
        absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

        file = os.path.join(absolute_path, "data/yelp_academic_dataset_tip.csv")

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

        cursor.execute("""
        DROP TABLE IF EXISTS tips
        """)

        conn.commit()

        cursor.execute("""
        CREATE TABLE tips (
            business_id  TEXT,
            compliment_count INTEGER,
            date TEXT,
            text TEXT,
            user_id TEXT,
            FOREIGN KEY (business_id) REFERENCES business (business_id)
        )
        """)

        conn.commit()

        df.to_sql("tips", conn, if_exists="replace", index=False)

        conn.close()
        cursor.close()

        print("yelp_academic_dataset_tip.csv inséré en base de données")
    except Exception as e:

        if conn is not None:
            conn.close()

        if cursor is not None:
            cursor.close()

        print(e)
        raise e
