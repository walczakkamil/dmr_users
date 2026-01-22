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

# Definicje prefiksów (w formacie dla awk)
PL_P="^(HF|3Z|SN|SO|SP|SQ|SR)"
EU_P="^(DL|DA|DB|DC|DD|DE|DF|DG|DH|DI|DJ|DK|DO|DM|DN|F|G|M|2A|2E|2I|2M|2W|I|HB|HE|OE|OK|OL|OM|ON|OT|PA|PB|PC|PD|PE|PF|PG|PH|PI|LX|LA|LB|LC|LD|LE|LF|LG|LH|SM|SA|OH|OZ|5P|5Q|EI|EJ|CT|EA|EB|EC|ED|HA|HG|YO|LZ|UR|UT|US|UW|UX|UY|LY|YL|ES|S5|9A|E7|Z3|ZA|ZB|ZC|SV|SW|SY|YU|YT|CS|CR|UA[1-7]|R[1-7]|UB[1-7])"
AMN_P="^(W|K|N|A|VE|VA|VO|VY|XE|XF|XG|TI|TG|YS|YN|HR|HP|HI|CO|CM|6Y|C6|V2|V3|V4|VP[2589]|KP[24]|J7)"
AMS_P="^(PP|PR|PS|PT|PU|PV|PW|PX|PY|LU|LW|AY|AZ|CE|CA|CB|CD|XQ|HK|HJ|HC|HD|YV|YW|YY|ZP|CX|OA|OB|OC|CP|PZ|8R)"
AZ_P="^(JA|JH|JR|JS|JE|JF|JG|JH|JI|JJ|JK|BY|BI|BM|VU|HS|E2|9V|9W|7L|7M|7N|UA[890]|R[890]|UB[890]|HL|DS|6K|UN|UK|EX|EY|EZ|4X|4Z|A6|A7|A9|HZ|EP|YI|JY|9M|9N|XV|XU|XW|S2|BA|BD|BG|BH|TA|TB|VR)"
AUS_P="^(VK|AX|ZL|ZM|YB|YC|YD|YE|YF|YG|YH|DU|DV|DW|DX|DY|DZ|4G|P2|V6|V7|V8|T2|T3|T8|ZK|FK|FO|FW|5W|A3|C2|E5|H4|KH[0-9]|NH[0-9]|WH[0-9]|V7|3D2)"
AF_P="^(ZS|ZR|ZU|CN|SU|5N|D2|D3|V5|EL|3V|5H|5I|5R|5T|5U|5V|5X|5Z|6W|7X|9G|9J|9L|9U|9X|C5|D4|E3|ET|J2|S7|ST|T5|TJ|TR|TT|TU|TY|TZ|VQ9|XT|Z2)"
ALL_KNOWN="$PL_P|$EU_P|$AMN_P|$AMS_P|$AZ_P|$AUS_P|$AF_P"

echo "--- Filter by 2nd column (CALLSIGN) ---"

filter_awk() {
    local pattern=$1
    local output=$2
    echo "$HEADER" > "$output"
    awk -F',' -v pat="$pattern" '$2 ~ pat' "$CLEAN_FILE" >> "$output"
}

filter_awk "$PL_P" "user_PL_wo_diacritics.csv"
filter_awk "$EU_P" "user_EU_wo_diacritics.csv"
filter_awk "$AMN_P" "user_AMN_wo_diacritics.csv"
filter_awk "$AMS_P" "user_AMS_wo_diacritics.csv"
filter_awk "$AZ_P" "user_AZ_wo_diacritics.csv"
filter_awk "$AUS_P" "user_AUS_wo_diacritics.csv"
filter_awk "$AF_P" "user_AF_wo_diacritics.csv"

# UNKNOWN - rekordy niepasujące do żadnego kontynentu
echo "$HEADER" > "user_UNKNOWN.csv"
awk -F',' -v pat="$ALL_KNOWN" 'NR > 1 && $2 !~ pat' "$CLEAN_FILE" >> "user_UNKNOWN.csv"

printf "Polska     : %'d\n" $(($(wc -l < user_PL_wo_diacritics.csv) - 1))
printf "Europa     : %'d\n" $(($(wc -l < user_EU_wo_diacritics.csv) - 1))
printf "Ameryka N  : %'d\n" $(($(wc -l < user_AMN_wo_diacritics.csv) - 1))
printf "Ameryka S  : %'d\n" $(($(wc -l < user_AMS_wo_diacritics.csv) - 1))
printf "Azja       : %'d\n" $(($(wc -l < user_AZ_wo_diacritics.csv) - 1))
printf "Australia  : %'d\n" $(($(wc -l < user_AUS_wo_diacritics.csv) - 1))
printf "Afryka     : %'d\n" $(($(wc -l < user_AF_wo_diacritics.csv) - 1))
printf "Pozostałe  : %'d (Plik UNKNOWN)\n" $(($(wc -l < user_UNKNOWN.csv) - 1))

mkdir -p databases
mv user*.csv databases/
echo "--- Finished ---"
