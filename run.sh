#!/bin/bash

# creation de la base de données
#touch argon.db

# execution des scripts python
python script/business_to_sqlite.py
python script/checkin_to_sqlite.py
python script/tip_to_sqlite.py

# execution des scripts sql
echo "Nettoyage des données"
sqlite3 argon.db < sql/clean/clean_tip.sql
sqlite3 argon.db < sql/clean/clean_checkin_dates.sql

echo "Création des tables"
sqlite3 argon.db < sql/create_table/create_other_table.sql

echo "Optimisation de la base de données"
./script/SqliteCleaner argon.db

exit 0