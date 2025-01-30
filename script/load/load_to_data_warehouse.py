import csv
import os
import sqlite3

import pandas as pd
import psycopg2
from sqlalchemy import create_engine

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

        # POSTGRES_USER = "argon"
        # POSTGRES_PASSWORD = "argon"
        # POSTGRES_HOST = "localhost"
        # POSTGRES_PORT = "5432"
        # POSTGRES_DB = "argon"

        POSTGRES_USER = "mc150904"
        POSTGRES_PASSWORD = "mc150904"
        POSTGRES_HOST = "kafka.iem"
        POSTGRES_PORT = "5432"
        POSTGRES_DB = "mc150904"

        postgres_conn = psycopg2.connect(
            dbname=POSTGRES_DB,
            user=POSTGRES_USER,
            password=POSTGRES_PASSWORD,
            host=POSTGRES_HOST,
            port=POSTGRES_PORT
        )
        postgres_cursor = postgres_conn.cursor()

        script_path = os.path.join(absolute_path, "sql/load/create_posgtres_tables_5.sql")
        # executer un fichier sql pour creer les tables sur postgres
        with open(script_path, mode='r', encoding='utf-8') as sql_file:
            try:
                postgres_cursor.execute(sql_file.read())
                postgres_conn.commit()
            except Exception as e:
                print(f"{e}")

        tables_to_import_map = {
            'dim_business': False,
            'dim_hours': False,
            'dim_business_hours': False,
            'dim_checkin': False,
            'dim_amenagement': False,
            'dim_tips': False,
            'dim_categories': False,
            'fact_business': False
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
                writer = csv.writer(csv_file, delimiter=';', quoting=csv.QUOTE_ALL, lineterminator='\n',
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

        # Importation des fichiers CSV dans PostgreSQL
        # for table_name, to_import in tables_to_import_map.items():
        #     csv_path = os.path.join(temp_absolute_path, f"{table_name}.csv")
        #
        #     # récupérer les colonnes de la table
        #     postgres_cursor.execute(
        #         f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table_name}'")
        #     # postgres_cursor.execute(
        #     #     f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table_name}'")
        #     columns = [column[0] for column in postgres_cursor.fetchall()]
        #
        #     if not os.path.exists(csv_path):
        #         print(f"Le fichier {csv_path} est introuvable.")
        #         continue
        #
        #     # Build the COPY command with STDIN
        #     sql = f"""COPY {table_name} ({', '.join(columns)}) FROM STDIN WITH (FORMAT CSV, DELIMITER ';', HEADER TRUE, QUOTE '"', ESCAPE '\\');"""
        #
        #
        #     print(f"Importation de {table_name} en cours...")
        #     try:
        #         with open(csv_path, mode='r', encoding='utf-8') as csv_file:
        #             postgres_cursor.copy_expert(sql, csv_file)
        #         postgres_conn.commit()
        #         print(f"Importation de {table_name} réussie.")
        #     except Exception as e:
        #         print(f"Erreur lors de l'importation de {table_name}: {e}")

        # Create SQLAlchemy engine for PostgreSQL
        engine = create_engine(
            f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}")

        for table_name, to_import in tables_to_import_map.items():
            csv_path = os.path.join(temp_absolute_path, f"{table_name}.csv")

            if not os.path.exists(csv_path):
                print(f"Le fichier {csv_path} est introuvable.")
                continue

            dataframe = pd.read_csv(csv_path, sep=';', encoding='utf-8')
            dataframe.to_sql(table_name, engine, if_exists='append', index=False, chunksize=chunk_size)

            print(f"Importation de {table_name} réussie.")

        # Close the connection
        sqlite_cursor.close()
        sqlite_conn.close()
        postgres_cursor.close()
        postgres_conn.close()
        # engine.dispose()
    except Exception as e:
        print(e)
