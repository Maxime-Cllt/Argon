#!/bin/bash

if [ -f argon.db ]; then
    echo "La base de données existe"
else
    echo "La base de données n'existe pas, création de la base de données"
    sqlite3 argon.db < sql/sqlite_config.sql
fi

# execution des scripts python
echo "Execution des scripts python"
python script/extract/business_to_sqlite.py
python script/extract/checkin_date_to_sqlite.py
python script/extract/tip_to_sqlite.py
python script/extract/csv_to_sqlite.py

# execution des scripts sql
echo "Nettoyage des données"
sqlite3 argon.db < sql/transform/clean_business.sql
sqlite3 argon.db < sql/transform/clean_tip.sql
sqlite3 argon.db < sql/transform/clean_checkin_dates.sql
sqlite3 argon.db < sql/transform/clean_city.sql

echo "Création des data marts et des tables de dimension en local"
sqlite3 argon.db < sql/load/merge_attr_cat_table_1.sql
sqlite3 argon.db < sql/load/creating_data_marts_2.sql
sqlite3 argon.db < sql/load/load_in_dim_tables_3.sql
sqlite3 argon.db < sql/load/cleanup_tables_4.sql

echo "Chargement des données dans la base de production"
python script/load/load_to_data_warehouse.py

echo "Nettoyage de la base de données en local"
#sqlite3 argon.db < sql/load/cleanup_tables_4.sql
#./script/SQLiteCleaner "argon.db" &

echo "Fin du script"

exit 0