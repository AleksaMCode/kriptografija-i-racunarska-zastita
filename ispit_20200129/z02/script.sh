#!/bin/bash
for i in {1..10}
do
    if [[ "$(openssl passwd -salt .. ulaz$i.txt)" =~ "$(cat otisak.txt)" ]]
    then
        echo "MATCH: ulaz$i.txt"
    fi
done
