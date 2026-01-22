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
EU_P="^(DL|DA|DB|DC|DD|DE|DF|DG|DH|DI|DJ|DK|DL|DM|DN|DO|DP|DQ|DR|F|G|M|I|HB|HE|OE|OK|OL|OM|ON|OT|OQ|OS|OR|OO|OP|PA|PB|PC|PD|PE|PF|PG|PH|PI|LX|LA|LB|LC|LD|LE|LF|LG|LH|SM|SA|OH|OZ|5P|5Q|EI|EJ|CT|EA|EB|EC|ED|EE|EF|EG|EH|HA|HG|YO|YR|LZ|UR|UT|US|UW|UX|UY|LY|YL|ES|S5|9A|E7|Z3|ZA|ZB|ZC|SV|SW|SX|SY|SZ|YU|YT|CS|CR|UA[1-7]|R[1-7]|RA[1-7]|UB[1-7]|1K|TK|3A|C3|Z6|4U|2[A-Z])"
AMN_P="^(W|K|N|A|VE|VA|VO|VY|CF|CG|CH|CI|CJ|CK|XE|XF|XG|TI|TG|TD|YS|YN|HR|HQ|HP|HI|CO|CM|6Y|C6|V2|V3|V4|VP[2589]|KP[24]|J7|J8|FS|PJ[5-8])"
AMS_P="^(PP|PR|PS|PT|PU|PV|PW|PX|PY|PQ|ZV|ZW|ZY|ZZ|LU|LW|AY|AZ|LO|CE|CA|CB|CC|CD|XQ|HK|HJ|HC|HD|YV|YW|YY|ZP|CX|OA|OB|OC|CP|PZ|8R|PJ[1-4])"
AZ_P="^(JA|JH|JR|JS|JE|JF|JG|JH|JI|JJ|JK|B[0-9]|BA|BD|BG|BH|BI|BJ|BL|BM|BV|BU|BX|VU|HS|E2|9V|9W|7L|7M|7N|UA[890]|R[890]|RA[890]|UB[890]|HL|DS|6K|UN|UK|EX|EY|EZ|4X|4Z|A6|A7|A9|HZ|EP|YI|JY|9M|9N|XV|XU|XW|S2|TA|TB|TC|VR|VS|7J|7Z)"
AUS_P="^(VK|AX|ZL|ZM|YB|YC|YD|YE|YF|YG|YH|DU|DV|DW|DX|DY|DZ|4E|4F|4G|4H|4I|P2|V6|V7|V8|T2|T3|T8|ZK|FK|FO|FW|5W|A3|C2|E5|H4|KH[0-9]|NH[0-9]|WH[0-9]|V7|3D2|YJ)"
AF_P="^(ZS|ZR|ZU|CN|SU|5N|D2|D3|V5|EL|3V|3B|5H|5I|5J|5K|5L|5M|5N|5O|5P|5R|5T|5U|5V|5X|5Z|6W|7X|9G|9H|9I|9J|9K|9L|9U|9X|C5|C9|D4|E3|ET|J2|S7|ST|7Q|7P|T5|TJ|TR|TT|TU|TY|TZ|VQ9|XT|Z2|3DA|ZD)"

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
