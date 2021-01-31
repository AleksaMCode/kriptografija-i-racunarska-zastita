#!/bin/bash
while IFS= read -r cast5
do
    for i in {0..30}
    do
        openssl $cast5 -d -in sifrat.txt -out ulaz1.txt -k lozinka$i
        openssl $cast5 -d -in ulaz1.txt -out ulaz2.txt -k lozinka$i
        openssl $cast5 -d -in ulaz2.txt -out ulaz3.txt -k lozinka$i
        TEXT=$(cat ulaz3.txt)
        rm ulaz*.txt
        if [ "$TEXT" != "" ]
        then
            echo "$cast5 + lozinka$i -> $TEXT"
            break 2
        fi
    done
done < cast5.algos
