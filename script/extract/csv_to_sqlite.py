import os
import sqlite3
import time

import pandas as pd


def csv_to_sqlite(nom_fichier: str, table_name: str, conn: sqlite3.Connection, separator: str = ","):
    file = os.path.join(absolute_path, "data", nom_fichier)

    if not os.path.exists(file):
        print(f"Le fichier {nom_fichier} est introuvable.")
        return

    with open(file, "r", encoding='utf-8') as f:
        num_lines = sum(1 for _ in f)

    if num_lines == 0:
        print(f"Le fichier est vide.")
        return

    df = pd.read_csv(file, on_bad_lines='skip', encoding='utf-8', engine='c', sep=separator)
    num_lines_df = df.shape[0]

    if num_lines_df == 0:
        print(f"Le DataFrame est vide.")
        return

    print(f"Le fichier contient {num_lines} lignes.")
    print(f"Le DataFrame contient {num_lines_df} lignes.")
    print(f"Difference: {num_lines - num_lines_df} soit {num_lines_df * 100 / num_lines:.2f}%.")

    try:
        sql = "DELETE FROM " + table_name
        conn.execute(sql)
        conn.commit()
    except Exception as e:
        print(e)

    df.to_sql(table_name, conn, if_exists="replace", index=False)
    print(f"{nom_fichier} a été importé avec succès dans la table {table_name}.")


if __name__ == '__main__':
    try:

        start = time.time()
        absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

        db_path = os.path.join(absolute_path, "argon.db")
        conn = sqlite3.connect(db_path)

        list_files = {
            # "population.csv": ["population", ","],
            # "tpid2020_yelp_review.csv": ["reviews", ","],
            # "yelp_academic_dataset_tip.csv": ["tip", ","],
            "review_sentiment_analysis_results.csv": ["review_sentiment", ","],
            "tips_sentiment_analysis_results.csv": ["tips_sentiment", ","],
        }

        for file, table in list_files.items():
            csv_to_sqlite(file, table[0], conn, table[1])

        conn.close()
        print(f"Execution time: {time.time() - start:.2f} seconds.")

    except Exception as e:
        print(e)
