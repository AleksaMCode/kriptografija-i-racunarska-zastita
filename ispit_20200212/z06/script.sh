#!/bin/bash
for i in {0..150}
do
    for j in {0..5}
    do
        if [ "$(diff keys/public/pub$i.pem public-keys/public$j.key | awk 'NR==1')" == "" ]
        then
            echo "MATCH FOUND: key$i.key"
        fi
    done
done
