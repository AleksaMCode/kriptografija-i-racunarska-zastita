#!/bin/bash

while IFS= read -r sha #sha algo loop
do
    for i in {1..80} #key loop
    do
        for j in {1..32} #signature loop
        do
            RES=$(openssl dgst -$sha -verify keys/public/keys$i.key -signature signatures/decoded/potpis$j.sign ulaz.txt)
            if [[ "$RES" =~ "OK" ]]
            then
                echo "Solution: Key$i + $sha + ulaz.txt= potpis$j.sign"
                break 3
            fi
        done
    done
done < sha.algos
