#!/bin/bash

DB_URL="https://radioid.net/static/user.csv"
DB_FILE="user.csv"
CLEAN_FILE="user_wo_diacritics.csv"

echo "--- Download & Verify ---"
if curl -s -f -o "$DB_FILE" "$DB_URL" && [ -s "$DB_FILE" ]; then
    echo "File downloaded successfully."
else
    echo "Error: Download failed or file is empty."
    exit 1
fi

echo "--- Replacing of diacritics ---"
iconv -f UTF8 -t ASCII//IGNORE//TRANSLIT "$DB_FILE" > "$CLEAN_FILE"
HEADER=$(head -n 1 "$DB_FILE")

filter_users() {
    local pattern=$1
    local output=$2
    local label=$3
    echo "$HEADER" > "$output"
    grep -E "$pattern" "$CLEAN_FILE" >> "$output"
    local count=$(($(wc -l < "$output") - 1))
    printf "%-20s : %'d users\n" "$label" "$count"
}

echo "--- Generating Continental Files ---"

# EU - Europa (Wszystkie kraje europejskie wg ITU)
EU_P='[,](SP|HF|3Z|SN|SO|SQ|SR|DL|DA|DB|DC|DD|DE|DF|DG|DH|DI|DJ|DK|F|G|M|2A|2E|2I|2M|2W|I|HB|HE|OE|OK|OL|OM|ON|OT|PA|PB|PC|PD|PE|PF|PG|PH|PI|LX|LA|LB|LC|LD|LE|LF|LG|LH|SM|SA|OH|OZ|5P|5Q|EI|EJ|CT|EA|EB|EC|ED|HA|YO|LZ|UR|UT|US|UW|UX|UY|LY|YL|ES|S5|9A|E7|Z3|ZA|ZB|ZC|SV|SW|UA1|UA2|UA3|UA4|UA5|UA6|UA7)[0-9]'

# AMN - Ameryka Północna i Środkowa (USA, Kanada, Meksyk, Karaiby)
AMN_P='[,](W|K|N|A|VE|VA|VO|VY|XE|XF|XG|TI|TG|YS|YN|HR|HP|HI|CO|CM|6Y|C6|V2|V3|V4|VP2|VP5|VP8|VP9|KP2|KP4)[0-9]'

# AMS - Ameryka Południowa
AMS_P='[,](PP|PR|PS|PT|PU|PV|PW|PX|PY|LU|LW|AY|AZ|CE|XQ|HK|HJ|HC|HD|YV|YW|ZP|CX|OA|OB|OC|CP|PZ|8R)[0-9]'

# AZ - Azja (Japonia, Chiny, Indie, Bliski Wschód, Azjatycka Rosja)
AZ_P='[,](JA|JH|JR|JS|BY|VU|HS|9V|7L|7M|7N|UA8|UA9|UA0|HL|DS|UN|UK|EX|EY|EZ|4X|4Z|A6|A7|A9|HZ|EP|YI|JY|9M|9N|XV|XU|XW|S2|BA|BD|BG|BH)[0-9]'

# AUS - Australia i Oceania
AUS_P='[,](VK|AX|ZL|ZM|YB|YC|YD|YE|YF|YG|YH|DU|DV|DW|DX|DY|DZ|P2|V6|V7|V8|T2|T3|T8|ZK|ZL|ZM|FK|FO|FW|5W|A3|C2|E5|H4|KH[0-9]|NH[0-9]|WH[0-9]|V7|3D2)[0-9]'

# AF - Afryka
AUS_P='[,](VK|AX|ZL|ZM|YB|YC|YD|YE|YF|YG|YH|DU|DV|DW|DX|DY|DZ|P2|V6|V7|V8|T2|T3|T8|ZK|FK|FO|FW|5W|A3|C2|E5|H4|KH0|KH2|KH6|NH6|WH6|V7|3D2)[0-9]'

filter_users "$EU_P" "user_EU_wo_diacritics.csv" "Europe"
filter_users "$AMN_P" "user_AMN_wo_diacritics.csv" "North America"
filter_users "$AMS_P" "user_AMS_wo_diacritics.csv" "South America"
filter_users "$AZ_P" "user_AZ_wo_diacritics.csv" "Asia"
filter_users "$AUS_P" "user_AUS_wo_diacritics.csv" "Australia/Oceania"
filter_users "$AF_P" "user_AF_wo_diacritics.csv" "Africa"

# Polska (zostaje jako osobny plik)
filter_users '[,](HF|3Z|S[NOPRQ])[0-9]' "user_PL_wo_diacritics.csv" "Poland"

mkdir -p databases
mv user*.csv databases/
echo "--- Finished ---"
