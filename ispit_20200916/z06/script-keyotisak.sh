#!/bin/bash
while IFS= read -r sha
do
    for i in {1..50}
    do
        openssl dgst -$sha -out otisak$i-$sha.txt keys/kljuc$i.key
        cat otisak$i-$sha.txt >> otisci.txt
        rm otisak$i-$sha.txt
    done
done < sha.algos

echo -n "Solution: " && grep -f otisak.txt otisci.txt
