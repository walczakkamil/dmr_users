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
EU_P="^(4O|DL|DA|DB|DC|DD|DE|DF|DG|DH|DI|DJ|DK|DO|DM|DN|DP|DQ|DR|F|G|M|I|HB|HE|OE|OK|OL|OM|ON|OT|OQ|OS|OR|OO|OP|PA|PB|PC|PD|PE|PF|PG|PH|PI|LX|LA|LB|LC|LD|LE|LF|LG|LH|SM|SA|SB|SC|SD|SI|SK|SH|SG|SE|SL|OH|OG|OI|OZ|OU|OV|OY|OX|JW|5P|5Q|EI|EJ|CT|EA|EB|EC|ED|EE|EF|EG|EH|HA|HG|YO|YR|ER|EW|EU|LZ|UR|UT|US|UW|UX|UY|LY|YL|ES|S5|9A|E7|Z3|ZA|ZB|ZC|SV|SW|SX|SY|SZ|YU|YT|CS|CR|CU|T7|TF|1K|TK|3A|C3|Z6|4U|D1|2[A-Z]|[RU][A-Z]?[1-7])"
AMN_P="^(4A|6F|W|K|N|A|VE|VA|VO|VY|CF|CG|CH|CI|CJ|CK|XE|XF|XG|TI|TG|TD|YS|YN|HR|HQ|HP|HI|CO|CM|CL|6Y|C6|V2|V3|V4|VC|VP[2589]|KP[24]|J[3678]|9Y|9Z|8P|P4|ZF|HH|FS|PJ[5-8])"
AMS_P="^(PP|PR|PS|PT|PU|PV|PW|PX|PY|PQ|ZV|ZW|ZY|ZZ|LU|LW|AY|AZ|LO|CE|CA|CB|CC|CD|CW|XQ|HK|HJ|HC|HD|YV|YW|YY|4M|ZP|CX|OA|OB|OC|CP|PZ|8R|PJ[1-4])"
AZ_P="^(5B|7Z|BY|JA|JH|JR|JS|JE|JF|JG|JI|JJ|JK|JL|JM|JN|JO|JP|JQ|JD|8J|8N|8Q|B[0-9]|BA|BD|BG|BH|BI|BJ|BL|BM|BO|BR|BV|BU|BX|VU|HS|E[24]|9[VW]|HL|DS|6[K-N]|D[7-9]|DT|UN|UK|EX|EY|EZ|4X|4Z|4[SLJK]|A[679]|HZ|EP|YI|JY|9[MN]|XV|XU|XW|3W|XX|S2|TA|TB|TC|YM|VR|VS|7[J-N]|OD|EK|JT|[RU][A-Z]?[890])"
AUS_P="^(VK|AX|ZL|ZM|YB|YC|YD|YE|YF|YG|YH|DU|DV|DW|DX|DY|DZ|4[D-I]|8I|P2|V[678]|T[238]|ZK|FK|FO|FW|5W|A3|C2|E5|H4|KH[0-9]|NH[0-9]|WH[0-9]|3D2|YJ)"
AF_P="^(7X|V5|6W|ZS|ZR|ZU|CN|SU|5[H-Z]|D[234]|E3|ET|EL|J2|S7|ST|T5|TJ|TR|TT|TU|TY|TZ|VQ9|XT|Z2|3B|3C|3DA|ZD|TL|3V|7[PQ]|9[G-L]|C5|C9)"
ALL_KNOWN="${PL_P}|${EU_P}|${AMN_P}|${AMS_P}|${AZ_P}|${AUS_P}|${AF_P}"

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
