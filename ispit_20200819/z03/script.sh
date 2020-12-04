#!/bin/bash

while IFS= read -r aes
do
    for i in {0..30}
    do
        openssl $aes -d -in sifrat.txt -out sifrat1.txt -k lozinka$i -md md5
        openssl $aes -d -in sifrat1.txt -out sifrat2.txt -k lozinka$i -md md5
        openssl $aes -d -in sifrat2.txt -out ulaz.txt -k lozinka$i -md md5
        rm sifrat1.txt sifrat2.txt
        MSG=$(cat ulaz.txt)
        if [ "$MSG" == "" ]
        then
            rm ulaz.txt
        else
            echo "$aes + lozinka$i -> $MSG"
            break 2
        fi
    done
done < aes.algos
