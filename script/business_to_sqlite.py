import ast
import json
import os
import sqlite3

if __name__ == '__main__':
    absolute_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    file = os.path.join(absolute_path, "data/yelp_academic_dataset_business.json")

    conn = sqlite3.connect("../argon.db")
    cursor = conn.cursor()

    cursor.execute("DROP TABLE IF EXISTS business")
    cursor.execute("DROP TABLE IF EXISTS hours")
    cursor.execute("DROP TABLE IF EXISTS attributes")
    cursor.execute("DROP TABLE IF EXISTS business_parking")
    cursor.execute("DROP TABLE IF EXISTS business_categories")
    conn.commit()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS business (
        business_id VARCHAR(22) PRIMARY KEY NOT NULL,
        name VARCHAR(255) DEFAULT NULL,
        address VARCHAR(255) DEFAULT NULL,
        city VARCHAR(255) DEFAULT NULL,
        state VARCHAR(255) DEFAULT NULL,
        postal_code VARCHAR(255) DEFAULT NULL,
        latitude REAL DEFAULT NULL,
        longitude REAL DEFAULT NULL,
        review_count INTEGER DEFAULT NULL,
        is_open INTEGER DEFAULT NULL
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS hours (
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
    CREATE TABLE IF NOT EXISTS attributes (
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

    with open(file, "r") as file:
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
            hours = data.get("hours")

            if hours:
                monday = hours.get("Monday", "")
                tuesday = hours.get("Tuesday", "")
                wednesday = hours.get("Wednesday", "")
                thursday = hours.get("Thursday", "")
                friday = hours.get("Friday", "")
                saturday = hours.get("Saturday", "")
                sunday = hours.get("Sunday", "")
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
                        INSERT INTO attributes (business_id, key, value)
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
            INSERT INTO hours (business_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (business_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday))

    conn.commit()
    conn.close()

    print("Données insérées avec succès dans la base SQLite3.")
