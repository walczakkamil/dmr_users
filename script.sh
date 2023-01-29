#!/bin/bash

echo "Cleanup"
rm -rf user*.csv

echo "Download the latest user database"
curl -s -o user.csv https://radioid.net/static/user.csv

echo "Replacing of diacritics"
iconv -o user_wo_diacritics.csv -f UTF8 -t US-ASCII//TRANSLIT user.csv

