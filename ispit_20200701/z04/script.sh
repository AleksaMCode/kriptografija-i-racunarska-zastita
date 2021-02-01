#!/bin/bash
while IFS= read -r sha
do
    for i in {1..31}
        do 
            VER=$(openssl dgst -$sha -verify kljucevi/public19.key -signature potpisi/potpis$i.txt ulaz.txt)
            if [[ "$VER" =~ "OK" ]]
            then
                echo "Solution is : kljuc19.key + $sha = potpis$i.txt"
                break 2
            fi
    done
done < sha.algos
