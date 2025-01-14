#!/bin/bash

if [ -f argon.db ]; then
    echo "La base de données existe"
else
    echo "La base de données n'existe pas, création de la base de données"
    sqlite3 argon.db < sql/sqlite_config.sql
fi

# execution des scripts python
echo "Execution des scripts python"
python script/business_to_sqlite.py
#python script/checkin_date_to_sqlite.py
python script/tip_to_sqlite.py

# execution des scripts sql
echo "Nettoyage des données"
sqlite3 argon.db < sql/transform/clean_tip.sql
sqlite3 argon.db < sql/transform/clean_checkin_dates.sql

echo "Création des data marts et des tables de dimension"
#sqlite3 argon.db < sql/load/merge_attr_cat_table_1.sql
#sqlite3 argon.db < sql/load/creating_dim_tables_2.sql
#sqlite3 argon.db < sql/load/load_in_dim_tables_3.sql.sql

echo "Nettoyage de la base de données"
#sqlite3 argon.db < sql/load/cleanup_tables_4.sql
#./script/SqliteCleaner argon.db &

exit 0