import os
import sqlite3
import psycopg2

if __name__ == '__main__':
    absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    db_path = os.path.join(absolute_path, "argon.db")

    if not os.path.exists(db_path):
        raise Exception(f"Le fichier {db_path} est introuvable.")


    # Connexion à SQLite
    sqlite_conn = sqlite3.connect(db_path)
    sqlite_cursor = sqlite_conn.cursor()

    # Connexion à PostgreSQL
    postgres_conn = psycopg2.connect(
        dbname="ma_base_postgres",
        user="mon_utilisateur",
        password="mon_mot_de_passe",
        host="localhost",
        port="5432"
    )
    postgres_cursor = postgres_conn.cursor()

    tables_to_import = ['dim_business', 'dim_hours', 'dim_business_hours', 'dim_amenagement', 'dim_tips', 'dim_categories', 'fact_business']