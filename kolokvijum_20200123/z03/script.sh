#!/bin/bash
while IFS= read -r sha # za sha algoritme
do
    for i in {1..10} # za kljuceve
    do
        for j in {1..31} # za potpise
        do
            if [[ "$(openssl dgst -$sha -verify keys/public$i.pem -signature signatures/potpis$j.txt ulaz.txt)" =~ "OK" ]]
            then
                echo "Solution: ulaz.txt + kljuc$i + $sha algo = potpis$j"
                break 3
            fi
        done
    done
done < sha.algos
