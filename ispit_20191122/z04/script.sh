#!/bin/bash
for i in {1..8}
do
    while IFS= read -r salt
    do
        while IFS= read -r otisak
        do
            if [[ "$1" != "crypt" ]]
            then
                if [[ "$otisak" =~ "$(openssl passwd -$1 -salt $salt lozinka$i | awk -F"$" '{print $4}')" ]]
                then
                    echo "MATCH: lozinka$i -> $otisak"
                fi
            else
                if [[ "$otisak" =~ "$(openssl passwd -$1 -salt $salt lozinka$i)" ]]
                then
                    echo "MATCH: lozinka$i -> $otisak"
                fi
            fi            
        done < digest.list
    done < $2
done
