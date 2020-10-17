#!/bin/bash
while IFS= read -r rc
do
    openssl $rc -d -in sifra.dec -out ulaz/ulaz-$rc.txt -k neporecivost -md md5
    echo -n "ulaz-$rc.txt -> " && cat ulaz/ulaz-$rc.txt && echo
done < rc.list
