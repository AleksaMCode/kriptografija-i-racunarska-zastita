#!/bin/bash
while IFS= read -r algo
do
    openssl $algo -d -in izlaz.txt -out ulaz-$algo.txt -k $algo
done < algos.txt
