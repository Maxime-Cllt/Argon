import csv
import os
import sqlite3
import time

import psycopg2


def csv_to_postgres(csv_path: str, table_name: str, postgres_cursor, separator: str):
    with open(csv_path, mode='r', encoding='utf-8') as csv_file:
        header = csv_file.readline().strip()

    header = header.split(separator)
    header = [h.replace('"', '') for h in header]

    if not os.path.exists(csv_path):
        print(f"Le fichier {csv_path} est introuvable.")
        return

    sql = f"""COPY {table_name} ({', '.join(header)}) FROM STDIN WITH (FORMAT CSV, DELIMITER '{separator}', HEADER TRUE, QUOTE '"', ESCAPE '\\');"""

    print(f"Importation de {table_name} en cours...")

    try:
        postgres_cursor.execute(f"TRUNCATE TABLE {table_name} CASCADE;")
        with open(csv_path, mode='r', encoding='utf-8') as csv_file:
            postgres_cursor.copy_expert(sql, csv_file)
        postgres_conn.commit()
        print(f"Importation de {table_name} réussie.")
    except Exception as e:
        print(f"Erreur lors de l'importation de {table_name}: {e}")


if __name__ == '__main__':
    try:
        absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        db_path = os.path.join(absolute_path, "argon.db")
        temp_absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "temp"))

        if not os.path.exists(db_path):
            raise Exception(f"Le fichier {db_path} est introuvable.")

        # Connexion à SQLite
        sqlite_conn = sqlite3.connect(db_path)
        sqlite_cursor = sqlite_conn.cursor()

        POSTGRES_USER = "mc150904"
        POSTGRES_PASSWORD = "mc150904"
        POSTGRES_HOST = "kafka.iem"
        POSTGRES_PORT = "5432"
        POSTGRES_DB = "mc150904"

        # POSTGRES_USER = "root"
        # POSTGRES_PASSWORD = "root"
        # POSTGRES_HOST = "localhost"
        # POSTGRES_PORT = "5432"
        # POSTGRES_DB = "postgres"

        postgres_conn = psycopg2.connect(
            dbname=POSTGRES_DB,
            user=POSTGRES_USER,
            password=POSTGRES_PASSWORD,
            host=POSTGRES_HOST,
            port=POSTGRES_PORT
        )
        postgres_cursor = postgres_conn.cursor()

        tables_to_import_map = {
            # 'dim_business': False,
            # 'dim_hours': False,
            # 'dim_business_hours': False,
            # 'dim_checkin': False,
            # 'dim_amenagement': False,
            # 'dim_tips': False,
            # 'dim_city': False,
            # 'dim_categories': False,
            # 'fact_business': False
        }

        chunk_size = 10000

        # verifier si le repertoire temporaire existe et vérifier si les fichiers csv existent
        if os.path.exists(temp_absolute_path):
            for file in os.listdir(temp_absolute_path):
                if file.endswith(".csv"):
                    table_name = file.split(".")[0]
                    if table_name in tables_to_import_map:
                        tables_to_import_map[table_name] = True
        else:
            os.makedirs(temp_absolute_path, exist_ok=True)

        # Création du répertoire temporaire
        for table_name, exist in tables_to_import_map.items():
            csv_path = os.path.join(temp_absolute_path, f"{table_name}.csv")

            if exist:
                continue

            print(f"Exportation de {table_name} en cours...")
            # récupérer les colonnes de la table
            sqlite_cursor.execute(f"PRAGMA table_info({table_name})")
            columns = [column[1] for column in sqlite_cursor.fetchall()]

            with open(csv_path, mode='w', newline='', encoding='utf-8') as csv_file:
                writer = csv.writer(csv_file, delimiter=';', quoting=csv.QUOTE_STRINGS, lineterminator='\n',
                                    escapechar='\\')

                writer.writerow(columns)

                offset = 0
                while True:
                    sqlite_cursor.execute(f"SELECT * FROM {table_name} LIMIT {chunk_size} OFFSET {offset}")
                    rows = sqlite_cursor.fetchall()
                    if not rows:
                        break
                    writer.writerows(rows)
                    offset += chunk_size

        sqlite_cursor.close()
        sqlite_conn.close()

        start_time = time.time()  # 201 secondes

        # Importation des fichiers CSV dans PostgreSQL
        for table_name, to_import in tables_to_import_map.items():
            csv_path = os.path.join(temp_absolute_path, f"{table_name}.csv")
            csv_to_postgres(csv_path, table_name, postgres_cursor, separator=';')

        file_to_import_from_data = {
            'tpid2020_yelp_review.csv': 'dim_reviews'
        }

        # Pour les fichiers en local dans le répertoire data
        for file, table_name in file_to_import_from_data.items():
            csv_path = os.path.join(absolute_path, "data", file)
            csv_to_postgres(csv_path, table_name, postgres_cursor, separator=',')

        print(f"Temps d'exécution: {time.time() - start_time} secondes")

        # Close the connection
        postgres_cursor.close()
        postgres_conn.close()
    except Exception as e:
        print(e)
