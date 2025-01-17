import os
import sqlite3

import pandas as pd

if __name__ == '__main__':
    try:
        absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

        file = os.path.join(absolute_path, "data/user.csv")

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
        DROP TABLE IF EXISTS dim_users
        """)

        conn.commit()

        cursor.execute("""
        CREATE TABLE dim_users
        (
            average_stars      FLOAT       DEFAULT NULL,
            compliment_cool    INTEGER     DEFAULT NULL,
            compliment_cute    INTEGER     DEFAULT NULL,
            compliment_funny   INTEGER     DEFAULT NULL,
            compliment_hot     INTEGER     DEFAULT NULL,
            compliment_list    INTEGER     DEFAULT NULL,
            compliment_more    INTEGER     DEFAULT NULL,
            compliment_note    INTEGER     DEFAULT NULL,
            compliment_photos  INTEGER     DEFAULT NULL,
            compliment_plain   INTEGER     DEFAULT NULL,
            compliment_profile INTEGER     DEFAULT NULL,
            compliment_writer  INTEGER     DEFAULT NULL,
            cool               INTEGER     DEFAULT NULL,
            fans               INTEGER     DEFAULT NULL,
            funny              INTEGER     DEFAULT NULL,
            name               VARCHAR(64) DEFAULT NULL,
            review_count       INTEGER     DEFAULT NULL,
            useful             INTEGER     DEFAULT NULL,
            user_id            VARCHAR(22) PRIMARY KEY NOT NULL,
            yelping_since      DATETIME    DEFAULT NULL
        )
        """)

        conn.commit()

        df.to_sql("dim_users", conn, if_exists="replace", index=False)

        conn.close()

        print("user.csv inséré en base de données")
    except Exception as e:

        if conn is not None:
            conn.close()

        if cursor is not None:
            cursor.close()

        print(e)
        raise e
