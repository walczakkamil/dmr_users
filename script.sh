#!/bin/bash

DB_URL="https://radioid.net/static/user.csv"
DB_FILE="user.csv"
CLEAN_FILE="user_wo_diacritics.csv"
NEW_HEADER="Radio_ID,Callsign,Name,City,State,Country,Remarks,Call Type,Call Alert"

echo "--- Download & Verify ---"
if curl -s -f -o "$DB_FILE" "$DB_URL" && [ -s "$DB_FILE" ]; then
    echo "File downloaded successfully."
else
    echo "Error: Download failed or file is empty."
    exit 1
fi

echo "--- Replacing of diacritics ---"
iconv -f UTF8 -t ASCII//IGNORE//TRANSLIT "$DB_FILE" > "$CLEAN_FILE"
sed -i 's/\r//' "$CLEAN_FILE"
HEADER=$(head -n 1 "$DB_FILE")

PL_P="^(HF|3Z|SN|SO|SP|SQ|SR)"
EU_P="^(4O|DL|DA|DB|DC|DD|DE|DF|DG|DH|DI|DJ|DK|DO|DM|DN|DP|DQ|DR|F|G|M|I|HB|HE|OE|OK|OL|OM|ON|OT|OQ|OS|OR|OO|OP|PA|PB|PC|PD|PE|PF|PG|PH|PI|LX|LA|LB|LC|LD|LE|LF|LG|LH|SM|SA|SB|SC|SD|SI|SK|SH|SG|SE|SL|OH|OG|OI|OZ|OU|OV|OY|OX|JW|5P|5Q|EI|EJ|CT|EA|EB|EC|ED|EE|EF|EG|EH|HA|HG|YO|YR|ER|EW|EU|LZ|UR|UT|US|UW|UX|UY|LY|YL|ES|S5|9A|E7|Z3|ZA|ZB|ZC|SV|SW|SX|SY|SZ|YU|YT|CS|CR|CU|T7|TF|1K|TK|3A|C3|Z6|4U|D1|2[A-Z]|[RU][A-Z]?[1-7])"
AMN_P="^(4A|6F|W|K|N|A|VE|VA|VO|VY|CF|CG|CH|CI|CJ|CK|XE|XF|XG|TI|TG|TD|YS|YN|HR|HQ|HP|HI|CO|CM|CL|6Y|C6|V2|V3|V4|VC|VP[2589]|KP[24]|J[3678]|9Y|9Z|8P|P4|ZF|HH|FS|PJ[5-8])"
AMS_P="^(PP|PR|PS|PT|PU|PV|PW|PX|PY|PQ|ZV|ZW|ZY|ZZ|LU|LW|AY|AZ|LO|CE|CA|CB|CC|CD|CW|XQ|HK|HJ|HC|HD|YV|YW|YY|4M|ZP|CX|OA|OB|OC|CP|PZ|8R|PJ[1-4])"
AZ_P="^(5B|7Z|BY|JA|JH|JR|JS|JE|JF|JG|JI|JJ|JK|JL|JM|JN|JO|JP|JQ|JD|8J|8N|8Q|B[0-9]|BA|BD|BG|BH|BI|BJ|BL|BM|BO|BR|BV|BU|BX|VU|HS|E[24]|9[VW]|HL|DS|6[K-N]|D[7-9]|DT|UN|UK|EX|EY|EZ|4X|4Z|4[SLJK]|A[679]|HZ|EP|YI|JY|9[MN]|XV|XU|XW|3W|XX|S2|TA|TB|TC|YM|VR|VS|7[J-N]|OD|EK|JT|[RU][A-Z]?[890])"
AUS_P="^(VK|AX|ZL|ZM|YB|YC|YD|YE|YF|YG|YH|DU|DV|DW|DX|DY|DZ|4[D-I]|8I|P2|V[678]|T[238]|ZK|FK|FO|FW|5W|A3|C2|E5|H4|KH[0-9]|NH[0-9]|WH[0-9]|3D2|YJ)"
AF_P="^(7X|V5|6W|ZS|ZR|ZU|CN|SU|5[H-Z]|D[234]|E3|ET|EL|J2|S7|ST|T5|TJ|TR|TT|TU|TY|TZ|VQ9|XT|Z2|3B|3C|3DA|ZD|TL|3V|7[PQ]|9[G-L]|C5|C9)"
ALL_KNOWN="${PL_P}|${EU_P}|${AMN_P}|${AMS_P}|${AZ_P}|${AUS_P}|${AF_P}"

echo "--- Processing and Categorizing ---"
process_data() {
    local pattern=$1
    local output=$2
    local is_unknown=$3

    echo "$NEW_HEADER" > "$output"

    awk -F',' -v pat="$pattern" -v unk="$is_unknown" '
    BEGIN { OFS="," }
    NR > 1 {
        match_found = ($2 ~ pat)
        if ((unk == "false" && match_found) || (unk == "true" && !match_found)) {

            # (First + Last)
            full_name = $3 " " $4
            gsub(/ +/, " ", full_name) # Usuń podwójne spacje
            gsub(/^ | $/, "", full_name) # Usuń spacje na końcach

            # Radio_ID ($1), Callsign ($2), Name (full_name), City ($5), State ($6), Country ($7), Remarks (puste), Call Type (Private Call), Call Alert (None)
            print $1, $2, "\""full_name"\"", "\""$5"\"", "\""$6"\"", "\""$7"\"", "\"\"", "\"\"", "\"\""
        }
    }' "$CLEAN_FILE" >> "$output"
}

mkdir -p databases
rm -rf ./databases/DMR*.csv
process_data "$PL_P"              "databases/DMR_PL.csv"            "false"
process_data "${PL_P}|${EU_P}"    "databases/DMR_Europe.csv"        "false"
process_data "$AMN_P"             "databases/DMR_America_North.csv" "false"
process_data "$AMS_P"             "databases/DMR_America_South.csv" "false"
process_data "$AZ_P"              "databases/DMR_Asia.csv"          "false"
process_data "$AUS_P"             "databases/DMR_Australia.csv"     "false"
process_data "$AF_P"              "databases/DMR_Africa.csv"        "false"
process_data "$ALL_KNOWN"         "databases/DMR_world.csv"         "false"
process_data "$ALL_KNOWN"         "databases/DMR_unkown.csv"        "true"

echo "--- Summary ---"
for f in databases/DMR_*.csv; do
    printf "%-25s : %'d lines\n" "$f" $(($(wc -l < "$f") - 1))
done

rm "$CLEAN_FILE" "$DB_FILE"
echo "--- Finished ---"
