#!/bin/bash
for i in {1..80}
do
    KEY=$(cat keys/key$i.key | awk 'NR==1')
    if [[ "$KEY" =~ "PUBLIC" ]]
    then
        mv keys/key$i.key keys/public/keys$i.key
    elif [[ "$KEY" =~ "RSA" ]]
    then
        mv keys/key$i.key keys/rsa/keys$i.key
    elif [[ "$KEY" =~ "DSA" ]]
    then
        mv keys/key$i.key keys/dsa/keys$i.key
    fi
done
