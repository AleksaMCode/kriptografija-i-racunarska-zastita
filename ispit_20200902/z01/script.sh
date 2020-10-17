#!/bin/bash
for i in {1..20}
do
    otisak=$(openssl passwd -1 -salt ... ulaz$i.txt)
    if [[ "$otisak" =~ "XkqITdBoh/5De0Fa3JAwD/" ]]
    then
        echo -n "Solution is file ulaz$i.txt -> " && cat ulaz/ulaz$i.txt && echo
        break
    fi
done
