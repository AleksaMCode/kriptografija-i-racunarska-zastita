#!/bin/bash
for i in {1..10}
do
    while IFS= read -r otisak
    do
        while IFS= read -r salt
        do
            if [[ "$otisak" == "$(openssl passwd -salt $salt sifra$i)" ]]
            then
                echo "sifra$i -> $otisak"
            fi
            if [[ "$otisak" == "$(openssl passwd -1 -salt $salt sifra$i)" ]]
            then
                echo "sifra$i -> $otisak"
            fi
            if [[ "$otisak" == "$(openssl passwd -apr1 -salt $salt sifra$i)" ]]
            then
                echo "sifra$i -> $otisak"
            fi
        done < salt.list
    done < otisci.list
done
