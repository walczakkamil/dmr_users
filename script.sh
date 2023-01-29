#!/bin/bash

echo "Cleanup"
rm -rf user*.csv

echo "Download the latest user database"
curl -s -o user.csv https://radioid.net/static/user.csv

echo "Replacing of diacritics"
iconv -o user_wo_diacritics.csv -f UTF8 -t US-ASCII//TRANSLIT user.csv

echo "Create PL stattion list"
head -n 1 user.csv > user_PL_wo_diacritics.csv
grep -E '[,](HF|3Z|S[NOPRQ])[0-9]([A-Z0-9]{0,3}[A-Z]{1})[,]' user_wo_diacritics.csv >> user_PL_wo_diacritics.csv
