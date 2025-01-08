#!/bin/bash

#python /script/business_to_sqlite.py
#python /script/checkin_to_sqlite.py
#python /script/tip_to_sqlite.py

echo "Nettoyage des données"
sqlite3 argon.db < sql/clean/clean_tip.sql
sqlite3 argon.db < sql/clean/clean_checkin_dates.sql
