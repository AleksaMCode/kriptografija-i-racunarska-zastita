#!/bin/bash
for i in {1..50}
do
    DIFF=$(diff kljuc.key keys/public/pub-key$i.pem)
    if [ "$DIFF" == "" ]
    then
        echo "Match found. Key is located in store$i.p12 file"
        cp stores/store$i.p12 .
        break
    fi
done
