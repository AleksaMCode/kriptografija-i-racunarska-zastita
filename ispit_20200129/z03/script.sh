#!/bin/bash
while IFS= read -r algo
do
    for i in {1..11}
    do
        openssl dgst -$algo -out otisak.txt ulaz.txt
        if [[ "$(cat otisak.txt)" =~ "$(cat otisci/otisak$i.txt)" ]]
        then
            echo "MATCH: $algo + ulaz.txt = otisak$i.txt"
            rm otisak.txt
            break 2
        fi
        rm otisak.txt
    done
done < algos.list
