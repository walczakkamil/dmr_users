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
# Zawiera m.in. SP, DL, G, F, I, HB, OE, OK, OM, LY, YL, ES, OH, LA, SM, OZ, EI, SV, CT, EA, HA, YO, LZ, UR, UA(1-6)
EU_P='[,]([C][3]|DL|EB|EA|EC|ED|EE|EF|EG|EH|EI|EJ|EK|ER|ES|ET|EU|EW|EX|EY|F|G|H[ABEGILN]|I|L[A-H]|M|OE|O[H-J]|O[K-M]|O[N-T]|O[U-Z]|P[A-I]|S[A-M]|S[NOPRQ]|T[FGHJKLMNPQR]|U[A-I][1-7]|U[KLNR-Z]|Y[LNU]|Z[A-C]|[23][A-Z])[0-9]'

# AMN - Ameryka Północna i Środkowa (USA, Kanada, Meksyk, Karaiby)
AMN_P='[,]([WKNA]|VE|VA|VO|VY|XE|XF|XG|V[2-4]|V[P-R]|TI|T[G-J]|H[H-K]|6[Y-Z]|7[P-S]|8[P-R]|9[A-Z])[0-9]'

# AMS - Ameryka Południowa
AMS_P='[,](PY|PP|PU|LU|AY|LW|CE|CX|HC|HK|HJ|OA|YV|ZP|ZV|OA|CP|P[J-T]|8[R])[0-9]'

# AZ - Azja (Japonia, Chiny, Indie, Bliski Wschód, Azjatycka Rosja)
AZ_P='[,](JA|JH|JR|JS|BY|VU|HS|9V|7L|7M|7N|UA9|UA0|HL|DS|A[4-9]|B|E[2-4]|H[L-Z]|J[A-S]|9[K-N])[0-9]'

# AUS - Australia i Oceania
AUS_P='[,](VK|ZL|ZM|V[A-G]|YB|YC|DU|DV|P2|T2|T3|V[6-8]|ZK|FW|5W|KH[0-9])[0-9]'

# AF - Afryka
AF_P='[,](ZS|ZR|ZU|CN|SU|5N|D2|V5|EL|3[A-B]|5[H-T]|6[A-W]|7[A-R]|9[G-L])[0-9]'

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
