import os
import sqlite3

import pandas as pd


def csv_to_sqlite(nom_fichier: str, table_name: str, conn: sqlite3.Connection):
    file = os.path.join(absolute_path, "data", nom_fichier)

    if not os.path.exists(file):
        print(f"Le fichier {nom_fichier} est introuvable.")
        return

    df = pd.read_csv(file, on_bad_lines='skip')

    nombre_lignes = df.shape[0]

    if nombre_lignes == 0:
        print(f"Le DataFrame est vide.")
        return

    print(f"Le DataFrame contient {nombre_lignes} lignes.")
    df.to_sql(table_name, conn, if_exists="replace", index=False)
    print(f"{nom_fichier} a été importé avec succès")


if __name__ == '__main__':
    try:
        absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

        db_path = os.path.join(absolute_path, "argon.db")
        conn = sqlite3.connect(db_path)

        list_files = {
            # "population.csv": "population",
            "tpid2020_yelp_review.csv": "dim_reviews",
        }

        for nom_fichier, table_name in list_files.items():
            csv_to_sqlite(nom_fichier, table_name, conn)

        conn.close()

    except Exception as e:
        print(e)
