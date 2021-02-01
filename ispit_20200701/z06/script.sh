#!/bin/bash
for i in {1..150} #150 datih kljuceva
do
    for j in {0..5} #JKS keys
    do
        DIFF=$(diff store-keys/key-jks-$j.pem keys/public/key$i.pem | awk 'NR==1')
        if [ "$DIFF" == "" ]
        then
            for k in {0..5} #P12 keys
            do
                DIFF=$(diff store-keys/key-p12-$k.pem keys/public/key$i.pem | awk 'NR==1')
                if [ "$DIFF" == "" ]
                then
                    echo "KEY $i is in both files, jks and p12."
                    break
                fi
            done
        fi
    done
done
