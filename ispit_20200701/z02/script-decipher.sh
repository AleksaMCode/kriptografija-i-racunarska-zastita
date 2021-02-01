#!/bin/bash
while IFS= read -r algo
do
    openssl $algo -d -in izlaz.txt -out ulaz1.txt -k $algo
    openssl $algo -d -in ulaz1.txt -out ulaz2.txt -k $algo
    openssl $algo -d -in ulaz2.txt -out ulaz.txt -k $algo
    TEXT=$(cat ulaz.txt)
    rm ulaz*.txt
    if [[ "$TEXT" != "" ]]
    then
        echo "$algo + izlaz.txt 3x times = $TEXT"
    fi
done < decription-algos.list
