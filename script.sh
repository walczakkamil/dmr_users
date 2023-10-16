#!/bin/bash

echo "Cleanup"
rm -rf user*.csv

echo "Download the latest user database"
curl -s -o user.csv https://radioid.net/static/user.csv

echo "Replacing of diacritics"
iconv -f UTF8 -t ASCII//IGNORE//TRANSLIT user.csv >  user_wo_diacritics.csv

echo "Create PL station list"
head -n 1 user.csv > user_PL_wo_diacritics.csv
grep -E '[,](HF|3Z|S[NOPRQ])[0-9]([A-Z0-9]{0,3}[A-Z]{1})[,]' user_wo_diacritics.csv >> user_PL_wo_diacritics.csv

mkdir -p databases
cp user*.csv databases/
