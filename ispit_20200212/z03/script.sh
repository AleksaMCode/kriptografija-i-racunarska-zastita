#!/bin/bash
for i in {1..100}
do
    DIFF=$(diff keys/public$i.pem public.pem | awk 'NR==1')
    if [ "$DIFF" == "" ]
    then
        echo "Match found: kljuc$i.key"
        break
    fi
done
