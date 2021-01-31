#!/bin/bash
while IFS= read -r algo
do
    for i in {0..9} # za tekst*.txt datoteke
    do
        for j in {1..8} # za kljuceve
        do
            if [[ "$(openssl dgst -$algo -verify keys/public/kljuc$j.key -signature potpis.txt tasks/tekst$i.txt)" =~ "OK" ]]
            then
                echo "MATCH FOUND: $algo + public$j.key + tekst$i.txt = potpis.txt"
                break 3
            fi
        done
    done
done < hash.algos
