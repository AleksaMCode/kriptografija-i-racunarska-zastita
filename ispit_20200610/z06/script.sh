#!/bin/bash
while IFS= read -r sha
do
    for j in {1..5}
    do
        for i in {1..50}
        do
            if [[ "$(openssl dgst -$sha -verify keys/public/public$i.pem -signature potpis.txt keystore/keystore$j.jks)" =~ "OK" ]]
            then
                echo "Match found: key$i + $sha + keystore$j = potpis.txt"
                break 3
            fi
        done
    done    
done < sha.list
