#!/bin/bash
while IFS= read -r algo
do
    while IFS= read -r digest
    do
        while IFS= read -r salt
        do
            if [[ "$digest" =~ "$(openssl passwd -salt $salt -1 $algo | awk -F"$" '{print $4}')" ]]
            then
                echo "MATCH: $algo"
                echo "$algo" >> algos.txt
            fi
        done < salt.list
    done < otisci-digests.txt
done < list.algos
