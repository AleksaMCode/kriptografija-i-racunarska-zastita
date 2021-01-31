#!/bin/bash
while IFS= read -r camellia
do
    openssl $camellia -d -in sifrat.txt -out sifrat-1.txt -k $1 -md md5
    openssl $camellia -d -in sifrat-1.txt -out sifrat-2.txt -k $2 -md md5
    openssl $camellia -d -in sifrat-2.txt -out ulaz.txt -k $3 -md md5
    rm sifrat-1.txt sifrat-2.txt
    TEXT=$(cat ulaz.txt)
    if [ "$TEXT" == "" ]
    then
        rm ulaz.txt
    else
        echo "$camellia with key combo $1 + $2 + $3 -> $TEXT"
    fi
done < camellia.algos
