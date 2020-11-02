#!/bin/bash
otisak=$(cat otisak.txt)
while IFS= read -r algo
do
    for i in {1..50}
    do
        if [[ "$(openssl dgst -$algo ulaz/ulaz$i.txt)" =~ "$otisak" ]]
        then
            echo "Match found: ulaz$i.txt + $algo = otisak.txt"
            break 2
        fi
    done
done < hash_algos.list
