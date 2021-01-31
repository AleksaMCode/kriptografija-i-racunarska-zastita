#!/bin/bash
while IFS= read -r algo
do
    for i in {1..50}
    do
        openssl dgst -$algo -out otisak.txt ulazi/ulaz$i.txt
        for j in {1..4}
        do
            if [[ "$(cat otisak.txt)" =~ "$(cat otisci/otisak$j.txt)" ]]
            then
                echo "ulaz$i.txt + $algo = otisak$j.txt"
                break
            fi
        done
    done
done < digest.list
