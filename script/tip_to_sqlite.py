import sqlite3

import pandas as pd

if __name__ == '__main__':
    file = "../data/yelp_academic_dataset_tip.csv"

    # count the number of lines in the file
    with open(file) as f:
        num_lines = sum(1 for line in f)

    print(f"Le fichier contient {num_lines} lignes.")

    df = pd.read_csv(file, on_bad_lines='skip')

    num_lines_df = df.shape[0]
    print(f"Le DataFrame contient {num_lines_df} lignes.")
    print(f"Difference: {num_lines - num_lines_df} soit {num_lines_df * 100 / num_lines:.2f}%.")

    conn = sqlite3.connect("../argon.db")
    cursor = conn.cursor()

    cursor.execute("""
    DROP TABLE IF EXISTS tip
    """)

    conn.commit()

    # cursor.execute("""
    # CREATE TABLE tip (
    #     business_id TEXT,
    #     compliment_count INTEGER,
    #     date TEXT,
    #     text TEXT,
    #     user_id TEXT
    # )
    # """)

    df.to_sql("tip", conn, if_exists="replace", index=False)

    conn.close()

    print("Données insérées avec succès dans la base SQLite3.")
