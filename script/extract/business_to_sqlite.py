import ast
import json
import os
import sqlite3


def drop_tables(cursor):
    sql_list = [
        "DROP TABLE IF EXISTS business",
        "DROP TABLE IF EXISTS business_hours",
        "DROP TABLE IF EXISTS business_attributes",
        "DROP TABLE IF EXISTS business_parking",
        "DROP TABLE IF EXISTS business_categories"
    ]

    for sql in sql_list:
        try:
            cursor.execute(sql)
            conn.commit()
        except Exception as e:
            print("Erreur lors de la suppression des tables", e)


def create_tables(cursor):
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS business (
        business_id VARCHAR(22) PRIMARY KEY NOT NULL,
        name VARCHAR(255) NOT NULL,
        address VARCHAR(255) DEFAULT NULL,
        city VARCHAR(255) DEFAULT NULL,
        state VARCHAR(255) DEFAULT NULL,
        postal_code VARCHAR(255) DEFAULT NULL,
        latitude FLOAT DEFAULT NULL,
        longitude FLOAT DEFAULT NULL,
        review_count INTEGER DEFAULT NULL,
        is_open INTEGER DEFAULT NULL
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS business_hours (
        business_id VARCHAR(22) PRIMARY KEY NOT NULL,
        monday VARCHAR(20) DEFAULT NULL,
        tuesday VARCHAR(20) DEFAULT NULL,
        wednesday VARCHAR(20) DEFAULT NULL,
        thursday VARCHAR(20) DEFAULT NULL,
        friday VARCHAR(20) DEFAULT NULL,
        saturday VARCHAR(20) DEFAULT NULL,
        sunday VARCHAR(20) DEFAULT NULL,
        FOREIGN KEY (business_id) REFERENCES business(business_id)
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS business_attributes (
        business_id VARCHAR(22) NOT NULL,
        key VARCHAR(255) NOT NULL,
        value VARCHAR(255) NOT NULL,
        FOREIGN KEY (business_id) REFERENCES business(business_id)
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS business_parking (
        business_id VARCHAR(22) NOT NULL,
        garage INTEGER DEFAULT NULL,
        street INTEGER DEFAULT NULL,
        validated INTEGER DEFAULT NULL,
        lot INTEGER DEFAULT NULL,
        valet INTEGER DEFAULT NULL,
        FOREIGN KEY (business_id) REFERENCES business(business_id)
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS business_categories (
        business_id VARCHAR(22) NOT NULL,
        category VARCHAR(255) NOT NULL,
        FOREIGN KEY (business_id) REFERENCES business(business_id)
    )
    """)

    conn.commit()


if __name__ == '__main__':
    try:
        nom_fichier = "yelp_academic_dataset_business.json"
        absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        file = os.path.join(absolute_path, "data", nom_fichier)

        if not os.path.exists(file):
            raise Exception(f"Le fichier {nom_fichier} est introuvable.")

        db_path = os.path.join(absolute_path, "argon.db")

        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        drop_tables(cursor)

        create_tables(cursor)

        with open(file, "r", encoding="utf-8") as file:
            for line in file:
                data = json.loads(line.strip())
                business_id = data.get("business_id")
                name = data.get("name")
                address = data.get("address")
                city = data.get("city")
                state = data.get("state")
                postal_code = data.get("postal_code")
                latitude = data.get("latitude")
                longitude = data.get("longitude")
                review_count = data.get("review_count")
                is_open = data.get("is_open")
                business_hours = data.get("hours")

                if business_hours:
                    monday = business_hours.get("Monday", "")
                    tuesday = business_hours.get("Tuesday", "")
                    wednesday = business_hours.get("Wednesday", "")
                    thursday = business_hours.get("Thursday", "")
                    friday = business_hours.get("Friday", "")
                    saturday = business_hours.get("Saturday", "")
                    sunday = business_hours.get("Sunday", "")
                else:
                    monday = tuesday = wednesday = thursday = friday = saturday = sunday = ""

                attributs = data.get("attributes")

                if attributs:
                    for key, value in attributs.items():

                        if key == "BusinessParking":
                            parking = ast.literal_eval(value)

                            if parking is None:
                                continue

                            cursor.execute("""
                            INSERT INTO business_parking (business_id, garage, street, validated, lot, valet)
                            VALUES (?, ?, ?, ?, ?, ?)
                            """, (business_id, parking.get("garage"), parking.get("street"), parking.get("validated"),
                                  parking.get("lot"), parking.get("valet")))
                        else:
                            cursor.execute("""
                            INSERT INTO business_attributes (business_id, key, value)
                            VALUES (?, ?, ?)
                            """, (business_id, key, value))

                categories = data.get("categories")

                if categories:
                    values = categories.split(", ")
                    for value in values:
                        cursor.execute("""
                        INSERT INTO business_categories (business_id, category)
                        VALUES (?, ?)
                        """, (business_id, value))

                cursor.execute("""
                INSERT INTO business (business_id, name, address, city, state, postal_code, latitude, longitude, review_count, is_open)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (business_id, name, address, city, state, postal_code, latitude, longitude, review_count, is_open))

                cursor.execute("""
                INSERT INTO business_hours (business_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """, (business_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday))

        conn.commit()
        conn.close()

        print(f"{nom_fichier} a été importé avec succès en bd.")

    except Exception as e:
        print("Erreur lors de l'importation du fichier", e)

        if conn:
            conn.close()
