#!/bin/bash
while IFS= read -r algo
do
    openssl $algo -d -in izlaz.txt -out ulazi/ulaz-$algo.txt -k $algo -md md5
    echo "$algo: " && cat ulazi/ulaz-$algo.txt && echo -e "\n"
done < algos.txt
